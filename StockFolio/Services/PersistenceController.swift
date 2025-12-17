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
                // 임시: 에러가 있어도 계속 진행 (디버깅용)
                print("⚠️ Core Data load error: \(error.localizedDescription)")
                print("⚠️ 앱은 계속 실행되지만 데이터 저장이 안 될 수 있습니다")
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
