import CoreData

/// Core Data 영속성 컨트롤러
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "StockFolio")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// 테스트용 인메모리 컨트롤러
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()
}
