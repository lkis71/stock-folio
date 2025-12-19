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
}
