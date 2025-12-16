import XCTest
@testable import StockFolio

/// PortfolioViewModel TDD 테스트
/// RED Phase: 이 테스트들은 구현이 없으므로 실패해야 합니다.
final class PortfolioViewModelTests: XCTestCase {

    // MARK: - Properties
    private var sut: PortfolioViewModel!
    private var mockRepository: MockStockRepository!
    private var mockSeedMoneyStorage: MockSeedMoneyStorage!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockRepository = MockStockRepository()
        mockSeedMoneyStorage = MockSeedMoneyStorage()
        sut = PortfolioViewModel(
            repository: mockRepository,
            seedMoneyStorage: mockSeedMoneyStorage
        )
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        mockSeedMoneyStorage = nil
        super.tearDown()
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

    // MARK: - Stock CRUD Tests

    func test_addStock_withValidInput_shouldSaveToRepository() {
        // Given
        let stockName = "삼성전자"
        let amount = 1_000_000.0

        // When
        sut.addStock(name: stockName, amount: amount)

        // Then
        XCTAssertEqual(mockRepository.saveCallCount, 1)
        XCTAssertEqual(mockRepository.stocks.count, 1)
        XCTAssertEqual(mockRepository.stocks.first?.stockName, stockName)
        XCTAssertEqual(mockRepository.stocks.first?.purchaseAmount, amount)
    }

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

    func test_deleteStock_shouldRemoveFromRepository() {
        // Given
        let stock = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000)
        mockRepository.stocks = [stock]
        sut.fetchHoldings()

        // When
        sut.deleteStock(stock)

        // Then
        XCTAssertEqual(mockRepository.deleteCallCount, 1)
        XCTAssertTrue(mockRepository.stocks.isEmpty)
    }

    func test_updateStock_shouldUpdateInRepository() {
        // Given
        var stock = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000)
        mockRepository.stocks = [stock]
        sut.fetchHoldings()

        // When
        sut.updateStock(stock, name: "SK하이닉스", amount: 2_000_000)

        // Then
        XCTAssertEqual(mockRepository.updateCallCount, 1)
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
}
