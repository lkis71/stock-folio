import Foundation

/// 종목 보유 엔티티 (Model - 데이터만 표현)
struct StockHoldingEntity: Identifiable, Equatable {
    let id: UUID
    var stockName: String
    var purchaseAmount: Double
    let createdAt: Date

    init(
        id: UUID = UUID(),
        stockName: String,
        purchaseAmount: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.stockName = stockName
        self.purchaseAmount = purchaseAmount
        self.createdAt = createdAt
    }
}
