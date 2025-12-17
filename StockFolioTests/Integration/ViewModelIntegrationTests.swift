import XCTest
import CoreData
@testable import StockFolio

/// ViewModel + Repository 통합 테스트
/// 실제 Core Data를 사용한 End-to-End 테스트
final class ViewModelIntegrationTests: XCTestCase {

    // MARK: - Properties
    private var persistenceController: PersistenceController!
    private var repository: CoreDataStockRepository!
    private var seedMoneyStorage: SeedMoneyStorage!
    private var viewModel: PortfolioViewModel!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        let context = persistenceController.container.viewContext
        repository = CoreDataStockRepository(context: context)
        seedMoneyStorage = SeedMoneyStorage(defaults: UserDefaults(suiteName: "test")!)
        viewModel = PortfolioViewModel(
            repository: repository,
            seedMoneyStorage: seedMoneyStorage
        )
    }

    override func tearDown() {
        // UserDefaults 정리
        UserDefaults(suiteName: "test")?.removePersistentDomain(forName: "test")
        viewModel = nil
        seedMoneyStorage = nil
        repository = nil
        persistenceController = nil
        super.tearDown()
    }

    // MARK: - Full Flow Tests

    func test_fullAddStockFlow_shouldUpdateAllCalculations() {
        // Given
        viewModel.saveSeedMoney(10_000_000)

        // When: 종목 추가
        viewModel.addStock(name: "삼성전자", amount: 3_000_000)
        viewModel.addStock(name: "SK하이닉스", amount: 2_000_000)

        // Then
        XCTAssertEqual(viewModel.holdings.count, 2)
        XCTAssertEqual(viewModel.totalInvestedAmount, 5_000_000)
        XCTAssertEqual(viewModel.remainingCash, 5_000_000)
        XCTAssertEqual(viewModel.investedPercentage, 50.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.cashPercentage, 50.0, accuracy: 0.01)
    }

    func test_fullDeleteStockFlow_shouldRecalculate() {
        // Given
        viewModel.saveSeedMoney(10_000_000)
        viewModel.addStock(name: "삼성전자", amount: 3_000_000)
        viewModel.addStock(name: "SK하이닉스", amount: 2_000_000)
        XCTAssertEqual(viewModel.holdings.count, 2)
        let totalBefore = viewModel.totalInvestedAmount

        // When: 첫 번째 종목 삭제
        let stockToDelete = viewModel.holdings.first!
        let deletedAmount = stockToDelete.purchaseAmount
        viewModel.deleteStock(stockToDelete)

        // Then
        XCTAssertEqual(viewModel.holdings.count, 1)
        XCTAssertEqual(viewModel.totalInvestedAmount, totalBefore - deletedAmount)
        XCTAssertEqual(viewModel.remainingCash, 10_000_000 - (totalBefore - deletedAmount))
    }

    func test_fullUpdateStockFlow_shouldRecalculate() {
        // Given
        viewModel.saveSeedMoney(10_000_000)
        viewModel.addStock(name: "삼성전자", amount: 3_000_000)
        let originalStock = viewModel.holdings.first!

        // When: 종목 수정
        viewModel.updateStock(originalStock, name: "카카오", amount: 5_000_000, colorName: originalStock.colorName)

        // Then
        XCTAssertEqual(viewModel.holdings.count, 1)
        XCTAssertEqual(viewModel.holdings.first?.stockName, "카카오")
        XCTAssertEqual(viewModel.holdings.first?.purchaseAmount, 5_000_000)
        XCTAssertEqual(viewModel.totalInvestedAmount, 5_000_000)
    }

    // MARK: - Data Persistence Tests

    func test_dataReload_shouldRestoreState() {
        // Given: 데이터 저장
        viewModel.saveSeedMoney(10_000_000)
        viewModel.addStock(name: "삼성전자", amount: 3_000_000)

        // When: 새로운 ViewModel 생성 (앱 재시작 시뮬레이션)
        let newViewModel = PortfolioViewModel(
            repository: repository,
            seedMoneyStorage: seedMoneyStorage
        )

        // Then: 데이터가 유지되어야 함
        XCTAssertEqual(newViewModel.seedMoney, 10_000_000)
        XCTAssertEqual(newViewModel.holdings.count, 1)
        XCTAssertEqual(newViewModel.holdings.first?.stockName, "삼성전자")
    }

    // MARK: - Percentage Calculation Tests

    func test_stockPercentages_shouldSumTo100() {
        // Given
        viewModel.saveSeedMoney(10_000_000)
        viewModel.addStock(name: "삼성전자", amount: 4_000_000)
        viewModel.addStock(name: "SK하이닉스", amount: 3_000_000)
        viewModel.addStock(name: "카카오", amount: 3_000_000)

        // When
        var totalPercentage = 0.0
        for holding in viewModel.holdings {
            totalPercentage += viewModel.percentage(for: holding)
        }

        // Then
        XCTAssertEqual(totalPercentage, 100.0, accuracy: 0.01)
    }

    func test_investedAndCashPercentages_shouldSumTo100() {
        // Given
        viewModel.saveSeedMoney(10_000_000)
        viewModel.addStock(name: "삼성전자", amount: 7_000_000)

        // When
        let sum = viewModel.investedPercentage + viewModel.cashPercentage

        // Then
        XCTAssertEqual(sum, 100.0, accuracy: 0.01)
    }

    // MARK: - Edge Cases

    func test_overInvestment_shouldCapPercentageAt100() {
        // Given
        viewModel.saveSeedMoney(10_000_000)

        // When: 시드머니 초과 투자
        viewModel.addStock(name: "삼성전자", amount: 15_000_000)

        // Then
        XCTAssertEqual(viewModel.investedPercentage, 100.0)
        XCTAssertEqual(viewModel.cashPercentage, 0.0)
        XCTAssertEqual(viewModel.remainingCash, 0.0)
    }

    func test_zeroSeedMoney_shouldHandleGracefully() {
        // Given
        viewModel.saveSeedMoney(0)

        // When
        viewModel.addStock(name: "삼성전자", amount: 1_000_000)

        // Then: 0으로 나누기 방지
        XCTAssertEqual(viewModel.investedPercentage, 0.0)
        XCTAssertEqual(viewModel.cashPercentage, 0.0)
    }

    func test_emptyPortfolio_shouldShowZeroInvestment() {
        // Given
        viewModel.saveSeedMoney(10_000_000)

        // When: 종목 없음

        // Then
        XCTAssertEqual(viewModel.totalInvestedAmount, 0.0)
        XCTAssertEqual(viewModel.remainingCash, 10_000_000)
        XCTAssertEqual(viewModel.investedPercentage, 0.0)
        XCTAssertEqual(viewModel.cashPercentage, 100.0)
    }

    // MARK: - Stress Tests

    func test_manyStocks_shouldCalculateCorrectly() {
        // Given
        viewModel.saveSeedMoney(100_000_000)

        // When: 50개 종목 추가
        for i in 1...50 {
            viewModel.addStock(name: "종목\(i)", amount: 1_000_000)
        }

        // Then
        XCTAssertEqual(viewModel.holdings.count, 50)
        XCTAssertEqual(viewModel.totalInvestedAmount, 50_000_000)
        XCTAssertEqual(viewModel.investedPercentage, 50.0, accuracy: 0.01)
    }
}
