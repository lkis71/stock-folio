import Foundation
import SwiftUI

final class TradingJournalViewModel: ObservableObject {

    @Published private(set) var journals: [TradingJournalEntity] = []
    @Published private(set) var portfolioStocks: [String] = []
    @Published private(set) var allStockNames: [String] = []
    @Published var filterType: FilterType = .all
    @Published var selectedDate: Date = Date()
    @Published var selectedMonth: Date = Date()
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var selectedStockName: String = ""

    private let repository: TradingJournalRepositoryProtocol
    private let stockRepository: StockRepositoryProtocol
    private let pageSize = 20

    var totalTradeCount: Int {
        journals.count
    }

    var buyTradeCount: Int {
        journals.filter { $0.tradeType == .buy }.count
    }

    var sellTradeCount: Int {
        journals.filter { $0.tradeType == .sell }.count
    }

    var totalRealizedProfit: Double {
        let sellJournals = journals.filter { $0.tradeType == .sell }
        return sellJournals.reduce(0) { total, journal in
            total + journal.realizedProfit
        }
    }

    var totalProfitRate: Double {
        let sellJournals = journals.filter { $0.tradeType == .sell }
        let totalSellAmount = sellJournals.reduce(0) { $0 + $1.totalAmount }
        let totalProfit = totalRealizedProfit
        let totalInvested = totalSellAmount - totalProfit
        guard totalInvested > 0 else { return 0 }
        return (totalProfit / totalInvested) * 100
    }

    var winRate: Double {
        let sellJournals = journals.filter { $0.tradeType == .sell }
        guard !sellJournals.isEmpty else { return 0 }

        let winCount = sellJournals.filter { $0.realizedProfit > 0 }.count
        return (Double(winCount) / Double(sellJournals.count)) * 100
    }

    init(
        repository: TradingJournalRepositoryProtocol = CoreDataTradingJournalRepository(),
        stockRepository: StockRepositoryProtocol = CoreDataStockRepository()
    ) {
        self.repository = repository
        self.stockRepository = stockRepository
        fetchJournals()
        fetchPortfolioStocks()
    }

    func fetchJournals() {
        journals = repository.fetchAll()
        updateAllStockNames(from: journals)
    }

    private func updateAllStockNames(from journalList: [TradingJournalEntity]) {
        let names = journalList.map { $0.stockName }
        allStockNames = Array(Set(names)).sorted()
    }

    func fetchPortfolioStocks() {
        let holdings = stockRepository.fetchAll()
        let stockNames = holdings
            .map { $0.stockName }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        portfolioStocks = Array(Set(stockNames)).sorted()
    }

    func fetchMore(offset: Int) {
        let moreJournals = repository.fetch(limit: pageSize, offset: offset)
        journals.append(contentsOf: moreJournals)
    }

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
            fetchJournals()
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
            fetchJournals()
        } catch {
            Logger.error("Update trading journal error: \(error.localizedDescription)")
        }
    }

    func deleteJournal(_ journal: TradingJournalEntity) {
        do {
            try repository.delete(journal)
            fetchJournals()
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
        fetchJournals()
        fetchPortfolioStocks()
    }

    func applyFilter() {
        var result: [TradingJournalEntity]

        switch filterType {
        case .all:
            result = repository.fetchAll()
        case .daily:
            result = repository.fetchByDate(selectedDate)
        case .monthly:
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: selectedMonth)
            guard let year = components.year, let month = components.month else {
                journals = []
                return
            }
            result = repository.fetchByMonth(year: year, month: month)
        case .yearly:
            result = repository.fetchByYear(selectedYear)
        }

        // 종목 필터 적용
        if !selectedStockName.isEmpty {
            result = result.filter { $0.stockName == selectedStockName }
        }

        journals = result
    }

    func clearStockFilter() {
        selectedStockName = ""
        applyFilter()
    }
}
