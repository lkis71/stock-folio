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
    private let syncService: PortfolioSyncServiceProtocol

    // MARK: - Pagination
    private var currentOffset = 0
    private let pageSize = 10

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

    /// 총 포트폴리오 가치 (투자금 + 현금, 비중 계산의 기준)
    var totalPortfolioValue: Double {
        totalInvestedAmount + remainingCash
    }

    var investedPercentage: Double {
        guard totalPortfolioValue > 0 else { return 0 }
        return (totalInvestedAmount / totalPortfolioValue) * 100
    }

    var cashPercentage: Double {
        guard totalPortfolioValue > 0 else { return 0 }
        return (remainingCash / totalPortfolioValue) * 100
    }

    func percentage(for holding: StockHoldingEntity) -> Double {
        guard totalPortfolioValue > 0 else { return 0 }
        return (holding.purchaseAmount / totalPortfolioValue) * 100
    }

    // MARK: - Statistics for StatCard (v2.0)

    /// 총 평가액 (현재 v1: 투자금액과 동일, 향후 실시간 시세 반영)
    var totalEvaluationAmount: Double {
        // v1: 평가액 = 투자금액 (손익 미반영)
        // TODO: v2에서 실시간 시세 API 연동 시 실제 평가액 계산
        return totalInvestedAmount
    }

    /// 총 손익 (현재 v1: 0, 향후 매매일지 연동)
    var totalProfitLoss: Double {
        // v1: 손익 계산 기능 없음
        // TODO: v2에서 매매일지 실현손익 + 미실현손익 합산
        return 0
    }

    /// 총 수익률 (현재 v1: 0, 향후 계산)
    var totalReturnRate: Double {
        // v1: 수익률 계산 기능 없음
        // TODO: v2에서 (총 손익 / 투자금액) * 100 계산
        guard totalInvestedAmount > 0 else { return 0 }
        return 0
    }

    // MARK: - Initialization (의존성 주입)
    init(
        repository: StockRepositoryProtocol = CoreDataStockRepository(),
        seedMoneyStorage: SeedMoneyStorageProtocol = SeedMoneyStorage(),
        validator: InputValidatorProtocol = StockInputValidator(),
        syncService: PortfolioSyncServiceProtocol = PortfolioSyncService()
    ) {
        self.repository = repository
        self.seedMoneyStorage = seedMoneyStorage
        self.validator = validator
        self.syncService = syncService

        // 앱 시작 시 매매일지 기반으로 포트폴리오 재계산
        // 기존 직접 입력 데이터를 삭제하고 매매일지만 반영
        rebuildPortfolioFromJournal()

        loadSeedMoney()
        fetchHoldings()
    }

    // MARK: - Portfolio Rebuild (매매일지 기반)

    /// 매매일지를 기반으로 포트폴리오 전체 재구축
    /// 앱 시작 시 호출되어 데이터 정합성 보장
    private func rebuildPortfolioFromJournal() {
        do {
            try syncService.recalculateAll()
            Logger.info("[Portfolio] 매매일지 기반 포트폴리오 재구축 완료")
        } catch {
            Logger.error("[Portfolio] 포트폴리오 재구축 실패: \(error)")
        }
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

    func collapseToInitial() {
        guard holdings.count > pageSize else { return }

        holdings = Array(holdings.prefix(pageSize))
        currentOffset = pageSize
        hasMore = totalCount > pageSize

        Logger.info("[Portfolio] collapseToInitial - Collapsed to \(pageSize) items")
    }

    // MARK: - Stock CRUD Operations (제거됨 - 매매일지 기반으로만 관리)
    // v3.0: 포트폴리오 직접 입력 기능 제거
    // 포트폴리오는 PortfolioSyncService를 통해 매매일지 기반으로만 관리됩니다.

    // MARK: - Refresh
    func refresh() {
        loadSeedMoney()
        fetchHoldings()
    }
}
