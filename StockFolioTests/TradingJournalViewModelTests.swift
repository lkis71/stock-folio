import XCTest
@testable import StockFolio

/// TradingJournalViewModel Tests
/// Following TDD Red-Green-Refactor cycle
/// Focus on statistics calculation logic (win rate, realized profit)
final class TradingJournalViewModelTests: XCTestCase {

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

    // MARK: - Initialization Tests

    func test_init_shouldFetchJournalsFromRepository() {
        // Given/When (initialization happens in setUp)

        // Then
        XCTAssertEqual(mockRepository.fetchAllCallCount, 1)
    }

    // MARK: - Fetch Tests

    func test_fetchJournals_shouldUpdateJournalsProperty() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "삼성전자", quantity: 10, price: 70000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "SK하이닉스", quantity: 5, price: 120000)
        mockRepository.journals = [journal1, journal2]

        // When
        sut.fetchJournals()

        // Then
        XCTAssertEqual(sut.journals.count, 2)
    }

    func test_fetchMore_shouldAppendJournals() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 1, price: 1000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 2, price: 2000)
        mockRepository.journals = [journal1, journal2]
        sut.fetchJournals()

        let journal3 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "C", quantity: 3, price: 3000)
        mockRepository.journals.append(journal3)

        // When
        sut.fetchMore(offset: 2)

        // Then
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
    }

    // MARK: - Add Journal Tests

    func test_addJournal_shouldSaveToRepository() {
        // Given
        let tradeType = TradeType.buy
        let tradeDate = Date()
        let stockName = "삼성전자"
        let quantity = 10
        let price = 70000.0
        let reason = "기술적 매수 신호"

        // When
        sut.addJournal(
            tradeType: tradeType,
            tradeDate: tradeDate,
            stockName: stockName,
            quantity: quantity,
            price: price,
            reason: reason
        )

        // Then
        XCTAssertEqual(mockRepository.saveCallCount, 1)
        XCTAssertEqual(mockRepository.journals.count, 1)
        XCTAssertEqual(mockRepository.journals.first?.stockName, stockName)
    }

    func test_addJournal_shouldRefetchJournals() {
        // Given
        let initialCallCount = mockRepository.fetchAllCallCount

        // When
        sut.addJournal(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0,
            reason: ""
        )

        // Then
        XCTAssertEqual(mockRepository.fetchAllCallCount, initialCallCount + 1)
    }

    // MARK: - Update Journal Tests

    func test_updateJournal_shouldUpdateInRepository() throws {
        // Given
        let journal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000
        )
        try mockRepository.save(journal)
        sut.fetchJournals()

        // When
        sut.updateJournal(
            journal,
            tradeType: .sell,
            tradeDate: Date(),
            stockName: "SK하이닉스",
            quantity: 20,
            price: 120000,
            reason: "익절"
        )

        // Then
        XCTAssertEqual(mockRepository.updateCallCount, 1)
    }

    func test_updateJournal_shouldRefetchJournals() throws {
        // Given
        let journal = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "삼성전자", quantity: 10, price: 70000)
        try mockRepository.save(journal)
        sut.fetchJournals()
        let initialCallCount = mockRepository.fetchAllCallCount

        // When
        sut.updateJournal(journal, tradeType: .sell, tradeDate: Date(), stockName: "SK하이닉스", quantity: 20, price: 120000, reason: "")

        // Then
        XCTAssertEqual(mockRepository.fetchAllCallCount, initialCallCount + 1)
    }

    // MARK: - Delete Journal Tests

    func test_deleteJournal_shouldDeleteFromRepository() throws {
        // Given
        let journal = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "삼성전자", quantity: 10, price: 70000)
        try mockRepository.save(journal)
        sut.fetchJournals()

        // When
        sut.deleteJournal(journal)

        // Then
        XCTAssertEqual(mockRepository.deleteCallCount, 1)
    }

    func test_deleteJournals_atOffsets_shouldDeleteMultipleJournals() throws {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 1, price: 1000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 2, price: 2000)
        let journal3 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "C", quantity: 3, price: 3000)

        try mockRepository.save(journal1)
        try mockRepository.save(journal2)
        try mockRepository.save(journal3)
        sut.fetchJournals()

        // When
        let offsets = IndexSet([0, 2])
        sut.deleteJournals(at: offsets)

        // Then
        XCTAssertEqual(mockRepository.deleteCallCount, 2)
    }

    // MARK: - Statistics Tests - Trade Count

    func test_totalTradeCount_withEmptyJournals_shouldReturnZero() {
        // Given
        mockRepository.journals = []
        sut.fetchJournals()

        // When
        let count = sut.totalTradeCount

        // Then
        XCTAssertEqual(count, 0)
    }

    func test_totalTradeCount_shouldReturnCorrectCount() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 1, price: 1000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 2, price: 2000)
        let journal3 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "C", quantity: 3, price: 3000)
        mockRepository.journals = [journal1, journal2, journal3]
        sut.fetchJournals()

        // When
        let count = sut.totalTradeCount

        // Then
        XCTAssertEqual(count, 3)
    }

    func test_buyTradeCount_shouldReturnOnlyBuyTrades() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 1, price: 1000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 2, price: 2000)
        let journal3 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "C", quantity: 3, price: 3000)
        mockRepository.journals = [journal1, journal2, journal3]
        sut.fetchJournals()

        // When
        let count = sut.buyTradeCount

        // Then
        XCTAssertEqual(count, 2)
    }

    func test_sellTradeCount_shouldReturnOnlySellTrades() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 1, price: 1000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 2, price: 2000)
        let journal3 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "C", quantity: 3, price: 3000)
        mockRepository.journals = [journal1, journal2, journal3]
        sut.fetchJournals()

        // When
        let count = sut.sellTradeCount

        // Then
        XCTAssertEqual(count, 2)
    }

    // MARK: - Statistics Tests - Realized Profit

    func test_totalRealizedProfit_withNoSells_shouldReturnZero() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 10, price: 70000)
        let journal2 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "B", quantity: 5, price: 120000)
        mockRepository.journals = [journal1, journal2]
        sut.fetchJournals()

        // When
        let profit = sut.totalRealizedProfit

        // Then
        XCTAssertEqual(profit, 0)
    }

    func test_totalRealizedProfit_shouldSumAllSellAmounts() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 10, price: 70000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 5, price: 120000, realizedProfit: 600000)
        let journal3 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "C", quantity: 10, price: 50000, realizedProfit: 500000)
        mockRepository.journals = [journal1, journal2, journal3]
        sut.fetchJournals()

        // When
        let profit = sut.totalRealizedProfit

        // Then
        // 600000 + 500000 = 1100000
        XCTAssertEqual(profit, 1_100_000, accuracy: 0.01)
    }

    func test_totalRealizedProfit_withMixedTrades_shouldOnlyCountSells() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 100, price: 1000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 10, price: 2000, realizedProfit: 20000)
        let journal3 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "C", quantity: 50, price: 3000)
        let journal4 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "D", quantity: 5, price: 4000, realizedProfit: 20000)
        mockRepository.journals = [journal1, journal2, journal3, journal4]
        sut.fetchJournals()

        // When
        let profit = sut.totalRealizedProfit

        // Then
        // 20000 + 20000 = 40000
        XCTAssertEqual(profit, 40_000, accuracy: 0.01)
    }

    // MARK: - Statistics Tests - Win Rate

    func test_winRate_withNoSells_shouldReturnZero() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 10, price: 70000)
        let journal2 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "B", quantity: 5, price: 120000)
        mockRepository.journals = [journal1, journal2]
        sut.fetchJournals()

        // When
        let winRate = sut.winRate

        // Then
        XCTAssertEqual(winRate, 0)
    }

    func test_winRate_withAllPositiveSells_shouldReturn100() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "A", quantity: 10, price: 70000, realizedProfit: 100000)
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 5, price: 120000, realizedProfit: 50000)
        mockRepository.journals = [journal1, journal2]
        sut.fetchJournals()

        // When
        let winRate = sut.winRate

        // Then
        XCTAssertEqual(winRate, 100.0, accuracy: 0.01)
    }

    func test_winRate_shouldCalculateCorrectPercentage() {
        // Given
        // Win: positive realizedProfit
        let journal1 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "A", quantity: 10, price: 70000, realizedProfit: 100000) // Win
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 5, price: 120000, realizedProfit: 50000) // Win
        let journal3 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "C", quantity: 10, price: 50000, realizedProfit: -30000) // Loss
        let journal4 = TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "D", quantity: 10, price: 30000) // Ignored (buy)
        mockRepository.journals = [journal1, journal2, journal3, journal4]
        sut.fetchJournals()

        // When
        let winRate = sut.winRate

        // Then
        // Total sells: 3 (A, B, C)
        // Wins: 2 (A, B have positive realizedProfit)
        // Win rate: (2/3) * 100 = 66.67%
        XCTAssertEqual(winRate, 66.67, accuracy: 0.01)
    }

    func test_winRate_withMixedResults_shouldCalculateCorrectly() {
        // Given
        let journal1 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "A", quantity: 10, price: 70000, realizedProfit: 100000) // Win
        let journal2 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "B", quantity: 5, price: 120000, realizedProfit: -50000) // Loss
        let journal3 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "C", quantity: 5, price: 50000, realizedProfit: 30000) // Win
        let journal4 = TradingJournalEntity(tradeType: .sell, tradeDate: Date(), stockName: "D", quantity: 10, price: 30000, realizedProfit: -20000) // Loss
        mockRepository.journals = [journal1, journal2, journal3, journal4]
        sut.fetchJournals()

        // When
        let winRate = sut.winRate

        // Then
        // Total sells: 4
        // Wins: 2 (A, C)
        // Win rate: (2/4) * 100 = 50%
        XCTAssertEqual(winRate, 50.0, accuracy: 0.01)
    }

    // MARK: - Refresh Tests

    func test_refresh_shouldFetchJournalsAgain() {
        // Given
        let initialCallCount = mockRepository.fetchAllCallCount

        // When
        sut.refresh()

        // Then
        XCTAssertEqual(mockRepository.fetchAllCallCount, initialCallCount + 1)
    }
}
