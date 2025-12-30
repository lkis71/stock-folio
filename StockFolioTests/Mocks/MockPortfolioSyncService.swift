import Foundation
@testable import StockFolio

/// Mock PortfolioSyncService for testing
final class MockPortfolioSyncService: PortfolioSyncServiceProtocol {

    // MARK: - Call Tracking
    var syncOnAddCallCount = 0
    var syncOnUpdateCallCount = 0
    var syncOnDeleteCallCount = 0
    var recalculateAllCallCount = 0

    var lastAddedJournal: TradingJournalEntity?
    var lastOldJournal: TradingJournalEntity?
    var lastNewJournal: TradingJournalEntity?
    var lastDeletedJournal: TradingJournalEntity?

    // MARK: - Error Simulation
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: 1)

    // MARK: - Protocol Methods

    func syncOnAdd(journal: TradingJournalEntity) throws {
        syncOnAddCallCount += 1
        lastAddedJournal = journal

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func syncOnUpdate(oldJournal: TradingJournalEntity, newJournal: TradingJournalEntity) throws {
        syncOnUpdateCallCount += 1
        lastOldJournal = oldJournal
        lastNewJournal = newJournal

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func syncOnDelete(journal: TradingJournalEntity) throws {
        syncOnDeleteCallCount += 1
        lastDeletedJournal = journal

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func recalculateAll() throws {
        recalculateAllCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }
    }

    // MARK: - Reset

    func reset() {
        syncOnAddCallCount = 0
        syncOnUpdateCallCount = 0
        syncOnDeleteCallCount = 0
        recalculateAllCallCount = 0
        lastAddedJournal = nil
        lastOldJournal = nil
        lastNewJournal = nil
        lastDeletedJournal = nil
        shouldThrowError = false
    }
}
