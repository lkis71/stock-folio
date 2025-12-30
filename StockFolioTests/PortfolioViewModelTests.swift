import XCTest
@testable import StockFolio

/// PortfolioViewModel TDD 테스트
/// RED Phase: 이 테스트들은 구현이 없으므로 실패해야 합니다.
final class PortfolioViewModelTests: XCTestCase {

    // MARK: - Properties
    private var sut: PortfolioViewModel!
    private var mockRepository: MockStockRepository!
    private var mockSeedMoneyStorage: MockSeedMoneyStorage!
    private var mockSyncService: MockPortfolioSyncService!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockStockRepository()
        mockSeedMoneyStorage = MockSeedMoneyStorage()
        mockSyncService = MockPortfolioSyncService()
        sut = PortfolioViewModel(
            repository: mockRepository,
            seedMoneyStorage: mockSeedMoneyStorage,
            syncService: mockSyncService
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockSeedMoneyStorage = nil
        mockSyncService = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_shouldCallRecalculateAll() {
        // Given & When: ViewModel이 초기화됨 (setUp에서 이미 생성됨)

        // Then: recalculateAll이 호출되어야 함
        XCTAssertEqual(mockSyncService.recalculateAllCallCount, 1)
    }

    // MARK: - Seed Money Tests

    func test_loadSeedMoney_shouldReturnStoredValue() {
        // Given
        mockSeedMoneyStorage.savedSeedMoney = 100_000_000

        // When
        sut.loadSeedMoney()

        // Then
        XCTAssertEqual(sut.seedMoney, 100_000_000)
    }

    func test_saveSeedMoney_shouldUpdateStorageAndProperty() {
        // Given
        let newSeedMoney = 50_000_000.0

        // When
        sut.saveSeedMoney(newSeedMoney)

        // Then
        XCTAssertEqual(mockSeedMoneyStorage.savedSeedMoney, newSeedMoney)
        XCTAssertEqual(sut.seedMoney, newSeedMoney)
    }

    // MARK: - Fetch Holdings Tests
    // v3.0: CRUD 테스트 제거 (매매일지 기반 관리로 전환)

    func test_fetchHoldings_shouldUpdateHoldingsProperty() {
        // Given
        let stock1 = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000)
        let stock2 = StockHoldingEntity(stockName: "SK하이닉스", purchaseAmount: 2_000_000)
        mockRepository.stocks = [stock1, stock2]

        // When
        sut.fetchHoldings()

        // Then
        XCTAssertEqual(sut.holdings.count, 2)
    }

    // MARK: - Portfolio Calculation Tests

    func test_totalInvestedAmount_shouldSumAllHoldings() {
        // Given
        mockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000),
            StockHoldingEntity(stockName: "SK하이닉스", purchaseAmount: 2_000_000)
        ]
        sut.fetchHoldings()

        // When
        let total = sut.totalInvestedAmount

        // Then
        XCTAssertEqual(total, 3_000_000)
    }

    func test_remainingCash_shouldCalculateCorrectly() {
        // Given
        mockSeedMoneyStorage.savedSeedMoney = 10_000_000
        mockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 3_000_000)
        ]
        sut.loadSeedMoney()
        sut.fetchHoldings()

        // When
        let remaining = sut.remainingCash

        // Then
        XCTAssertEqual(remaining, 7_000_000)
    }

    func test_investedPercentage_shouldCalculateCorrectly() {
        // Given
        mockSeedMoneyStorage.savedSeedMoney = 10_000_000
        mockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 5_000_000)
        ]
        sut.loadSeedMoney()
        sut.fetchHoldings()

        // When
        let percentage = sut.investedPercentage

        // Then
        XCTAssertEqual(percentage, 50.0, accuracy: 0.01)
    }

    func test_investedPercentage_withZeroSeedMoney_shouldReturnZero() {
        // Given
        mockSeedMoneyStorage.savedSeedMoney = 0
        mockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 5_000_000)
        ]
        sut.loadSeedMoney()
        sut.fetchHoldings()

        // When
        let percentage = sut.investedPercentage

        // Then
        XCTAssertEqual(percentage, 0)
    }

    func test_percentageForHolding_shouldCalculateCorrectly() {
        // Given
        let stock1 = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 4_000_000)
        let stock2 = StockHoldingEntity(stockName: "SK하이닉스", purchaseAmount: 6_000_000)
        mockRepository.stocks = [stock1, stock2]
        sut.fetchHoldings()

        // When
        let percentage = sut.percentage(for: stock1)

        // Then
        XCTAssertEqual(percentage, 40.0, accuracy: 0.01)
    }

    // MARK: - Statistics Tests (for StatCard)

    func test_totalEvaluationAmount_withProfit_shouldCalculateCorrectly() {
        // Given
        mockSeedMoneyStorage.savedSeedMoney = 10_000_000
        mockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 3_000_000)
        ]
        sut.loadSeedMoney()
        sut.fetchHoldings()

        // Mock 수익 (실제로는 매매일지에서 계산, 현재는 평가액 = 투자금액)
        // TODO: 향후 실현/미실현 손익 기능 추가 시 업데이트

        // When
        let totalEvaluation = sut.totalEvaluationAmount

        // Then
        // 현재 v1: 평가액 = 투자금액 (손익 미반영)
        XCTAssertEqual(totalEvaluation, 3_000_000, accuracy: 0.01)
    }

    func test_totalProfitLoss_withNoTrades_shouldReturnZero() {
        // Given
        mockSeedMoneyStorage.savedSeedMoney = 10_000_000
        mockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 3_000_000)
        ]
        sut.loadSeedMoney()
        sut.fetchHoldings()

        // When
        let profitLoss = sut.totalProfitLoss

        // Then
        // v1: 손익 계산 기능 없음 (향후 매매일지 연동 필요)
        XCTAssertEqual(profitLoss, 0, accuracy: 0.01)
    }

    func test_totalReturnRate_withNoTrades_shouldReturnZero() {
        // Given
        mockSeedMoneyStorage.savedSeedMoney = 10_000_000
        mockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 3_000_000)
        ]
        sut.loadSeedMoney()
        sut.fetchHoldings()

        // When
        let returnRate = sut.totalReturnRate

        // Then
        // v1: 수익률 계산 기능 없음 (향후 매매일지 연동 필요)
        XCTAssertEqual(returnRate, 0, accuracy: 0.01)
    }

    func test_totalReturnRate_withZeroInvestedAmount_shouldReturnZero() {
        // Given
        mockSeedMoneyStorage.savedSeedMoney = 10_000_000
        mockRepository.stocks = []
        sut.loadSeedMoney()
        sut.fetchHoldings()

        // When
        let returnRate = sut.totalReturnRate

        // Then
        XCTAssertEqual(returnRate, 0)
    }
}
