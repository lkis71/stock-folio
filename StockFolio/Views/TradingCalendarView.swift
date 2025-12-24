import SwiftUI

struct TradingCalendarView: View {
    @StateObject private var viewModel = TradingCalendarViewModel()

    private let calendar = Calendar.current
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        VStack(spacing: 0) {
            // 헤더: 월 선택
            monthHeader

            // 월별 통계 카드
            if let stats = viewModel.monthlyStatistics {
                monthlyStatsCard(stats)
            }

            // 요일 헤더
            weekdayHeader

            // 캘린더 그리드 - 고정 높이
            calendarGrid
                .frame(height: calculateCalendarHeight())

            Spacer()
        }
        .sheet(isPresented: $viewModel.showingDailyTrades) {
            if let selectedDate = viewModel.selectedDate,
               let summary = viewModel.getDailySummary(for: selectedDate) {
                DailyTradesSheet(summary: summary)
            }
        }
    }

    // 캘린더 높이 계산 (최대 6주)
    private func calculateCalendarHeight() -> CGFloat {
        return 70 * 6  // 셀 높이 70pt × 최대 6주
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                viewModel.moveToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(monthTitle)
                    .font(.headline)
                    .fontWeight(.semibold)

                if !calendar.isDate(viewModel.currentMonth, equalTo: Date(), toGranularity: .month) {
                    Button {
                        viewModel.moveToToday()
                    } label: {
                        Text("오늘")
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                    }
                }
            }

            Spacer()

            Button {
                viewModel.moveToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 0)
        .padding(.bottom, 12)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: viewModel.currentMonth)
    }

    // MARK: - Monthly Stats Card

    private func monthlyStatsCard(_ stats: MonthlyStatistics) -> some View {
        VStack(spacing: 8) {
            // 헤더: 제목 + 접기 버튼
            HStack {
                Text("월 통계")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    viewModel.toggleStatExpanded()
                } label: {
                    Image(systemName: viewModel.isStatExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 통계 내용 - 접기 가능
            if viewModel.isStatExpanded {
                HStack(spacing: 16) {
                    StatItem(
                        title: "총 손익",
                        value: formattedProfit(stats.totalProfit),
                        valueColor: stats.totalProfit >= 0 ? .red : .blue
                    )

                    Divider()
                        .frame(height: 30)

                    StatItem(
                        title: "거래",
                        value: "\(stats.totalTradeCount)건",
                        valueColor: .primary
                    )

                    Divider()
                        .frame(height: 30)

                    StatItem(
                        title: "수익률",
                        value: String(format: "%.1f%%", stats.winRate),
                        valueColor: stats.winRate >= 0 ? .red : .blue
                    )
                }
                .transition(.opacity)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.weeksInMonth(), id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        if let date = week[index] {
                            DateCell(
                                date: date,
                                summary: viewModel.getDailySummary(for: date),
                                isToday: viewModel.isToday(date),
                                isCurrentMonth: viewModel.isCurrentMonth(date),
                                onTap: {
                                    viewModel.selectDate(date)
                                }
                            )
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Helper Methods

    private func formattedProfit(_ profit: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let sign = profit >= 0 ? "+" : ""
        return sign + (formatter.string(from: NSNumber(value: profit)) ?? "0") + "원"
    }
}

// MARK: - Date Cell

struct DateCell: View {
    let date: Date
    let summary: DailyTradingSummary?
    let isToday: Bool
    let isCurrentMonth: Bool
    let onTap: () -> Void

    private var hasTrades: Bool {
        summary?.hasTrades ?? false
    }

    private var profitColor: Color {
        guard let summary = summary else { return .clear }
        return summary.hasProfit ? .red : .blue  // 수익=빨간색, 손실=파란색
    }

    var body: some View {
        Button {
            if hasTrades {
                onTap()
            }
        } label: {
            VStack(spacing: 2) {
                // 날짜
                Text(dayString)
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isCurrentMonth ? .primary : .secondary)

                // 거래 정보
                if let summary = summary {
                    // 거래 건수
                    Text("\(summary.tradeCount)건")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // 수익률
                    if abs(summary.profitRate) >= 0.1 {
                        Text(formattedRate(summary.profitRate))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(profitColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                } else {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(isToday ? Color.accentColor.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasTrades ? profitColor.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!hasTrades)
    }

    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func formattedProfit(_ profit: Double) -> String {
        let absProfit = abs(profit)
        let sign = profit >= 0 ? "+" : "-"

        if absProfit >= 10000 {
            return sign + String(format: "%.1fK", absProfit / 1000)
        } else if absProfit >= 1000 {
            return sign + String(format: "%.1fK", absProfit / 1000)
        } else {
            return sign + String(format: "%.0f", absProfit)
        }
    }

    private func formattedRate(_ rate: Double) -> String {
        let sign = rate >= 0 ? "+" : ""
        return sign + String(format: "%.1f%%", rate)
    }

    private func formattedProfitWithRate(_ summary: DailyTradingSummary) -> String {
        let profitStr = formattedProfit(summary.totalProfit)
        if abs(summary.profitRate) >= 0.1 {
            return "\(profitStr) (\(formattedRate(summary.profitRate)))"
        }
        return profitStr
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TradingCalendarView()
}
