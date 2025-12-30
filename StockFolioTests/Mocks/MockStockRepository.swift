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

    // MARK: - Pagination & Statistics

    func fetch(pagination: PaginationRequest) -> PaginationResult<StockHoldingEntity> {
        let sorted = stocks.sorted { $0.createdAt > $1.createdAt }

        let endIndex = min(pagination.offset + pagination.limit, sorted.count)
        guard pagination.offset < sorted.count else {
            return PaginationResult(items: [], totalCount: sorted.count, hasMore: false)
        }

        let items = Array(sorted[pagination.offset..<endIndex])
        let hasMore = endIndex < sorted.count

        return PaginationResult(items: items, totalCount: sorted.count, hasMore: hasMore)
    }

    func fetchTotalCount() -> Int {
        return stocks.count
    }

    func fetchTotalInvestedAmount() -> Double {
        return stocks.reduce(0) { $0 + $1.purchaseAmount }
    }

    // MARK: - 매매일지 연동용 메서드

    func fetchByStockName(_ stockName: String) -> StockHoldingEntity? {
        return stocks.first { $0.stockName == stockName }
    }

    func upsert(_ stock: StockHoldingEntity) throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        if let index = stocks.firstIndex(where: { $0.stockName == stock.stockName }) {
            stocks[index] = stock
            updateCallCount += 1
        } else {
            stocks.append(stock)
            saveCallCount += 1
        }
    }

    func deleteByStockName(_ stockName: String) throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        deleteCallCount += 1
        stocks.removeAll { $0.stockName == stockName }
    }
}
