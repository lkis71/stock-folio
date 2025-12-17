import SwiftUI
import Charts

// MARK: - Array Safe Subscript
private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

/// 포트폴리오 파이 차트 뷰 (Swift Charts 사용)
/// SRP: 차트 시각화만 담당
struct PortfolioChartView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @State private var selectedItem: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("포트폴리오 구성")
                .font(.headline)
                .padding(.horizontal)

            if let selected = selectedItem {
                selectedItemInfo(selected)
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
            }

            chartContent
                .padding(.horizontal)
        }
        .animation(.easeInOut(duration: 0.3), value: selectedItem)
    }

    // MARK: - Chart Content
    private var chartContent: some View {
        VStack(spacing: 16) {
            // 차트 영역 (화면 너비 기준 정사각형에 가깝게)
            Chart {
                // 투자된 종목들
                ForEach(viewModel.holdings) { holding in
                    SectorMark(
                        angle: .value("금액", holding.purchaseAmount),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("종목", holding.stockName))
                    .cornerRadius(4)
                    .annotation(position: .overlay) {
                        if viewModel.percentage(for: holding) >= 10 {
                            let stockColor = StockColor(rawValue: holding.colorName) ?? .blue
                            Text(String(format: "%.0f%%", viewModel.percentage(for: holding)))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(stockColor.isLightColor ? .black : .white)
                                .shadow(color: stockColor.isLightColor ? .white.opacity(0.8) : .black.opacity(0.5), radius: 2)
                        }
                    }
                }

                // 남은 현금 (있을 경우만)
                if viewModel.remainingCash > 0 {
                    SectorMark(
                        angle: .value("금액", viewModel.remainingCash),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("종목", "현금"))
                    .cornerRadius(4)
                    .annotation(position: .overlay) {
                        if viewModel.cashPercentage >= 10 {
                            Text(String(format: "%.0f%%", viewModel.cashPercentage))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .chartLegend(.hidden) // 기본 범례 숨김 (커스텀 범례 사용)
            .chartForegroundStyleScale(domain: chartColorDomain, range: chartColorRange)
            .chartAngleSelection(value: $selectedItem)
            .aspectRatio(1, contentMode: .fit) // 정사각형 비율 유지
            .frame(maxHeight: 250) // 최대 높이 제한
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityDescription)

            // 커스텀 범례 (스크롤 가능, 그리드 레이아웃)
            legendView
        }
    }

    // MARK: - Custom Legend
    private var legendView: some View {
        let columns = [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.holdings) { holding in
                legendItem(
                    name: holding.stockName,
                    color: holding.color,
                    percentage: viewModel.percentage(for: holding)
                )
            }

            if viewModel.remainingCash > 0 {
                legendItem(
                    name: "현금",
                    color: .gray,
                    percentage: viewModel.cashPercentage
                )
            }
        }
    }

    private func legendItem(name: String, color: Color, percentage: Double) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(name)
                .font(.caption)
                .lineLimit(1)

            Spacer(minLength: 4)

            Text(String(format: "%.1f%%", percentage))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Selected Item Info
    @ViewBuilder
    private func selectedItemInfo(_ itemName: String) -> some View {
        if itemName == "현금" {
            cashInfoCard
        } else if let holding = viewModel.holdings.first(where: { $0.stockName == itemName }) {
            stockInfoCard(holding)
        }
    }

    private var cashInfoCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("현금")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(viewModel.remainingCash.currencyFormatted)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text(String(format: "%.1f%%", viewModel.cashPercentage))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func stockInfoCard(_ holding: StockHoldingEntity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(holding.stockName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(holding.purchaseAmount.currencyFormatted)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text(String(format: "%.1f%%", viewModel.percentage(for: holding)))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Chart Colors
    private var chartColorDomain: [String] {
        var domain = viewModel.holdings.map { $0.stockName }
        if viewModel.remainingCash > 0 {
            domain.append("현금")
        }
        return domain
    }

    private var chartColorRange: [Color] {
        var range = viewModel.holdings.map { $0.color }

        if viewModel.remainingCash > 0 {
            range.append(.gray)
        }

        return range
    }

    // MARK: - Accessibility
    private var accessibilityDescription: String {
        var description = "포트폴리오 구성 차트. "

        for holding in viewModel.holdings {
            let percentage = viewModel.percentage(for: holding)
            description += "\(holding.stockName) \(String(format: "%.1f", percentage))%, "
        }

        if viewModel.remainingCash > 0 {
            description += "현금 \(String(format: "%.1f", viewModel.cashPercentage))%"
        }

        return description
    }
}

#Preview {
    PortfolioChartView(viewModel: PortfolioViewModel())
}
