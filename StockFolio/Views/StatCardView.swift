import SwiftUI

/// StatCard - 매매일지 스타일의 통계 카드 컴포넌트
/// SRP: 단일 통계 항목 표시만 담당
struct StatCard: View {
    let title: String
    let value: String
    let valueColor: Color
    let additionalInfo: String?
    let onTap: (() -> Void)?

    init(
        title: String,
        value: String,
        valueColor: Color = .primary,
        additionalInfo: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
        self.additionalInfo = additionalInfo
        self.onTap = onTap
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                // 제목 (라벨)
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                // 주요 값
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .monospacedDigit()

                // 부가 정보 (옵션)
                if let info = additionalInfo {
                    Text(info)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }
}

/// 포트폴리오 통계 섹션 (1x2 Row)
/// 간소화 버전: 투자금과 남은 현금만 표시
struct PortfolioStatisticsSection: View {
    @ObservedObject var viewModel: PortfolioViewModel
    let onSeedMoneyTap: () -> Void

    // 진한 파랑 (투자금용)
    private var darkBlue: Color {
        Color(red: 0.0, green: 0.3, blue: 0.7)
    }

    // 진한 초록 (남은 현금용)
    private var darkGreen: Color {
        Color(red: 0.0, green: 0.5, blue: 0.3)
    }

    var body: some View {
        HStack(spacing: 12) {
            // 1. 투자 금액 카드
            StatCard(
                title: "투자금",
                value: viewModel.totalInvestedAmount.currencyFormatted,
                valueColor: darkBlue,
                additionalInfo: percentageText(viewModel.investedPercentage)
            )

            // 2. 남은 현금 카드
            StatCard(
                title: "남은 현금",
                value: viewModel.remainingCash.currencyFormatted,
                valueColor: darkGreen,
                additionalInfo: percentageText(viewModel.cashPercentage)
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Helper Methods

    private func percentageText(_ percentage: Double) -> String {
        String(format: "%.1f%%", percentage)
    }
}

#Preview {
    PortfolioStatisticsSection(
        viewModel: PortfolioViewModel(),
        onSeedMoneyTap: {}
    )
}
