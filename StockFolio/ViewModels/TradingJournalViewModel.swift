import Foundation
import SwiftUI

final class TradingJournalViewModel: ObservableObject {

    @Published private(set) var journals: [TradingJournalEntity] = []
    @Published var filterType: FilterType = .all
    @Published var selectedDate: Date = Date()
    @Published var selectedMonth: Date = Date()
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private let repository: TradingJournalRepositoryProtocol
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
            total + journal.totalAmount
        }
    }

    var winRate: Double {
        let sellJournals = journals.filter { $0.tradeType == .sell }
        guard !sellJournals.isEmpty else { return 0 }

        let winCount = sellJournals.filter { $0.totalAmount > 0 }.count
        return (Double(winCount) / Double(sellJournals.count)) * 100
    }

    init(repository: TradingJournalRepositoryProtocol = CoreDataTradingJournalRepository()) {
        self.repository = repository
        fetchJournals()
    }

    func fetchJournals() {
        journals = repository.fetchAll()
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
        reason: String
    ) {
        let journal = TradingJournalEntity(
            tradeType: tradeType,
            tradeDate: tradeDate,
            stockName: stockName,
            quantity: quantity,
            price: price,
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
        reason: String
    ) {
        var updatedJournal = journal
        updatedJournal.tradeType = tradeType
        updatedJournal.tradeDate = tradeDate
        updatedJournal.stockName = stockName
        updatedJournal.quantity = quantity
        updatedJournal.price = price
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
    }

    func applyFilter() {
        switch filterType {
        case .all:
            journals = repository.fetchAll()
        case .daily:
            journals = repository.fetchByDate(selectedDate)
        case .monthly:
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: selectedMonth)
            guard let year = components.year, let month = components.month else {
                journals = []
                return
            }
            journals = repository.fetchByMonth(year: year, month: month)
        case .yearly:
            journals = repository.fetchByYear(selectedYear)
        }
    }
}
