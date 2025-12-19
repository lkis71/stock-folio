import Foundation

enum TradeType: String, Codable, CaseIterable {
    case buy = "매수"
    case sell = "매도"

    var color: String {
        switch self {
        case .buy: return "green"
        case .sell: return "red"
        }
    }
}

enum FilterType: String, Codable, CaseIterable {
    case all = "전체"
    case daily = "일별"
    case monthly = "월별"
    case yearly = "년도별"
}

struct TradingJournalEntity: Identifiable {
    let id: UUID
    var tradeType: TradeType
    var tradeDate: Date
    var stockName: String
    var quantity: Int
    var price: Double
    var reason: String
    var createdAt: Date
    var updatedAt: Date

    var totalAmount: Double {
        Double(quantity) * price
    }

    init(
        id: UUID = UUID(),
        tradeType: TradeType,
        tradeDate: Date,
        stockName: String,
        quantity: Int,
        price: Double,
        reason: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.tradeType = tradeType
        self.tradeDate = tradeDate
        self.stockName = stockName
        self.quantity = quantity
        self.price = price
        self.reason = reason
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension TradingJournalEntity {
    init(from managedObject: TradingJournalMO) {
        self.id = managedObject.id ?? UUID()
        self.tradeType = TradeType(rawValue: managedObject.tradeType ?? "") ?? .buy
        self.tradeDate = managedObject.tradeDate ?? Date()
        self.stockName = managedObject.stockName ?? ""
        self.quantity = Int(managedObject.quantity)
        self.price = managedObject.price
        self.reason = managedObject.reason ?? ""
        self.createdAt = managedObject.createdAt ?? Date()
        self.updatedAt = managedObject.updatedAt ?? Date()
    }
}
