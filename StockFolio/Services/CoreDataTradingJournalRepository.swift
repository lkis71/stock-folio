import Foundation
import CoreData

final class CoreDataTradingJournalRepository: TradingJournalRepositoryProtocol {

    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }

    func fetchAll() -> [TradingJournalEntity] {
        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        request.sortDescriptors = [NSSortDescriptor(key: "tradeDate", ascending: false)]

        do {
            let results = try viewContext.fetch(request)
            return results.map { TradingJournalEntity(from: $0) }
        } catch {
            Logger.error("Fetch all trading journals error: \(error.localizedDescription)")
            return []
        }
    }

    func fetch(limit: Int, offset: Int) -> [TradingJournalEntity] {
        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        request.sortDescriptors = [NSSortDescriptor(key: "tradeDate", ascending: false)]
        request.fetchLimit = limit
        request.fetchOffset = offset

        do {
            let results = try viewContext.fetch(request)
            return results.map { TradingJournalEntity(from: $0) }
        } catch {
            Logger.error("Fetch trading journals error: \(error.localizedDescription)")
            return []
        }
    }

    func save(_ journal: TradingJournalEntity) throws {
        let entity = NSEntityDescription.entity(forEntityName: "TradingJournal", in: viewContext)!
        let managedObject = TradingJournalMO(entity: entity, insertInto: viewContext)

        managedObject.id = journal.id
        managedObject.tradeType = journal.tradeType.rawValue
        managedObject.tradeDate = journal.tradeDate
        managedObject.stockName = journal.stockName
        managedObject.quantity = Int32(journal.quantity)
        managedObject.price = journal.price
        managedObject.realizedProfit = journal.realizedProfit
        managedObject.reason = journal.reason
        managedObject.createdAt = journal.createdAt
        managedObject.updatedAt = journal.updatedAt

        try viewContext.save()
    }

    func update(_ journal: TradingJournalEntity) throws {
        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        request.predicate = NSPredicate(format: "id == %@", journal.id as CVarArg)

        let results = try viewContext.fetch(request)
        guard let managedObject = results.first else {
            throw NSError(domain: "TradingJournalRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Trading journal not found"])
        }

        managedObject.tradeType = journal.tradeType.rawValue
        managedObject.tradeDate = journal.tradeDate
        managedObject.stockName = journal.stockName
        managedObject.quantity = Int32(journal.quantity)
        managedObject.price = journal.price
        managedObject.realizedProfit = journal.realizedProfit
        managedObject.reason = journal.reason
        managedObject.updatedAt = Date()

        try viewContext.save()
    }

    func delete(_ journal: TradingJournalEntity) throws {
        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        request.predicate = NSPredicate(format: "id == %@", journal.id as CVarArg)

        let results = try viewContext.fetch(request)
        guard let managedObject = results.first else {
            throw NSError(domain: "TradingJournalRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Trading journal not found"])
        }

        viewContext.delete(managedObject)
        try viewContext.save()
    }

    func fetchByDate(_ date: Date) -> [TradingJournalEntity] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        request.predicate = NSPredicate(format: "tradeDate >= %@ AND tradeDate < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "tradeDate", ascending: false)]

        do {
            let results = try viewContext.fetch(request)
            return results.map { TradingJournalEntity(from: $0) }
        } catch {
            Logger.error("Fetch by date error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchByMonth(year: Int, month: Int) -> [TradingJournalEntity] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) else {
            return []
        }

        guard let endOfMonth = calendar.date(byAdding: .day, value: 1, to: endDate) else {
            return []
        }

        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        request.predicate = NSPredicate(format: "tradeDate >= %@ AND tradeDate < %@", startDate as NSDate, endOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "tradeDate", ascending: false)]

        do {
            let results = try viewContext.fetch(request)
            return results.map { TradingJournalEntity(from: $0) }
        } catch {
            Logger.error("Fetch by month error: \(error.localizedDescription)")
            return []
        }
    }

    func fetchByYear(_ year: Int) -> [TradingJournalEntity] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endDate = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) else {
            return []
        }

        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        request.predicate = NSPredicate(format: "tradeDate >= %@ AND tradeDate < %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "tradeDate", ascending: false)]

        do {
            let results = try viewContext.fetch(request)
            return results.map { TradingJournalEntity(from: $0) }
        } catch {
            Logger.error("Fetch by year error: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Pagination & Statistics

    func fetch(pagination: PaginationRequest, filter: TradingJournalFilter?) -> PaginationResult<TradingJournalEntity> {
        // 1. totalCount 조회
        let totalCount = fetchCount(predicate: filter?.toPredicate())

        // 2. 페이징 데이터 조회
        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        request.predicate = filter?.toPredicate()
        request.sortDescriptors = [NSSortDescriptor(key: "tradeDate", ascending: false)]
        request.fetchLimit = pagination.limit
        request.fetchOffset = pagination.offset

        do {
            let results = try viewContext.fetch(request)
            let items = results.map { TradingJournalEntity(from: $0) }
            let hasMore = pagination.offset + pagination.limit < totalCount

            return PaginationResult(items: items, totalCount: totalCount, hasMore: hasMore)
        } catch {
            Logger.error("Fetch with pagination error: \(error.localizedDescription)")
            return PaginationResult(items: [], totalCount: 0, hasMore: false)
        }
    }

    func fetchStatistics(filter: TradingJournalFilter?) -> TradingJournalStatistics {
        let basePredicate = filter?.toPredicate()

        // 전체 count
        let totalCount = fetchCount(predicate: basePredicate)

        // 매수 count
        let buyPredicate = NSPredicate(format: "tradeType == %@", "매수")
        let buyCount = fetchCount(predicate: combinePredicates([basePredicate, buyPredicate]))

        // 매도 count
        let sellPredicate = NSPredicate(format: "tradeType == %@", "매도")
        let sellCount = fetchCount(predicate: combinePredicates([basePredicate, sellPredicate]))

        // 매도의 realizedProfit 합계
        let totalRealizedProfit = fetchSum(
            attribute: "realizedProfit",
            predicate: combinePredicates([basePredicate, sellPredicate])
        )

        // totalSellAmount 계산 (price * quantity의 합계)
        let sellJournals = fetchSellJournalsForStatistics(predicate: basePredicate)
        let totalSellAmount = sellJournals.reduce(0) { $0 + $1.totalAmount }

        return TradingJournalStatistics(
            totalCount: totalCount,
            buyCount: buyCount,
            sellCount: sellCount,
            totalRealizedProfit: totalRealizedProfit,
            totalSellAmount: totalSellAmount,
            winRate: 0 // fetchWinRate에서 별도 계산
        )
    }

    func fetchWinRate(filter: TradingJournalFilter?) -> Double {
        let sellJournals = fetchSellJournalsForStatistics(predicate: filter?.toPredicate())
        guard !sellJournals.isEmpty else { return 0 }

        let winCount = sellJournals.filter { $0.realizedProfit > 0 }.count
        return (Double(winCount) / Double(sellJournals.count)) * 100
    }

    // MARK: - Helper Methods

    private func fetchCount(predicate: NSPredicate?) -> Int {
        let request = NSFetchRequest<NSNumber>(entityName: "TradingJournal")
        request.predicate = predicate
        request.resultType = .countResultType

        do {
            let result = try viewContext.fetch(request)
            return result.first?.intValue ?? 0
        } catch {
            Logger.error("Count error: \(error.localizedDescription)")
            return 0
        }
    }

    private func fetchSum(attribute: String, predicate: NSPredicate?) -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "TradingJournal")
        request.predicate = predicate

        let sumExpression = NSExpression(forKeyPath: attribute)
        let sumDesc = NSExpressionDescription()
        sumDesc.name = "sum"
        sumDesc.expression = NSExpression(forFunction: "sum:", arguments: [sumExpression])
        sumDesc.expressionResultType = .doubleAttributeType

        request.propertiesToFetch = [sumDesc]
        request.resultType = .dictionaryResultType

        do {
            let results = try viewContext.fetch(request)
            return results.first?["sum"] as? Double ?? 0
        } catch {
            Logger.error("Sum error: \(error.localizedDescription)")
            return 0
        }
    }

    private func fetchSellJournalsForStatistics(predicate: NSPredicate?) -> [TradingJournalEntity] {
        let request = NSFetchRequest<TradingJournalMO>(entityName: "TradingJournal")
        let sellPredicate = NSPredicate(format: "tradeType == %@", "매도")

        request.predicate = combinePredicates([predicate, sellPredicate])
        request.propertiesToFetch = ["quantity", "price", "realizedProfit"]

        do {
            let results = try viewContext.fetch(request)
            return results.map { TradingJournalEntity(from: $0) }
        } catch {
            Logger.error("Fetch sell journals error: \(error.localizedDescription)")
            return []
        }
    }

    private func combinePredicates(_ predicates: [NSPredicate?]) -> NSPredicate? {
        let nonNilPredicates = predicates.compactMap { $0 }
        guard !nonNilPredicates.isEmpty else { return nil }

        if nonNilPredicates.count == 1 {
            return nonNilPredicates.first
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: nonNilPredicates)
    }
}
