import Foundation
import SwiftUI

/// 포트폴리오 ViewModel (MVVM - 비즈니스 로직 담당)
/// DIP: 프로토콜에 의존하여 테스트 가능한 구조
final class PortfolioViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var holdings: [StockHoldingEntity] = []
    @Published private(set) var seedMoney: Double = 0

    // MARK: - Dependencies (DIP - 프로토콜에 의존)
    private let repository: StockRepositoryProtocol
    private let seedMoneyStorage: SeedMoneyStorageProtocol
    private let validator: InputValidatorProtocol

    // MARK: - Computed Properties (Portfolio 계산 위임)
    private var portfolio: Portfolio {
        Portfolio(holdings: holdings, seedMoney: seedMoney)
    }

    var totalInvestedAmount: Double {
        portfolio.totalInvestedAmount
    }

    var remainingCash: Double {
        portfolio.remainingCash
    }

    var investedPercentage: Double {
        portfolio.investedPercentage
    }

    var cashPercentage: Double {
        portfolio.cashPercentage
    }

    func percentage(for holding: StockHoldingEntity) -> Double {
        portfolio.percentage(for: holding)
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

    // MARK: - Stock CRUD Operations
    func fetchHoldings() {
        holdings = repository.fetchAll()
    }

    func addStock(name: String, amount: Double) {
        // 입력 검증
        guard case .success(let validName) = validator.validateStockName(name),
              case .success(let validAmount) = validator.validateAmount(amount) else {
            return
        }

        let stock = StockHoldingEntity(
            stockName: validName,
            purchaseAmount: validAmount
        )

        do {
            try repository.save(stock)
            fetchHoldings()
        } catch {
            print("Save error: \(error)")
        }
    }

    func updateStock(_ stock: StockHoldingEntity, name: String, amount: Double) {
        // 입력 검증
        guard case .success(let validName) = validator.validateStockName(name),
              case .success(let validAmount) = validator.validateAmount(amount) else {
            return
        }

        var updatedStock = stock
        updatedStock.stockName = validName
        updatedStock.purchaseAmount = validAmount

        do {
            try repository.update(updatedStock)
            fetchHoldings()
        } catch {
            print("Update error: \(error)")
        }
    }

    func deleteStock(_ stock: StockHoldingEntity) {
        do {
            try repository.delete(stock)
            fetchHoldings()
        } catch {
            print("Delete error: \(error)")
        }
    }

    func deleteStocks(at offsets: IndexSet) {
        for index in offsets {
            deleteStock(holdings[index])
        }
    }
}
