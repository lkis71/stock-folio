import XCTest
import CoreData
@testable import StockFolio

/// Core Data 통합 테스트
/// 실제 Core Data 스택을 사용하여 데이터 영속성 테스트
final class CoreDataIntegrationTests: XCTestCase {

    // MARK: - Properties
    private var persistenceController: PersistenceController!
    private var repository: CoreDataStockRepository!
    private var context: NSManagedObjectContext!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // 인메모리 Core Data 스택 사용 (테스트용)
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        repository = CoreDataStockRepository(context: context)
    }

    override func tearDown() {
        // 테스트 데이터 정리
        clearAllData()
        repository = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    private func clearAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "StockHolding")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        try? context.save()
    }

    // MARK: - CRUD Integration Tests

    func test_saveAndFetch_shouldPersistData() throws {
        // Given
        let stockName = "삼성전자"
        let amount = 1_000_000.0
        let stock = StockHoldingEntity(stockName: stockName, purchaseAmount: amount)

        // When
        try repository.save(stock)
        let fetchedStocks = repository.fetchAll()

        // Then
        XCTAssertEqual(fetchedStocks.count, 1)
        XCTAssertEqual(fetchedStocks.first?.stockName, stockName)
        XCTAssertEqual(fetchedStocks.first?.purchaseAmount, amount)
    }

    func test_saveMultiple_shouldPersistAllData() throws {
        // Given
        let stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000),
            StockHoldingEntity(stockName: "SK하이닉스", purchaseAmount: 2_000_000),
            StockHoldingEntity(stockName: "카카오", purchaseAmount: 3_000_000)
        ]

        // When
        for stock in stocks {
            try repository.save(stock)
        }
        let fetchedStocks = repository.fetchAll()

        // Then
        XCTAssertEqual(fetchedStocks.count, 3)
    }

    func test_update_shouldModifyExistingData() throws {
        // Given
        let stock = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000)
        try repository.save(stock)

        // When
        var updatedStock = repository.fetchAll().first!
        updatedStock.stockName = "SK하이닉스"
        updatedStock.purchaseAmount = 2_000_000
        try repository.update(updatedStock)

        let fetchedStocks = repository.fetchAll()

        // Then
        XCTAssertEqual(fetchedStocks.count, 1)
        XCTAssertEqual(fetchedStocks.first?.stockName, "SK하이닉스")
        XCTAssertEqual(fetchedStocks.first?.purchaseAmount, 2_000_000)
    }

    func test_delete_shouldRemoveData() throws {
        // Given
        let stock = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000)
        try repository.save(stock)
        XCTAssertEqual(repository.fetchAll().count, 1)

        // When
        let savedStock = repository.fetchAll().first!
        try repository.delete(savedStock)

        // Then
        XCTAssertEqual(repository.fetchAll().count, 0)
    }

    // MARK: - Data Integrity Tests

    func test_fetchAll_shouldReturnEmptyArray_whenNoData() {
        // Given: 데이터 없음

        // When
        let stocks = repository.fetchAll()

        // Then
        XCTAssertTrue(stocks.isEmpty)
    }

    func test_save_shouldPreserveUUID() throws {
        // Given
        let originalId = UUID()
        let stock = StockHoldingEntity(id: originalId, stockName: "삼성전자", purchaseAmount: 1_000_000)

        // When
        try repository.save(stock)
        let fetchedStock = repository.fetchAll().first

        // Then
        XCTAssertEqual(fetchedStock?.id, originalId)
    }

    func test_save_shouldPreserveCreatedDate() throws {
        // Given
        let stock = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000)
        let originalDate = stock.createdAt

        // When
        try repository.save(stock)
        let fetchedStock = repository.fetchAll().first

        // Then
        XCTAssertEqual(
            fetchedStock?.createdAt.timeIntervalSince1970 ?? 0,
            originalDate.timeIntervalSince1970,
            accuracy: 1.0
        )
    }

    // MARK: - Sequential Save Tests

    func test_sequentialSave_shouldSaveAllStocks() throws {
        // Given & When
        for i in 0..<10 {
            let stock = StockHoldingEntity(stockName: "종목\(i)", purchaseAmount: Double(i * 1_000_000))
            try repository.save(stock)
        }

        // Then
        let stocks = repository.fetchAll()
        XCTAssertEqual(stocks.count, 10)
    }

    // MARK: - Large Data Tests

    func test_saveAndFetch_withLargeDataset_shouldPerformWell() throws {
        // Given
        let stockCount = 100

        // When
        let saveStart = Date()
        for i in 0..<stockCount {
            let stock = StockHoldingEntity(stockName: "종목\(i)", purchaseAmount: Double(i * 10_000))
            try repository.save(stock)
        }
        let saveDuration = Date().timeIntervalSince(saveStart)

        let fetchStart = Date()
        let stocks = repository.fetchAll()
        let fetchDuration = Date().timeIntervalSince(fetchStart)

        // Then
        XCTAssertEqual(stocks.count, stockCount)
        // 저장은 5초 이내여야 함
        XCTAssertLessThan(saveDuration, 5.0, "Save took too long: \(saveDuration)s")
        // 조회는 1초 이내여야 함
        XCTAssertLessThan(fetchDuration, 1.0, "Fetch took too long: \(fetchDuration)s")
    }

    // MARK: - Edge Case Tests

    func test_save_withEmptyName_shouldStillSave() throws {
        // Given (빈 이름은 Validator에서 처리하지만, Repository는 저장만 담당)
        let stock = StockHoldingEntity(stockName: "", purchaseAmount: 1_000_000)

        // When
        try repository.save(stock)

        // Then
        let fetchedStocks = repository.fetchAll()
        XCTAssertEqual(fetchedStocks.count, 1)
        XCTAssertEqual(fetchedStocks.first?.stockName, "")
    }

    func test_save_withSpecialCharacters_shouldPersist() throws {
        // Given (특수문자는 Validator에서 걸러지지만 Repository 테스트)
        let stock = StockHoldingEntity(stockName: "Test 주식 (테스트)", purchaseAmount: 1_000_000)

        // When
        try repository.save(stock)

        // Then
        let fetchedStocks = repository.fetchAll()
        XCTAssertEqual(fetchedStocks.first?.stockName, "Test 주식 (테스트)")
    }

    func test_save_withUnicodeCharacters_shouldPersist() throws {
        // Given
        let stock = StockHoldingEntity(stockName: "삼성전자 🚀", purchaseAmount: 1_000_000)

        // When
        try repository.save(stock)

        // Then
        let fetchedStocks = repository.fetchAll()
        XCTAssertEqual(fetchedStocks.first?.stockName, "삼성전자 🚀")
    }
}
