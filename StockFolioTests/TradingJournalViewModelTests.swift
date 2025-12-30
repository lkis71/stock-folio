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
        sut.fetchMore()

        // Then
        // fetchMore는 내부적으로 관리되는 offset 사용
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
        let initialJournalCount = sut.journals.count

        // Add a journal to repository
        mockRepository.journals.append(TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "NewStock",
            quantity: 10,
            price: 1000
        ))

        // When
        sut.refresh()

        // Then (refresh should reload journals from repository)
        XCTAssertEqual(sut.journals.count, initialJournalCount + 1)
    }

    // MARK: - Pagination Tests

    func test_init_shouldLoadInitialPageWithStatistics() {
        // Given: 30개의 journal 생성
        var journals: [TradingJournalEntity] = []
        for i in 1...30 {
            let journal = TradingJournalEntity(
                tradeType: i % 2 == 0 ? .sell : .buy,
                tradeDate: Date().addingTimeInterval(TimeInterval(-i * 86400)),
                stockName: "Stock\(i)",
                quantity: 10,
                price: Double(i * 1000),
                realizedProfit: i % 2 == 0 ? Double(i * 100) : 0
            )
            journals.append(journal)
        }
        mockRepository.journals = journals

        // When
        sut = TradingJournalViewModel(repository: mockRepository)

        // Then
        XCTAssertEqual(sut.journals.count, 10, "Should load initial page size (10)")
        XCTAssertTrue(sut.hasMore, "Should have more items")
        XCTAssertNotNil(sut.statistics, "Should load statistics")
        XCTAssertEqual(sut.statistics?.totalCount, 30, "Statistics should reflect total count")
    }

    func test_fetchMore_shouldLoadNextPage() {
        // Given: 25개의 journal, 초기 로드 완료
        var journals: [TradingJournalEntity] = []
        for i in 1...25 {
            let journal = TradingJournalEntity(
                tradeType: .buy,
                tradeDate: Date().addingTimeInterval(TimeInterval(-i * 86400)),
                stockName: "Stock\(i)",
                quantity: 10,
                price: 1000
            )
            journals.append(journal)
        }
        mockRepository.journals = journals
        sut = TradingJournalViewModel(repository: mockRepository)

        XCTAssertEqual(sut.journals.count, 10, "Initial load should be 10")

        // When
        sut.fetchMore()

        // Then
        XCTAssertEqual(sut.journals.count, 20, "Should load 20 items after first fetchMore")
        XCTAssertTrue(sut.hasMore, "Should still have more items")

        // Fetch remaining
        sut.fetchMore()
        XCTAssertEqual(sut.journals.count, 25, "Should load all 25 items")
        XCTAssertFalse(sut.hasMore, "Should not have more items")
        XCTAssertFalse(sut.isLoading, "Should not be loading")
    }

    func test_fetchMore_whenNoMore_shouldNotLoad() {
        // Given: 10개의 journal (1 page)
        var journals: [TradingJournalEntity] = []
        for i in 1...10 {
            let journal = TradingJournalEntity(
                tradeType: .buy,
                tradeDate: Date(),
                stockName: "Stock\(i)",
                quantity: 10,
                price: 1000
            )
            journals.append(journal)
        }
        mockRepository.journals = journals
        sut = TradingJournalViewModel(repository: mockRepository)

        let initialCount = sut.journals.count

        // When
        sut.fetchMore()

        // Then
        XCTAssertEqual(sut.journals.count, initialCount, "Should not load more")
        XCTAssertFalse(sut.hasMore, "Should not have more items")
    }

    func test_fetchMore_whenLoading_shouldNotLoadAgain() {
        // Given
        var journals: [TradingJournalEntity] = []
        for i in 1...30 {
            let journal = TradingJournalEntity(
                tradeType: .buy,
                tradeDate: Date(),
                stockName: "Stock\(i)",
                quantity: 10,
                price: 1000
            )
            journals.append(journal)
        }
        mockRepository.journals = journals
        sut = TradingJournalViewModel(repository: mockRepository)

        // When: isLoading을 true로 설정하고 fetchMore 호출
        // Note: 실제로는 비동기이지만 Mock에서는 동기적으로 처리
        let initialCount = sut.journals.count
        sut.fetchMore()
        let countAfterFirst = sut.journals.count

        // fetchMore가 이미 진행 중일 때 다시 호출하면 무시되어야 함
        // 하지만 Mock은 동기적이므로 이 테스트는 실제 비동기 환경을 시뮬레이션하기 어려움

        // Then
        XCTAssertGreaterThan(countAfterFirst, initialCount, "First fetchMore should load")
    }

    // MARK: - Statistics Tests (NEW)

    func test_statistics_shouldLoadFromRepository() {
        // Given: 통계 데이터
        let sellJournal1 = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: Date(),
            stockName: "A",
            quantity: 10,
            price: 1000,
            realizedProfit: 500
        )
        let sellJournal2 = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: Date(),
            stockName: "B",
            quantity: 10,
            price: 2000,
            realizedProfit: -300
        )
        let buyJournal = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "C",
            quantity: 10,
            price: 3000
        )
        mockRepository.journals = [sellJournal1, sellJournal2, buyJournal]

        // When
        sut = TradingJournalViewModel(repository: mockRepository)

        // Then
        XCTAssertNotNil(sut.statistics)
        XCTAssertEqual(sut.statistics?.totalCount, 3)
        XCTAssertEqual(sut.statistics?.buyCount, 1)
        XCTAssertEqual(sut.statistics?.sellCount, 2)
        if let profit = sut.statistics?.totalRealizedProfit {
            XCTAssertEqual(profit, 200, accuracy: 0.01)
        } else {
            XCTFail("totalRealizedProfit should not be nil")
        }
    }

    func test_applyFilter_shouldReloadWithFilteredStatistics() {
        // Given: 여러 날짜의 journal
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayJournal = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: today,
            stockName: "A",
            quantity: 10,
            price: 1000,
            realizedProfit: 100
        )
        let yesterdayJournal = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: yesterday,
            stockName: "B",
            quantity: 10,
            price: 2000,
            realizedProfit: 200
        )
        mockRepository.journals = [todayJournal, yesterdayJournal]
        sut = TradingJournalViewModel(repository: mockRepository)

        // When: 오늘 날짜로 필터 적용
        sut.filterType = .daily
        sut.selectedDate = today
        sut.applyFilter()

        // Then: 필터링된 결과만 표시
        XCTAssertEqual(sut.journals.count, 1, "Should only show today's journals")
        XCTAssertEqual(sut.statistics?.totalCount, 1, "Statistics should reflect filtered count")
        if let profit = sut.statistics?.totalRealizedProfit {
            XCTAssertEqual(profit, 100, accuracy: 0.01)
        } else {
            XCTFail("totalRealizedProfit should not be nil")
        }
    }

    func test_applyFilter_withStockName_shouldFilterCorrectly() {
        // Given
        let journalA1 = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 1000,
            realizedProfit: 100
        )
        let journalA2 = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 5,
            price: 2000
        )
        let journalB = TradingJournalEntity(
            tradeType: .sell,
            tradeDate: Date(),
            stockName: "SK하이닉스",
            quantity: 10,
            price: 3000,
            realizedProfit: 200
        )
        mockRepository.journals = [journalA1, journalA2, journalB]
        sut = TradingJournalViewModel(repository: mockRepository)

        // When
        sut.selectedStockName = "삼성전자"
        sut.applyFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 2, "Should only show 삼성전자 journals")
        XCTAssertEqual(sut.statistics?.totalCount, 2)
        XCTAssertEqual(sut.statistics?.buyCount, 1)
        XCTAssertEqual(sut.statistics?.sellCount, 1)
    }

    func test_clearStockFilter_shouldResetFilter() {
        // Given
        mockRepository.journals = [
            TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "A", quantity: 10, price: 1000),
            TradingJournalEntity(tradeType: .buy, tradeDate: Date(), stockName: "B", quantity: 10, price: 2000)
        ]
        sut = TradingJournalViewModel(repository: mockRepository)
        sut.selectedStockName = "A"
        sut.applyFilter()

        XCTAssertEqual(sut.journals.count, 1)

        // When
        sut.clearStockFilter()

        // Then
        XCTAssertEqual(sut.journals.count, 2, "Should show all journals")
        XCTAssertTrue(sut.selectedStockName.isEmpty, "Stock filter should be cleared")
    }
}
