import Foundation
import CoreData

/// Core Data 기반 종목 저장소 (SRP - 데이터 영속성만 담당)
final class CoreDataStockRepository: StockRepositoryProtocol {

    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }

    func fetchAll() -> [StockHoldingEntity] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "StockHolding")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            let results = try viewContext.fetch(request)
            return results.compactMap { managedObject in
                guard let id = managedObject.value(forKey: "id") as? UUID,
                      let stockName = managedObject.value(forKey: "stockName") as? String,
                      let purchaseAmount = managedObject.value(forKey: "purchaseAmount") as? Double,
                      let createdAt = managedObject.value(forKey: "createdAt") as? Date else {
                    return nil
                }
                let colorName = managedObject.value(forKey: "colorName") as? String ?? "blue"
                return StockHoldingEntity(
                    id: id,
                    stockName: stockName,
                    purchaseAmount: purchaseAmount,
                    colorName: colorName,
                    createdAt: createdAt
                )
            }
        } catch {
            Logger.error("Fetch error: \(error.localizedDescription)")
            return []
        }
    }

    func save(_ stock: StockHoldingEntity) throws {
        let entity = NSEntityDescription.entity(forEntityName: "StockHolding", in: viewContext)!
        let managedObject = NSManagedObject(entity: entity, insertInto: viewContext)

        managedObject.setValue(stock.id, forKey: "id")
        managedObject.setValue(stock.stockName, forKey: "stockName")
        managedObject.setValue(stock.purchaseAmount, forKey: "purchaseAmount")
        managedObject.setValue(stock.colorName, forKey: "colorName")
        managedObject.setValue(stock.createdAt, forKey: "createdAt")

        try viewContext.save()
    }

    func update(_ stock: StockHoldingEntity) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "StockHolding")
        request.predicate = NSPredicate(format: "id == %@", stock.id as CVarArg)

        let results = try viewContext.fetch(request)
        guard let managedObject = results.first else {
            throw NSError(domain: "StockRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Stock not found"])
        }

        managedObject.setValue(stock.stockName, forKey: "stockName")
        managedObject.setValue(stock.purchaseAmount, forKey: "purchaseAmount")
        managedObject.setValue(stock.colorName, forKey: "colorName")

        try viewContext.save()
    }

    func delete(_ stock: StockHoldingEntity) throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "StockHolding")
        request.predicate = NSPredicate(format: "id == %@", stock.id as CVarArg)

        let results = try viewContext.fetch(request)
        guard let managedObject = results.first else {
            throw NSError(domain: "StockRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Stock not found"])
        }

        viewContext.delete(managedObject)
        try viewContext.save()
    }
}
