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
    var fetchByDateCallCount = 0
    var fetchByMonthCallCount = 0
    var fetchByYearCallCount = 0

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

    func fetchByDate(_ date: Date) -> [TradingJournalEntity] {
        fetchByDateCallCount += 1
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return journals.filter { journal in
            journal.tradeDate >= startOfDay && journal.tradeDate < endOfDay
        }.sorted { $0.tradeDate > $1.tradeDate }
    }

    func fetchByMonth(year: Int, month: Int) -> [TradingJournalEntity] {
        fetchByMonthCallCount += 1
        let calendar = Calendar.current

        return journals.filter { journal in
            let components = calendar.dateComponents([.year, .month], from: journal.tradeDate)
            return components.year == year && components.month == month
        }.sorted { $0.tradeDate > $1.tradeDate }
    }

    func fetchByYear(_ year: Int) -> [TradingJournalEntity] {
        fetchByYearCallCount += 1
        let calendar = Calendar.current

        return journals.filter { journal in
            let components = calendar.dateComponents([.year], from: journal.tradeDate)
            return components.year == year
        }.sorted { $0.tradeDate > $1.tradeDate }
    }
}
