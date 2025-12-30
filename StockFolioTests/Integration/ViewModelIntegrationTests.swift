import XCTest
import CoreData
@testable import StockFolio

/// ViewModel + Repository 통합 테스트
/// 실제 Core Data를 사용한 End-to-End 테스트
/// v3.0: 포트폴리오는 매매일지 기반으로만 관리 (직접 CRUD 제거)
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

    // MARK: - Helper Methods

    /// Repository를 통해 직접 종목 추가 (매매일지 동기화 시뮬레이션)
    private func addStockViaRepository(name: String, quantity: Int, averagePrice: Double) {
        let stock = StockHoldingEntity(
            stockName: name,
            quantity: quantity,
            averagePrice: averagePrice
        )
        try? repository.upsert(stock)
        viewModel.fetchHoldings()
    }

    // MARK: - Full Flow Tests

    func test_fullPortfolioFlow_shouldUpdateAllCalculations() {
        // Given
        viewModel.saveSeedMoney(10_000_000)

        // When: Repository를 통해 종목 추가 (매매일지 동기화 시뮬레이션)
        addStockViaRepository(name: "삼성전자", quantity: 100, averagePrice: 30_000)
        addStockViaRepository(name: "SK하이닉스", quantity: 20, averagePrice: 100_000)

        // Then
        XCTAssertEqual(viewModel.holdings.count, 2)
        XCTAssertEqual(viewModel.totalInvestedAmount, 5_000_000)  // 3M + 2M
        XCTAssertEqual(viewModel.remainingCash, 5_000_000)
        XCTAssertEqual(viewModel.investedPercentage, 50.0, accuracy: 0.01)
        XCTAssertEqual(viewModel.cashPercentage, 50.0, accuracy: 0.01)
    }

    func test_stockDeletion_shouldRecalculate() {
        // Given
        viewModel.saveSeedMoney(10_000_000)
        addStockViaRepository(name: "삼성전자", quantity: 100, averagePrice: 30_000)
        addStockViaRepository(name: "SK하이닉스", quantity: 20, averagePrice: 100_000)
        XCTAssertEqual(viewModel.holdings.count, 2)

        // When: Repository를 통해 종목 삭제 (전량 매도 시뮬레이션)
        try? repository.deleteByStockName("삼성전자")
        viewModel.fetchHoldings()

        // Then
        XCTAssertEqual(viewModel.holdings.count, 1)
        XCTAssertEqual(viewModel.totalInvestedAmount, 2_000_000)
        XCTAssertEqual(viewModel.remainingCash, 8_000_000)
    }

    // MARK: - Data Persistence Tests

    func test_dataReload_shouldRestoreState() {
        // Given: 데이터 저장
        viewModel.saveSeedMoney(10_000_000)
        addStockViaRepository(name: "삼성전자", quantity: 100, averagePrice: 30_000)

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
        addStockViaRepository(name: "삼성전자", quantity: 40, averagePrice: 100_000)  // 4M
        addStockViaRepository(name: "SK하이닉스", quantity: 30, averagePrice: 100_000)  // 3M
        addStockViaRepository(name: "카카오", quantity: 30, averagePrice: 100_000)  // 3M

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
        addStockViaRepository(name: "삼성전자", quantity: 70, averagePrice: 100_000)  // 7M

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
        addStockViaRepository(name: "삼성전자", quantity: 150, averagePrice: 100_000)  // 15M

        // Then
        XCTAssertEqual(viewModel.investedPercentage, 100.0)
        XCTAssertEqual(viewModel.cashPercentage, 0.0)
        XCTAssertEqual(viewModel.remainingCash, 0.0)
    }

    func test_zeroSeedMoney_shouldHandleGracefully() {
        // Given
        viewModel.saveSeedMoney(0)

        // When
        addStockViaRepository(name: "삼성전자", quantity: 10, averagePrice: 100_000)

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
}
