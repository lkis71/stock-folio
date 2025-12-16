import Foundation
@testable import StockFolio

/// 테스트용 Mock Repository (DIP 적용)
final class MockStockRepository: StockRepositoryProtocol {
    var stocks: [StockHoldingEntity] = []
    var saveCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    var shouldThrowError = false

    func fetchAll() -> [StockHoldingEntity] {
        return stocks
    }

    func save(_ stock: StockHoldingEntity) throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        saveCallCount += 1
        stocks.append(stock)
    }

    func update(_ stock: StockHoldingEntity) throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        updateCallCount += 1
        if let index = stocks.firstIndex(where: { $0.id == stock.id }) {
            stocks[index] = stock
        }
    }

    func delete(_ stock: StockHoldingEntity) throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        deleteCallCount += 1
        stocks.removeAll { $0.id == stock.id }
    }
}
