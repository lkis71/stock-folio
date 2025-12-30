import Foundation

// MARK: - 일별 매매 요약
struct DailyTradingSummary: Identifiable {
    let id: UUID
    let date: Date
    let tradeCount: Int
    let totalProfit: Double
    let profitRate: Double
    let trades: [TradingJournalEntity]

    var hasProfit: Bool {
        totalProfit > 0
    }

    var hasTrades: Bool {
        tradeCount > 0
    }

    init(
        id: UUID = UUID(),
        date: Date,
        tradeCount: Int,
        totalProfit: Double,
        profitRate: Double,
        trades: [TradingJournalEntity]
    ) {
        self.id = id
        self.date = date
        self.tradeCount = tradeCount
        self.totalProfit = totalProfit
        self.profitRate = profitRate
        self.trades = trades
    }
}

// MARK: - 월별 통계
struct MonthlyStatistics: Identifiable {
    let id: UUID
    let year: Int
    let month: Int
    let totalProfit: Double
    let totalTradeCount: Int
    let profitRate: Double  // 월 전체 수익률: (총 실현손익 / 총 투자금액) × 100
    let dailySummaries: [DailyTradingSummary]

    var monthString: String {
        "\(year)년 \(month)월"
    }

    init(
        id: UUID = UUID(),
        year: Int,
        month: Int,
        totalProfit: Double,
        totalTradeCount: Int,
        profitRate: Double,
        dailySummaries: [DailyTradingSummary]
    ) {
        self.id = id
        self.year = year
        self.month = month
        self.totalProfit = totalProfit
        self.totalTradeCount = totalTradeCount
        self.profitRate = profitRate
        self.dailySummaries = dailySummaries
    }
}
