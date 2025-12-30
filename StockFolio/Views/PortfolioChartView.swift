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

    /// 비중 기준 내림차순 정렬된 종목 목록
    private var sortedHoldings: [StockHoldingEntity] {
        viewModel.holdings.sorted { viewModel.percentage(for: $0) > viewModel.percentage(for: $1) }
    }

    /// 비중 순서에 따른 색상 반환
    private func colorForIndex(_ index: Int) -> Color {
        StockColor.fromIndex(index).color
    }

    /// 종목명으로 색상 조회 (비중 순서 기반)
    private func colorForStockName(_ name: String) -> Color {
        if let index = sortedHoldings.firstIndex(where: { $0.stockName == name }) {
            return colorForIndex(index)
        }
        return .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("포트폴리오 구성")
                .font(.headline)
                .padding(.horizontal)

            ZStack {
                chartContent
                    .padding(.horizontal)

                // 툴팁 (클릭 이벤트를 차단하지 않도록 설정)
                if let selected = selectedItem {
                    tooltipView(for: selected)
                        .allowsHitTesting(false)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedItem)
    }

    // MARK: - Chart Content
    private var chartContent: some View {
        VStack(spacing: 16) {
            // 차트 영역 (화면 너비 기준 정사각형에 가깝게)
            Chart {
                // 투자된 종목들
                ForEach(Array(sortedHoldings.enumerated()), id: \.element.id) { index, holding in
                    SectorMark(
                        angle: .value("금액", holding.purchaseAmount),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("종목", holding.stockName))
                    .cornerRadius(4)
                    .opacity(selectedItem == nil || selectedItem == holding.stockName ? 1.0 : 0.5)
                    .annotation(position: .overlay) {
                        if viewModel.percentage(for: holding) >= 5 {
                            let stockColor = StockColor.fromIndex(index)
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
                    .opacity(selectedItem == nil || selectedItem == "현금" ? 1.0 : 0.5)
                    .annotation(position: .overlay) {
                        if viewModel.cashPercentage >= 5 {
                            Text(String(format: "%.0f%%", viewModel.cashPercentage))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .chartLegend(.hidden) // 기본 범례 숨김 (커스텀 범례 사용)
            .chartForegroundStyleScale(domain: chartColorDomain, range: chartColorRangeWithGradient)
            .chartAngleSelection(value: $selectedItem)
            .aspectRatio(1, contentMode: .fit) // 정사각형 비율 유지
            .frame(maxHeight: 250) // 최대 높이 제한
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
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
            ForEach(Array(sortedHoldings.enumerated()), id: \.element.id) { index, holding in
                legendItem(
                    name: holding.stockName,
                    color: colorForIndex(index),
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
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(selectedItem == name ? color.opacity(0.2) : Color(.tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(selectedItem == name ? color : Color.clear, lineWidth: 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                if selectedItem == name {
                    selectedItem = nil
                } else {
                    selectedItem = name
                }
            }
        }
    }

    // MARK: - Tooltip
    @ViewBuilder
    private func tooltipView(for itemName: String) -> some View {
        if itemName == "현금" {
            tooltipContent(
                name: "현금",
                amount: viewModel.remainingCash,
                percentage: viewModel.cashPercentage,
                quantity: nil,
                averagePrice: nil,
                color: .gray
            )
        } else if let holding = sortedHoldings.first(where: { $0.stockName == itemName }) {
            tooltipContent(
                name: holding.stockName,
                amount: holding.purchaseAmount,
                percentage: viewModel.percentage(for: holding),
                quantity: holding.quantity,
                averagePrice: holding.averagePrice,
                color: colorForStockName(holding.stockName)
            )
        }
    }

    private func tooltipContent(name: String, amount: Double, percentage: Double, quantity: Int?, averagePrice: Double?, color: Color) -> some View {
        VStack(spacing: 8) {
            // 종목명
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Divider()

            // 상세 정보
            VStack(spacing: 4) {
                // 보유 수량 (종목인 경우에만)
                if let qty = quantity, qty > 0 {
                    HStack {
                        Text("보유수량")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(qty)주")
                            .font(.caption)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    }
                }

                // 평균매입가 (종목인 경우에만)
                if let avgPrice = averagePrice, avgPrice > 0 {
                    HStack {
                        Text("평균매입가")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(avgPrice.currencyFormatted)
                            .font(.caption)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    }
                }

                HStack {
                    Text("투자금액")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(amount.currencyFormatted)
                        .font(.caption)
                        .fontWeight(.medium)
                        .monospacedDigit()
                }

                HStack {
                    Text("비중")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f%%", percentage))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(color)
                        .monospacedDigit()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.3), lineWidth: 1.5)
        )
        .frame(width: 200)
        .fixedSize()
    }

    // MARK: - Chart Colors
    private var chartColorDomain: [String] {
        var domain = sortedHoldings.map { $0.stockName }
        if viewModel.remainingCash > 0 {
            domain.append("현금")
        }
        return domain
    }

    private var chartColorRange: [Color] {
        var range = sortedHoldings.enumerated().map { index, _ in
            colorForIndex(index)
        }

        if viewModel.remainingCash > 0 {
            range.append(.gray)
        }

        return range
    }

    /// 그라디언트 효과를 적용한 차트 색상 범위
    private var chartColorRangeWithGradient: [AnyShapeStyle] {
        var range: [AnyShapeStyle] = sortedHoldings.enumerated().map { index, _ in
            let color = colorForIndex(index)
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        color,
                        color.opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        if viewModel.remainingCash > 0 {
            range.append(
                AnyShapeStyle(
                    LinearGradient(
                        colors: [.gray, .gray.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            )
        }

        return range
    }

    // MARK: - Accessibility
    private var accessibilityDescription: String {
        var description = "포트폴리오 구성 차트. "

        for holding in sortedHoldings {
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
