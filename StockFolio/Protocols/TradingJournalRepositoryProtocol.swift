import Foundation

protocol TradingJournalRepositoryProtocol {
    func fetchAll() -> [TradingJournalEntity]
    func fetch(limit: Int, offset: Int) -> [TradingJournalEntity]
    func save(_ journal: TradingJournalEntity) throws
    func update(_ journal: TradingJournalEntity) throws
    func delete(_ journal: TradingJournalEntity) throws

    // Filtering methods
    func fetchByDate(_ date: Date) -> [TradingJournalEntity]
    func fetchByMonth(year: Int, month: Int) -> [TradingJournalEntity]
    func fetchByYear(_ year: Int) -> [TradingJournalEntity]
}
