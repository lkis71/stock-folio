import Foundation

struct TradingJournalStatistics {
    let totalCount: Int
    let buyCount: Int
    let sellCount: Int
    let totalRealizedProfit: Double
    let totalSellAmount: Double

    let winRate: Double

    var totalProfitRate: Double {
        let totalInvested = totalSellAmount - totalRealizedProfit
        guard totalInvested > 0 else { return 0 }
        return (totalRealizedProfit / totalInvested) * 100
    }

    init(totalCount: Int, buyCount: Int, sellCount: Int, totalRealizedProfit: Double, totalSellAmount: Double, winRate: Double = 0) {
        self.totalCount = totalCount
        self.buyCount = buyCount
        self.sellCount = sellCount
        self.totalRealizedProfit = totalRealizedProfit
        self.totalSellAmount = totalSellAmount
        self.winRate = winRate
    }
}
