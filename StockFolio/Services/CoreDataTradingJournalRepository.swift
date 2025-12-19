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
}
