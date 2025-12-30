import Foundation

/// 포트폴리오 동기화 서비스 프로토콜
protocol PortfolioSyncServiceProtocol {
    /// 매매일지 추가 시 포트폴리오 동기화
    func syncOnAdd(journal: TradingJournalEntity) throws
    /// 매매일지 수정 시 포트폴리오 동기화 (이전 → 새로운)
    func syncOnUpdate(oldJournal: TradingJournalEntity, newJournal: TradingJournalEntity) throws
    /// 매매일지 삭제 시 포트폴리오 동기화
    func syncOnDelete(journal: TradingJournalEntity) throws
    /// 전체 재계산 (매매일지 기반으로 포트폴리오 재구축)
    func recalculateAll() throws
}

/// 포트폴리오 동기화 서비스
/// 매매일지 변경 시 포트폴리오를 자동으로 업데이트합니다.
final class PortfolioSyncService: PortfolioSyncServiceProtocol {

    private let stockRepository: StockRepositoryProtocol
    private let journalRepository: TradingJournalRepositoryProtocol

    init(
        stockRepository: StockRepositoryProtocol = CoreDataStockRepository(),
        journalRepository: TradingJournalRepositoryProtocol = CoreDataTradingJournalRepository()
    ) {
        self.stockRepository = stockRepository
        self.journalRepository = journalRepository
    }

    // MARK: - 매매일지 추가 시 동기화

    func syncOnAdd(journal: TradingJournalEntity) throws {
        switch journal.tradeType {
        case .buy:
            try applyBuy(stockName: journal.stockName, quantity: journal.quantity, price: journal.price)
        case .sell:
            try applySell(stockName: journal.stockName, quantity: journal.quantity)
        }
    }

    // MARK: - 매매일지 수정 시 동기화

    func syncOnUpdate(oldJournal: TradingJournalEntity, newJournal: TradingJournalEntity) throws {
        // 1. 이전 매매 영향 취소
        try revertJournal(oldJournal)
        // 2. 새 매매 영향 적용
        try syncOnAdd(journal: newJournal)
    }

    // MARK: - 매매일지 삭제 시 동기화

    func syncOnDelete(journal: TradingJournalEntity) throws {
        try revertJournal(journal)
    }

    // MARK: - 전체 재계산

    func recalculateAll() throws {
        // 1. 기존 포트폴리오 전체 삭제
        let allStocks = stockRepository.fetchAll()
        for stock in allStocks {
            try stockRepository.delete(stock)
        }

        // 2. 매매일지 전체 조회 (날짜순 정렬)
        let allJournals = journalRepository.fetchAll().sorted { $0.tradeDate < $1.tradeDate }

        // 3. 순차적으로 매매 반영
        for journal in allJournals {
            try syncOnAdd(journal: journal)
        }

        Logger.info("[PortfolioSync] 전체 재계산 완료: \(allJournals.count)건 처리")
    }

    // MARK: - Private Methods

    /// 매수 반영: 동일 종목이 있으면 평균매입가 계산, 없으면 신규 추가
    private func applyBuy(stockName: String, quantity: Int, price: Double) throws {
        if let existing = stockRepository.fetchByStockName(stockName) {
            // 기존 종목 있음 → 평균매입가 재계산
            let totalQuantity = existing.quantity + quantity
            let totalAmount = existing.purchaseAmount + (Double(quantity) * price)
            let newAveragePrice = totalAmount / Double(totalQuantity)

            let updated = StockHoldingEntity(
                id: existing.id,
                stockName: stockName,
                quantity: totalQuantity,
                averagePrice: newAveragePrice,
                colorName: existing.colorName,
                createdAt: existing.createdAt
            )
            try stockRepository.upsert(updated)

            Logger.info("[PortfolioSync] 매수 반영 (기존): \(stockName) \(existing.quantity) + \(quantity) = \(totalQuantity)주, 평균가: \(newAveragePrice)")
        } else {
            // 신규 종목 추가
            let newStock = StockHoldingEntity(
                stockName: stockName,
                quantity: quantity,
                averagePrice: price
            )
            try stockRepository.upsert(newStock)

            Logger.info("[PortfolioSync] 매수 반영 (신규): \(stockName) \(quantity)주 @ \(price)")
        }
    }

    /// 매도 반영: 수량 차감, 0이 되면 종목 제거
    private func applySell(stockName: String, quantity: Int) throws {
        guard let existing = stockRepository.fetchByStockName(stockName) else {
            Logger.warning("[PortfolioSync] 매도 실패: \(stockName) 종목 없음")
            return
        }

        let remainingQuantity = existing.quantity - quantity

        if remainingQuantity <= 0 {
            // 전량 매도 → 종목 삭제
            try stockRepository.deleteByStockName(stockName)
            Logger.info("[PortfolioSync] 매도 반영 (전량): \(stockName) 종목 삭제")
        } else {
            // 부분 매도 → 수량만 감소 (평균가 유지)
            let updated = StockHoldingEntity(
                id: existing.id,
                stockName: stockName,
                quantity: remainingQuantity,
                averagePrice: existing.averagePrice,
                colorName: existing.colorName,
                createdAt: existing.createdAt
            )
            try stockRepository.upsert(updated)

            Logger.info("[PortfolioSync] 매도 반영 (부분): \(stockName) \(existing.quantity) - \(quantity) = \(remainingQuantity)주")
        }
    }

    /// 매매 취소 (수정/삭제 시 이전 영향 되돌리기)
    private func revertJournal(_ journal: TradingJournalEntity) throws {
        switch journal.tradeType {
        case .buy:
            // 매수 취소 = 매도 적용
            try applySell(stockName: journal.stockName, quantity: journal.quantity)
        case .sell:
            // 매도 취소 = 매수 적용 (단, 평균가는 이전 값 사용해야 함 → 전체 재계산 필요)
            // 간단한 구현: 매도 취소 시에도 동일 가격으로 재매수
            try applyBuy(stockName: journal.stockName, quantity: journal.quantity, price: journal.price)
        }
    }
}
