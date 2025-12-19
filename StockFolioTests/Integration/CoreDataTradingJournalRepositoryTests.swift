import XCTest
import CoreData
@testable import StockFolio

/// CoreDataTradingJournalRepository Integration Tests
/// Tests actual Core Data CRUD operations for trading journal
final class CoreDataTradingJournalRepositoryTests: XCTestCase {

    // MARK: - Properties
    private var persistenceController: PersistenceController!
    private var repository: CoreDataTradingJournalRepository!
    private var context: NSManagedObjectContext!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Use in-memory Core Data stack for testing
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        repository = CoreDataTradingJournalRepository(context: context)
    }

    override func tearDown() {
        // Clean up test data
        clearAllData()
        repository = nil
        context = nil
        persistenceController = nil
        super.tearDown()
    }

    private func clearAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TradingJournal")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        try? context.save()
    }

    // MARK: - CRUD Integration Tests

    func test_save_shouldPersistJournal() throws {
        // Given
        let journal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0,
            reason: "기술적 매수 신호"
        )

        // When
        try repository.save(journal)
        let fetchedJournals = repository.fetchAll()

        // Then
        XCTAssertEqual(fetchedJournals.count, 1)
        XCTAssertEqual(fetchedJournals.first?.stockName, "삼성전자")
        XCTAssertEqual(fetchedJournals.first?.quantity, 10)
        XCTAssertEqual(fetchedJournals.first?.price, 70000.0)
        XCTAssertEqual(fetchedJournals.first?.reason, "기술적 매수 신호")
    }

    func test_fetchAll_shouldReturnEmptyArray_whenNoData() {
        // When
        let journals = repository.fetchAll()

        // Then
        XCTAssertTrue(journals.isEmpty)
    }

    func test_fetchAll_shouldReturnSortedByDateDescending() throws {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: twoDaysAgo, stockName: "A", quantity: 1, price: 1000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: today, stockName: "B", quantity: 2, price: 2000)
        let journal3 = TradingJournalEntity(tradeType: .buy, tradeDate: yesterday, stockName: "C", quantity: 3, price: 3000)

        // When
        try repository.save(journal1)
        try repository.save(journal2)
        try repository.save(journal3)

        let journals = repository.fetchAll()

        // Then
        XCTAssertEqual(journals.count, 3)
        XCTAssertEqual(journals[0].stockName, "B") // Most recent
        XCTAssertEqual(journals[1].stockName, "C")
        XCTAssertEqual(journals[2].stockName, "A") // Oldest
    }

    func test_fetch_withLimitAndOffset_shouldReturnCorrectJournals() throws {
        // Given
        for i in 0..<10 {
            let journal = TradingJournalEntity(
                tradeType: .buy,
                tradeDate: Date(timeIntervalSinceNow: TimeInterval(-i * 86400)),
                stockName: "Stock\(i)",
                quantity: i + 1,
                price: Double((i + 1) * 1000)
            )
            try repository.save(journal)
        }

        // When
        let firstPage = repository.fetch(limit: 3, offset: 0)
        let secondPage = repository.fetch(limit: 3, offset: 3)

        // Then
        XCTAssertEqual(firstPage.count, 3)
        XCTAssertEqual(secondPage.count, 3)
        XCTAssertEqual(firstPage[0].stockName, "Stock0")
        XCTAssertEqual(secondPage[0].stockName, "Stock3")
    }

    func test_update_shouldModifyExistingJournal() throws {
        // Given
        let journal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0
        )
        try repository.save(journal)

        // When
        var updatedJournal = repository.fetchAll().first!
        updatedJournal.stockName = "SK하이닉스"
        updatedJournal.quantity = 20
        updatedJournal.price = 120000.0
        updatedJournal.reason = "추가 매수"

        try repository.update(updatedJournal)
        let fetchedJournals = repository.fetchAll()

        // Then
        XCTAssertEqual(fetchedJournals.count, 1)
        XCTAssertEqual(fetchedJournals.first?.stockName, "SK하이닉스")
        XCTAssertEqual(fetchedJournals.first?.quantity, 20)
        XCTAssertEqual(fetchedJournals.first?.price, 120000.0)
        XCTAssertEqual(fetchedJournals.first?.reason, "추가 매수")
    }

    func test_update_nonExistentJournal_shouldThrowError() {
        // Given
        let journal = TradingJournalEntity(
            id: UUID(),
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0
        )

        // When/Then
        XCTAssertThrowsError(try repository.update(journal)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "TradingJournalRepository")
        }
    }

    func test_delete_shouldRemoveJournal() throws {
        // Given
        let journal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0
        )
        try repository.save(journal)
        XCTAssertEqual(repository.fetchAll().count, 1)

        // When
        let savedJournal = repository.fetchAll().first!
        try repository.delete(savedJournal)

        // Then
        XCTAssertEqual(repository.fetchAll().count, 0)
    }

    func test_delete_nonExistentJournal_shouldThrowError() {
        // Given
        let journal = TradingJournalEntity(
            id: UUID(),
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0
        )

        // When/Then
        XCTAssertThrowsError(try repository.delete(journal)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "TradingJournalRepository")
        }
    }

    // MARK: - Data Integrity Tests

    func test_save_shouldPreserveUUID() throws {
        // Given
        let originalId = UUID()
        let journal = TradingJournalEntity(
            id: originalId,
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0
        )

        // When
        try repository.save(journal)
        let fetchedJournal = repository.fetchAll().first

        // Then
        XCTAssertEqual(fetchedJournal?.id, originalId)
    }

    func test_save_shouldPreserveTradeType() throws {
        // Given
        let buyJournal = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 1, price: 1000)
        let sellJournal = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 2, price: 2000)

        // When
        try repository.save(buyJournal)
        try repository.save(sellJournal)
        let journals = repository.fetchAll()

        // Then
        XCTAssertEqual(journals.count, 2)
        let types = journals.map { $0.tradeType }
        XCTAssertTrue(types.contains(.buy))
        XCTAssertTrue(types.contains(.sell))
    }

    func test_save_shouldPreserveDates() throws {
        // Given
        let journal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0
        )
        let originalTradeDate = journal.tradeDate
        let originalCreatedAt = journal.createdAt

        // When
        try repository.save(journal)
        let fetchedJournal = repository.fetchAll().first

        // Then
        XCTAssertEqual(
            fetchedJournal?.tradeDate.timeIntervalSince1970 ?? 0,
            originalTradeDate.timeIntervalSince1970,
            accuracy: 1.0
        )
        XCTAssertEqual(
            fetchedJournal?.createdAt.timeIntervalSince1970 ?? 0,
            originalCreatedAt.timeIntervalSince1970,
            accuracy: 1.0
        )
    }

    // MARK: - Performance Tests

    func test_saveAndFetch_withLargeDataset_shouldPerformWell() throws {
        // Given
        let journalCount = 100

        // When
        let saveStart = Date()
        for i in 0..<journalCount {
            let journal = TradingJournalEntity(
                tradeType: i % 2 == 0 ? .buy : .sell,
                tradeDate: Date(timeIntervalSinceNow: TimeInterval(-i * 3600)),
                stockName: "Stock\(i)",
                quantity: i + 1,
                price: Double((i + 1) * 1000)
            )
            try repository.save(journal)
        }
        let saveDuration = Date().timeIntervalSince(saveStart)

        let fetchStart = Date()
        let journals = repository.fetchAll()
        let fetchDuration = Date().timeIntervalSince(fetchStart)

        // Then
        XCTAssertEqual(journals.count, journalCount)
        XCTAssertLessThan(saveDuration, 5.0, "Save took too long: \(saveDuration)s")
        XCTAssertLessThan(fetchDuration, 1.0, "Fetch took too long: \(fetchDuration)s")
    }

    // MARK: - Edge Case Tests

    func test_save_withEmptyReason_shouldPersist() throws {
        // Given
        let journal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0,
            reason: ""
        )

        // When
        try repository.save(journal)
        let fetchedJournal = repository.fetchAll().first

        // Then
        XCTAssertEqual(fetchedJournal?.reason, "")
    }

    func test_save_withZeroQuantity_shouldPersist() throws {
        // Given
        let journal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 0,
            price: 70000.0
        )

        // When
        try repository.save(journal)
        let fetchedJournal = repository.fetchAll().first

        // Then
        XCTAssertEqual(fetchedJournal?.quantity, 0)
    }

    func test_save_withLargePrice_shouldPersist() throws {
        // Given
        let journal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "버크셔해서웨이",
            quantity: 1,
            price: 500_000_000.0
        )

        // When
        try repository.save(journal)
        let fetchedJournal = repository.fetchAll().first

        // Then
        XCTAssertEqual(fetchedJournal?.price, 500_000_000.0)
    }
}
