import Foundation
@testable import StockFolio

final class MockTradingJournalRepository: TradingJournalRepositoryProtocol {

    var journals: [TradingJournalEntity] = []
    var shouldThrowError = false

    var saveCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0
    var fetchAllCallCount = 0
    var fetchCallCount = 0

    func fetchAll() -> [TradingJournalEntity] {
        fetchAllCallCount += 1
        return journals.sorted { $0.tradeDate > $1.tradeDate }
    }

    func fetch(limit: Int, offset: Int) -> [TradingJournalEntity] {
        fetchCallCount += 1
        let sorted = journals.sorted { $0.tradeDate > $1.tradeDate }
        let endIndex = min(offset + limit, sorted.count)
        guard offset < sorted.count else { return [] }
        return Array(sorted[offset..<endIndex])
    }

    func save(_ journal: TradingJournalEntity) throws {
        saveCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock save error"])
        }
        journals.append(journal)
    }

    func update(_ journal: TradingJournalEntity) throws {
        updateCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock update error"])
        }
        guard let index = journals.firstIndex(where: { $0.id == journal.id }) else {
            throw NSError(domain: "MockRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Journal not found"])
        }
        journals[index] = journal
    }

    func delete(_ journal: TradingJournalEntity) throws {
        deleteCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock delete error"])
        }
        guard let index = journals.firstIndex(where: { $0.id == journal.id }) else {
            throw NSError(domain: "MockRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Journal not found"])
        }
        journals.remove(at: index)
    }
}
