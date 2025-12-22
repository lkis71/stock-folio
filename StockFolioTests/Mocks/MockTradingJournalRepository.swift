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

    // MARK: - Pagination & Statistics

    func fetch(pagination: PaginationRequest, filter: TradingJournalFilter?) -> PaginationResult<TradingJournalEntity> {
        let filtered = applyFilter(journals, filter: filter)
        let sorted = filtered.sorted { $0.tradeDate > $1.tradeDate }

        let endIndex = min(pagination.offset + pagination.limit, sorted.count)
        guard pagination.offset < sorted.count else {
            return PaginationResult(items: [], totalCount: sorted.count, hasMore: false)
        }

        let items = Array(sorted[pagination.offset..<endIndex])
        let hasMore = endIndex < sorted.count

        return PaginationResult(items: items, totalCount: sorted.count, hasMore: hasMore)
    }

    func fetchStatistics(filter: TradingJournalFilter?) -> TradingJournalStatistics {
        let filtered = applyFilter(journals, filter: filter)

        let totalCount = filtered.count
        let buyCount = filtered.filter { $0.tradeType == .buy }.count
        let sellCount = filtered.filter { $0.tradeType == .sell }.count
        let sellJournals = filtered.filter { $0.tradeType == .sell }
        let totalRealizedProfit = sellJournals.reduce(0) { $0 + $1.realizedProfit }
        let totalSellAmount = sellJournals.reduce(0) { $0 + $1.totalAmount }

        let winRate = fetchWinRate(filter: filter)

        return TradingJournalStatistics(
            totalCount: totalCount,
            buyCount: buyCount,
            sellCount: sellCount,
            totalRealizedProfit: totalRealizedProfit,
            totalSellAmount: totalSellAmount,
            winRate: winRate
        )
    }

    func fetchWinRate(filter: TradingJournalFilter?) -> Double {
        let filtered = applyFilter(journals, filter: filter)
        let sellJournals = filtered.filter { $0.tradeType == .sell }
        guard !sellJournals.isEmpty else { return 0 }

        let winCount = sellJournals.filter { $0.realizedProfit > 0 }.count
        return (Double(winCount) / Double(sellJournals.count)) * 100
    }

    private func applyFilter(_ journals: [TradingJournalEntity], filter: TradingJournalFilter?) -> [TradingJournalEntity] {
        guard let filter = filter else { return journals }

        var result = journals
        let calendar = Calendar.current

        // filterType별 필터링
        switch filter.filterType {
        case .daily:
            if let date = filter.date {
                result = result.filter {
                    calendar.isDate($0.tradeDate, inSameDayAs: date)
                }
            }
        case .monthly:
            if let year = filter.year, let month = filter.month {
                result = result.filter {
                    let components = calendar.dateComponents([.year, .month], from: $0.tradeDate)
                    return components.year == year && components.month == month
                }
            }
        case .yearly:
            if let year = filter.year {
                result = result.filter {
                    calendar.component(.year, from: $0.tradeDate) == year
                }
            }
        case .all:
            break
        }

        // stockName 필터링
        if let stockName = filter.stockName, !stockName.isEmpty {
            result = result.filter { $0.stockName == stockName }
        }

        return result
    }
}
