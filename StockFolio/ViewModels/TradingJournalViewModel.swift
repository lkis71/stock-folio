import Foundation
import SwiftUI

final class TradingJournalViewModel: ObservableObject {

    @Published private(set) var journals: [TradingJournalEntity] = []
    @Published private(set) var statistics: TradingJournalStatistics?
    @Published private(set) var portfolioStocks: [String] = []
    @Published private(set) var allStockNames: [String] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasMore: Bool = false

    @Published var filterType: FilterType = .all
    @Published var selectedDate: Date = Date()
    @Published var selectedMonth: Date = Date()
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var selectedStockName: String = ""

    private let repository: TradingJournalRepositoryProtocol
    private let stockRepository: StockRepositoryProtocol
    private let pageSize = 10
    private var currentOffset = 0

    // Computed properties - 통계 위임
    var totalTradeCount: Int {
        statistics?.totalCount ?? 0
    }

    var buyTradeCount: Int {
        statistics?.buyCount ?? 0
    }

    var sellTradeCount: Int {
        statistics?.sellCount ?? 0
    }

    var totalRealizedProfit: Double {
        statistics?.totalRealizedProfit ?? 0
    }

    var totalProfitRate: Double {
        statistics?.totalProfitRate ?? 0
    }

    var winRate: Double {
        statistics?.winRate ?? 0
    }

    // 현재 필터 생성
    private var currentFilter: TradingJournalFilter? {
        let calendar = Calendar.current
        let year: Int?
        let month: Int?

        switch filterType {
        case .daily:
            year = nil
            month = nil
        case .monthly:
            let components = calendar.dateComponents([.year, .month], from: selectedMonth)
            year = components.year
            month = components.month
        case .yearly:
            year = selectedYear
            month = nil
        case .all:
            year = nil
            month = nil
        }

        return TradingJournalFilter(
            filterType: filterType,
            date: filterType == .daily ? selectedDate : nil,
            year: year,
            month: month,
            stockName: selectedStockName.isEmpty ? nil : selectedStockName
        )
    }

    init(
        repository: TradingJournalRepositoryProtocol = CoreDataTradingJournalRepository(),
        stockRepository: StockRepositoryProtocol = CoreDataStockRepository()
    ) {
        self.repository = repository
        self.stockRepository = stockRepository
        loadInitialData()
        updateAllStockNames()
        fetchPortfolioStocks()
    }

    // MARK: - Data Loading

    private func loadInitialData() {
        currentOffset = 0
        journals = []

        // 페이징 데이터 로드
        let pagination = PaginationRequest(limit: pageSize, offset: currentOffset)
        let result = repository.fetch(pagination: pagination, filter: currentFilter)

        Logger.info("[TradingJournal] loadInitialData - Requested: \(pageSize), Loaded: \(result.items.count), Total: \(result.totalCount), HasMore: \(result.hasMore)")

        journals = result.items
        hasMore = result.hasMore
        currentOffset = result.items.count

        // 통계 로드 (별도 쿼리)
        let stats = repository.fetchStatistics(filter: currentFilter)
        let winRate = repository.fetchWinRate(filter: currentFilter)

        statistics = TradingJournalStatistics(
            totalCount: stats.totalCount,
            buyCount: stats.buyCount,
            sellCount: stats.sellCount,
            totalRealizedProfit: stats.totalRealizedProfit,
            totalSellAmount: stats.totalSellAmount,
            winRate: winRate
        )
    }

    func fetchJournals() {
        loadInitialData()
    }

    func fetchMore() {
        guard !isLoading && hasMore else {
            Logger.info("[TradingJournal] fetchMore - Skipped (isLoading: \(isLoading), hasMore: \(hasMore))")
            return
        }

        isLoading = true

        let pagination = PaginationRequest(limit: pageSize, offset: currentOffset)
        let result = repository.fetch(pagination: pagination, filter: currentFilter)

        Logger.info("[TradingJournal] fetchMore - Requested: \(pageSize), Offset: \(currentOffset), Loaded: \(result.items.count), HasMore: \(result.hasMore)")

        journals.append(contentsOf: result.items)
        hasMore = result.hasMore
        currentOffset += result.items.count

        isLoading = false
    }

    private func updateAllStockNames() {
        // 전체 종목 목록은 필터와 무관하게 가져오기
        let allJournals = repository.fetchAll()
        let names = allJournals.map { $0.stockName }
        allStockNames = Array(Set(names)).sorted()
    }

    func fetchPortfolioStocks() {
        let holdings = stockRepository.fetchAll()
        let stockNames = holdings
            .map { $0.stockName }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        portfolioStocks = Array(Set(stockNames)).sorted()
    }

    // MARK: - CRUD Operations

    func addJournal(
        tradeType: TradeType,
        tradeDate: Date,
        stockName: String,
        quantity: Int,
        price: Double,
        realizedProfit: Double = 0,
        reason: String
    ) {
        let journal = TradingJournalEntity(
            tradeType: tradeType,
            tradeDate: tradeDate,
            stockName: stockName,
            quantity: quantity,
            price: price,
            realizedProfit: realizedProfit,
            reason: reason
        )

        do {
            try repository.save(journal)
            loadInitialData()
            updateAllStockNames()
        } catch {
            Logger.error("Save trading journal error: \(error.localizedDescription)")
        }
    }

    func updateJournal(
        _ journal: TradingJournalEntity,
        tradeType: TradeType,
        tradeDate: Date,
        stockName: String,
        quantity: Int,
        price: Double,
        realizedProfit: Double = 0,
        reason: String
    ) {
        var updatedJournal = journal
        updatedJournal.tradeType = tradeType
        updatedJournal.tradeDate = tradeDate
        updatedJournal.stockName = stockName
        updatedJournal.quantity = quantity
        updatedJournal.price = price
        updatedJournal.realizedProfit = realizedProfit
        updatedJournal.reason = reason
        updatedJournal.updatedAt = Date()

        do {
            try repository.update(updatedJournal)
            loadInitialData()
            updateAllStockNames()
        } catch {
            Logger.error("Update trading journal error: \(error.localizedDescription)")
        }
    }

    func deleteJournal(_ journal: TradingJournalEntity) {
        do {
            try repository.delete(journal)
            loadInitialData()
            updateAllStockNames()
        } catch {
            Logger.error("Delete trading journal error: \(error.localizedDescription)")
        }
    }

    func deleteJournals(at offsets: IndexSet) {
        for index in offsets {
            deleteJournal(journals[index])
        }
    }

    func refresh() {
        loadInitialData()
        fetchPortfolioStocks()
    }

    // MARK: - Filtering

    func applyFilter() {
        loadInitialData()
    }

    func clearStockFilter() {
        selectedStockName = ""
        applyFilter()
    }
}
