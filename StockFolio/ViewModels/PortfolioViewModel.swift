import Foundation
import SwiftUI

/// 포트폴리오 ViewModel (MVVM - 비즈니스 로직 담당)
/// DIP: 프로토콜에 의존하여 테스트 가능한 구조
final class PortfolioViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var holdings: [StockHoldingEntity] = []
    @Published private(set) var seedMoney: Double = 0
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasMore: Bool = false

    // MARK: - Dependencies (DIP - 프로토콜에 의존)
    private let repository: StockRepositoryProtocol
    private let seedMoneyStorage: SeedMoneyStorageProtocol
    private let validator: InputValidatorProtocol

    // MARK: - Pagination
    private var currentOffset = 0
    private let pageSize = 6

    // MARK: - Computed Properties (Repository 집계 쿼리 사용)
    var totalCount: Int {
        repository.fetchTotalCount()
    }

    var totalInvestedAmount: Double {
        repository.fetchTotalInvestedAmount()
    }

    var remainingCash: Double {
        max(0, seedMoney - totalInvestedAmount)
    }

    var investedPercentage: Double {
        guard seedMoney > 0 else { return 0 }
        return min(100, (totalInvestedAmount / seedMoney) * 100)
    }

    var cashPercentage: Double {
        guard seedMoney > 0 else { return 0 }
        return max(0, 100 - investedPercentage)
    }

    func percentage(for holding: StockHoldingEntity) -> Double {
        guard totalInvestedAmount > 0 else { return 0 }
        return (holding.purchaseAmount / totalInvestedAmount) * 100
    }

    // MARK: - Initialization (의존성 주입)
    init(
        repository: StockRepositoryProtocol = CoreDataStockRepository(),
        seedMoneyStorage: SeedMoneyStorageProtocol = SeedMoneyStorage(),
        validator: InputValidatorProtocol = StockInputValidator()
    ) {
        self.repository = repository
        self.seedMoneyStorage = seedMoneyStorage
        self.validator = validator

        loadSeedMoney()
        fetchHoldings()
    }

    // MARK: - Seed Money Operations
    func loadSeedMoney() {
        seedMoney = seedMoneyStorage.getSeedMoney()
    }

    func saveSeedMoney(_ amount: Double) {
        seedMoneyStorage.saveSeedMoney(amount)
        seedMoney = amount
    }

    // MARK: - Data Loading
    private func loadInitialData() {
        currentOffset = 0
        holdings = []

        let pagination = PaginationRequest(limit: pageSize, offset: currentOffset)
        let result = repository.fetch(pagination: pagination)

        Logger.info("[Portfolio] loadInitialData - Requested: \(pageSize), Loaded: \(result.items.count), Total: \(result.totalCount), HasMore: \(result.hasMore)")

        holdings = result.items
        hasMore = result.hasMore
        currentOffset = result.items.count
    }

    func fetchHoldings() {
        loadInitialData()
    }

    func fetchMore() {
        guard !isLoading && hasMore else {
            Logger.info("[Portfolio] fetchMore - Skipped (isLoading: \(isLoading), hasMore: \(hasMore))")
            return
        }

        isLoading = true

        let pagination = PaginationRequest(limit: pageSize, offset: currentOffset)
        let result = repository.fetch(pagination: pagination)

        Logger.info("[Portfolio] fetchMore - Requested: \(pageSize), Offset: \(currentOffset), Loaded: \(result.items.count), HasMore: \(result.hasMore)")

        holdings.append(contentsOf: result.items)
        hasMore = result.hasMore
        currentOffset += result.items.count

        isLoading = false
    }

    // MARK: - Stock CRUD Operations

    func addStock(name: String, amount: Double, colorName: String = StockColor.random.rawValue) {
        // 입력 검증
        guard case .success(let validName) = validator.validateStockName(name),
              case .success(let validAmount) = validator.validateAmount(amount) else {
            return
        }

        let stock = StockHoldingEntity(
            stockName: validName,
            purchaseAmount: validAmount,
            colorName: colorName
        )

        do {
            try repository.save(stock)
            fetchHoldings()
        } catch {
            Logger.error("Save error: \(error.localizedDescription)")
        }
    }

    func updateStock(_ stock: StockHoldingEntity, name: String, amount: Double, colorName: String) {
        // 입력 검증
        guard case .success(let validName) = validator.validateStockName(name),
              case .success(let validAmount) = validator.validateAmount(amount) else {
            return
        }

        var updatedStock = stock
        updatedStock.stockName = validName
        updatedStock.purchaseAmount = validAmount
        updatedStock.colorName = colorName

        do {
            try repository.update(updatedStock)
            fetchHoldings()
        } catch {
            Logger.error("Update error: \(error.localizedDescription)")
        }
    }

    func deleteStock(_ stock: StockHoldingEntity) {
        do {
            try repository.delete(stock)
            fetchHoldings()
        } catch {
            Logger.error("Delete error: \(error.localizedDescription)")
        }
    }

    func deleteStocks(at offsets: IndexSet) {
        for index in offsets {
            deleteStock(holdings[index])
        }
    }

    // MARK: - Refresh
    func refresh() {
        loadSeedMoney()
        fetchHoldings()
    }
}
