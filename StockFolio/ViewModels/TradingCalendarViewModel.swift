import Foundation
import SwiftUI

final class TradingCalendarViewModel: ObservableObject {

    @Published private(set) var monthlyStatistics: MonthlyStatistics?
    @Published private(set) var dailySummaries: [Date: DailyTradingSummary] = [:]
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date?
    @Published var showingDailyTrades: Bool = false

    private let repository: TradingJournalRepositoryProtocol
    private let calendar = Calendar.current

    init(repository: TradingJournalRepositoryProtocol = CoreDataTradingJournalRepository()) {
        self.repository = repository
        loadMonthData()
    }

    // MARK: - Data Loading

    func loadMonthData() {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let year = components.year, let month = components.month else { return }

        // 월의 시작일과 종료일 계산
        guard let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return
        }

        // 월별 모든 거래 조회
        let allTrades = repository.fetchByMonth(year: year, month: month)

        // 일별로 그룹화
        let groupedByDate = Dictionary(grouping: allTrades) { trade in
            calendar.startOfDay(for: trade.tradeDate)
        }

        // 일별 요약 생성
        var summaries: [Date: DailyTradingSummary] = [:]
        for (date, trades) in groupedByDate {
            let sellTrades = trades.filter { $0.tradeType == .sell }
            let totalProfit = sellTrades.reduce(0) { $0 + $1.realizedProfit }

            // 수익률 계산: (총 실현손익 / 총 투자금액) × 100
            let totalSellAmount = sellTrades.reduce(0) { $0 + $1.totalAmount }
            let totalInvested = totalSellAmount - totalProfit
            let profitRate = totalInvested > 0 ? (totalProfit / totalInvested) * 100 : 0

            let summary = DailyTradingSummary(
                date: date,
                tradeCount: trades.count,
                totalProfit: totalProfit,
                profitRate: profitRate,
                trades: trades
            )
            summaries[date] = summary
        }

        self.dailySummaries = summaries

        // 월별 통계 계산
        let sellTrades = allTrades.filter { $0.tradeType == .sell }
        let totalProfit = sellTrades.reduce(0) { $0 + $1.realizedProfit }

        // 월 전체 수익률 계산: (총 실현손익 / 총 투자금액) × 100
        let totalSellAmount = sellTrades.reduce(0) { $0 + $1.totalAmount }
        let totalInvested = totalSellAmount - totalProfit  // 투자 원금
        let profitRate = totalInvested > 0 ? (totalProfit / totalInvested) * 100 : 0

        let dailySummaryList = summaries.values.sorted { $0.date < $1.date }

        self.monthlyStatistics = MonthlyStatistics(
            year: year,
            month: month,
            totalProfit: totalProfit,
            totalTradeCount: allTrades.count,
            profitRate: profitRate,
            dailySummaries: dailySummaryList
        )

        Logger.info("[TradingCalendar] Loaded month: \(year)-\(month), Trades: \(allTrades.count), Days with trades: \(summaries.count)")
    }

    // MARK: - Navigation

    func moveToNextMonth() {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        withAnimation(.spring(duration: 0.3)) {
            currentMonth = nextMonth
        }
        loadMonthData()
    }

    func moveToPreviousMonth() {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        withAnimation(.spring(duration: 0.3)) {
            currentMonth = previousMonth
        }
        loadMonthData()
    }

    func moveToToday() {
        withAnimation(.spring(duration: 0.3)) {
            currentMonth = Date()
        }
        loadMonthData()
    }

    // MARK: - Date Selection

    func selectDate(_ date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        guard dailySummaries[startOfDay] != nil else {
            Logger.info("[TradingCalendar] No trades on selected date: \(date)")
            return
        }

        selectedDate = startOfDay
        showingDailyTrades = true
    }

    func getDailySummary(for date: Date) -> DailyTradingSummary? {
        let startOfDay = calendar.startOfDay(for: date)
        return dailySummaries[startOfDay]
    }

    // MARK: - Calendar Helper Methods

    func daysInMonth() -> [Date] {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    func weeksInMonth() -> [[Date?]] {
        let days = daysInMonth()
        guard let firstDay = days.first else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingEmptyDays = Array(repeating: nil as Date?, count: firstWeekday - 1)

        var allDays: [Date?] = leadingEmptyDays + days.map { $0 as Date? }

        // 마지막 주를 7일로 채우기
        let remainingDays = allDays.count % 7
        if remainingDays > 0 {
            allDays += Array(repeating: nil as Date?, count: 7 - remainingDays)
        }

        // 7일씩 나누어 주 단위 배열 생성
        var weeks: [[Date?]] = []
        for i in stride(from: 0, to: allDays.count, by: 7) {
            let week = Array(allDays[i..<min(i + 7, allDays.count)])
            weeks.append(week)
        }

        return weeks
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
}
