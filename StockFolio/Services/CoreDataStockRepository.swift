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

    // MARK: - Pagination & Statistics

    func fetch(pagination: PaginationRequest) -> PaginationResult<StockHoldingEntity> {
        // 1. totalCount 조회
        let totalCount = fetchTotalCount()

        // 2. 페이징 데이터 조회
        let request = NSFetchRequest<NSManagedObject>(entityName: "StockHolding")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = pagination.limit
        request.fetchOffset = pagination.offset

        do {
            let results = try viewContext.fetch(request)
            let items = results.compactMap { managedObject -> StockHoldingEntity? in
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

            let hasMore = pagination.offset + pagination.limit < totalCount
            return PaginationResult(items: items, totalCount: totalCount, hasMore: hasMore)
        } catch {
            Logger.error("Fetch with pagination error: \(error.localizedDescription)")
            return PaginationResult(items: [], totalCount: 0, hasMore: false)
        }
    }

    func fetchTotalCount() -> Int {
        let request = NSFetchRequest<NSNumber>(entityName: "StockHolding")
        request.resultType = .countResultType

        do {
            let result = try viewContext.fetch(request)
            return result.first?.intValue ?? 0
        } catch {
            Logger.error("Count error: \(error.localizedDescription)")
            return 0
        }
    }

    func fetchTotalInvestedAmount() -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "StockHolding")

        let sumExpression = NSExpression(forKeyPath: "purchaseAmount")
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
}
