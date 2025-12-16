import SwiftUI
import Charts

/// 포트폴리오 파이 차트 뷰 (Swift Charts 사용)
/// SRP: 차트 시각화만 담당
struct PortfolioChartView: View {
    @ObservedObject var viewModel: PortfolioViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("포트폴리오 구성")
                .font(.headline)
                .padding(.horizontal)

            chartContent
                .padding(.horizontal)
        }
    }

    // MARK: - Chart Content
    private var chartContent: some View {
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
                        Text(String(format: "%.0f%%", viewModel.percentage(for: holding)))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
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
        .chartLegend(position: .bottom, spacing: 16)
        .chartForegroundStyleScale(chartColors)
        .frame(height: 280)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Chart Colors
    private var chartColors: [String: Color] {
        var colors: [String: Color] = [:]
        let baseColors: [Color] = [
            .blue, .green, .orange, .purple, .pink,
            .cyan, .indigo, .mint, .teal, .yellow
        ]

        for (index, holding) in viewModel.holdings.enumerated() {
            colors[holding.stockName] = baseColors[index % baseColors.count]
        }

        // 현금은 항상 회색
        colors["현금"] = .gray

        return colors
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
