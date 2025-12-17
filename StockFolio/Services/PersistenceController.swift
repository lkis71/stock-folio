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
                // 프로덕션 환경에서는 적절한 에러 처리 필요
                #if DEBUG
                fatalError("Core Data error: \(error), \(error.userInfo)")
                #else
                // 로그만 남기고 계속 진행 (앱 크래시 방지)
                NSLog("⚠️ Core Data load error: \(error.localizedDescription)")
                #endif
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
