import XCTest
@testable import StockFolio

/// TradingJournal Filtering Tests (RED Phase - TDD)
/// Tests for date-based filtering functionality
/// These tests will fail initially and drive the implementation
final class TradingJournalFilteringTests: XCTestCase {

    // MARK: - Properties
    private var sut: TradingJournalViewModel!
    private var mockRepository: MockTradingJournalRepository!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        mockRepository = MockTradingJournalRepository()
        sut = TradingJournalViewModel(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Filter Type Tests

    func test_filterType_defaultValue_shouldBeAll() {
        // Given/When (initialization happens in setUp)

        // Then
        XCTAssertEqual(sut.filterType, .all, "Default filter type should be .all")
    }

    func test_setFilterType_shouldUpdateFilterType() {
        // Given
        let expectedFilterType = FilterType.daily

        // When
        sut.filterType = expectedFilterType

        // Then
        XCTAssertEqual(sut.filterType, expectedFilterType)
    }

    // MARK: - Daily Filter Tests

    func test_applyFilter_withDailyFilter_shouldFetchJournalsForSelectedDate() {
        // Given
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayJournal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: today,
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )

        let yesterdayJournal = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: yesterday,
            stockName: "SK하이닉스",
            quantity: 5,
            price: 120000
        )

        mockRepository.journals = [todayJournal, yesterdayJournal]
        sut.fetchJournals()

        // When
        sut.filterType = .daily
        sut.selectedDate = today
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 1, "Should only return journals from selected date")
        XCTAssertEqual(sut.journals.first?.stockName, "삼성전자")
    }

    func test_applyFilter_withDailyFilter_whenNoJournalsForDate_shouldReturnEmpty() {
        // Given
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .day, value: -10, to: Date())!
        let todayJournal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )

        mockRepository.journals = [todayJournal]
        sut.fetchJournals()

        // When
        sut.filterType = .daily
        sut.selectedDate = pastDate
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 0, "Should return empty when no journals for selected date")
    }

    // MARK: - Monthly Filter Tests

    func test_applyFilter_withMonthlyFilter_shouldFetchJournalsForSelectedMonth() {
        // Given
        let calendar = Calendar.current
        let december2024 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 1))!
        let november2024 = calendar.date(from: DateComponents(year: 2024, month: 11, day: 1))!

        let decemberJournal1 = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!,
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )

        let decemberJournal2 = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: calendar.date(from: DateComponents(year: 2024, month: 12, day: 20))!,
            stockName: "SK하이닉스",
            quantity: 5,
            price: 120000
        )

        let novemberJournal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: calendar.date(from: DateComponents(year: 2024, month: 11, day: 10))!,
            stockName: "LG전자",
            quantity: 15,
            price: 90000
        )

        mockRepository.journals = [decemberJournal1, decemberJournal2, novemberJournal]
        sut.fetchJournals()

        // When
        sut.filterType = .monthly
        sut.selectedMonth = december2024
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 2, "Should return 2 journals from December")
        XCTAssertTrue(sut.journals.contains(where: { $0.stockName == "삼성전자" }))
        XCTAssertTrue(sut.journals.contains(where: { $0.stockName == "SK하이닉스" }))
    }

    func test_applyFilter_withMonthlyFilter_whenNoJournalsForMonth_shouldReturnEmpty() {
        // Given
        let calendar = Calendar.current
        let january2024 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let decemberJournal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!,
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )

        mockRepository.journals = [decemberJournal]
        sut.fetchJournals()

        // When
        sut.filterType = .monthly
        sut.selectedMonth = january2024
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 0, "Should return empty when no journals for selected month")
    }

    // MARK: - Yearly Filter Tests

    func test_applyFilter_withYearlyFilter_shouldFetchJournalsForSelectedYear() {
        // Given
        let calendar = Calendar.current
        let date2024 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!
        let date2023 = calendar.date(from: DateComponents(year: 2023, month: 6, day: 10))!

        let journal2024_1 = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: date2024,
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )

        let journal2024_2 = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: calendar.date(from: DateComponents(year: 2024, month: 1, day: 5))!,
            stockName: "SK하이닉스",
            quantity: 5,
            price: 120000
        )

        let journal2023 = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: date2023,
            stockName: "LG전자",
            quantity: 15,
            price: 90000
        )

        mockRepository.journals = [journal2024_1, journal2024_2, journal2023]
        sut.fetchJournals()

        // When
        sut.filterType = .yearly
        sut.selectedYear = 2024
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 2, "Should return 2 journals from 2024")
        XCTAssertTrue(sut.journals.allSatisfy { calendar.component(.year, from: $0.tradeDate) == 2024 })
    }

    func test_applyFilter_withYearlyFilter_whenNoJournalsForYear_shouldReturnEmpty() {
        // Given
        let calendar = Calendar.current
        let date2024 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 15))!
        let journal2024 = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: date2024,
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )

        mockRepository.journals = [journal2024]
        sut.fetchJournals()

        // When
        sut.filterType = .yearly
        sut.selectedYear = 2023
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 0, "Should return empty when no journals for selected year")
    }

    // MARK: - All Filter Tests

    func test_applyFilter_withAllFilter_shouldFetchAllJournals() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 1, price: 1000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 2, price: 2000)
        let journal3 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "C", quantity: 3, price: 3000)

        mockRepository.journals = [journal1, journal2, journal3]
        sut.fetchJournals()

        // When
        sut.filterType = .all
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 3, "Should return all journals when filter is .all")
    }

    // MARK: - Statistics with Filter Tests

    func test_statistics_shouldReflectFilteredJournals() {
        // Given
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayBuy = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: today,
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )

        let todaySell = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: today,
            stockName: "SK하이닉스",
            quantity: 5,
            price: 120000
        )

        let yesterdayBuy = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: yesterday,
            stockName: "LG전자",
            quantity: 15,
            price: 90000
        )

        mockRepository.journals = [todayBuy, todaySell, yesterdayBuy]
        sut.fetchJournals()

        // When
        sut.filterType = .daily
        sut.selectedDate = today
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.totalTradeCount, 2, "Should count only filtered journals")
        XCTAssertEqual(sut.buyTradeCount, 1, "Should count only filtered buy trades")
        XCTAssertEqual(sut.sellTradeCount, 1, "Should count only filtered sell trades")
    }

    // MARK: - Repository Method Tests

    func test_repository_fetchByDate_shouldBeCalledWithCorrectDate() {
        // Given
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayJournal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: today,
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )

        mockRepository.journals = [todayJournal]

        // When
        sut.filterType = .daily
        sut.selectedDate = today
        sut.applyFilter()

        // Then
        XCTAssertGreaterThan(mockRepository.fetchByDateCallCount, 0, "Repository fetchByDate should be called")
    }

    func test_repository_fetchByMonth_shouldBeCalledWithCorrectYearAndMonth() {
        // Given
        let calendar = Calendar.current
        let december2024 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 1))!

        // When
        sut.filterType = .monthly
        sut.selectedMonth = december2024
        sut.applyFilter()

        // Then
        XCTAssertGreaterThan(mockRepository.fetchByMonthCallCount, 0, "Repository fetchByMonth should be called")
    }

    func test_repository_fetchByYear_shouldBeCalledWithCorrectYear() {
        // Given/When
        sut.filterType = .yearly
        sut.selectedYear = 2024
        sut.applyFilter()

        // Then
        XCTAssertGreaterThan(mockRepository.fetchByYearCallCount, 0, "Repository fetchByYear should be called")
    }
}
