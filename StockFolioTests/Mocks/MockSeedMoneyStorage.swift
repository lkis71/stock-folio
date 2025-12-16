import Foundation
@testable import StockFolio

/// 테스트용 Mock SeedMoney Storage
final class MockSeedMoneyStorage: SeedMoneyStorageProtocol {
    var savedSeedMoney: Double = 0

    func getSeedMoney() -> Double {
        return savedSeedMoney
    }

    func saveSeedMoney(_ amount: Double) {
        savedSeedMoney = amount
    }
}
