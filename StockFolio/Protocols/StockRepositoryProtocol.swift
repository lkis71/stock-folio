import Foundation

/// 종목 데이터 저장소 프로토콜 (DIP - 의존성 역전 원칙)
/// ViewModel은 이 프로토콜에 의존하여 테스트 가능한 구조를 유지합니다.
protocol StockRepositoryProtocol {
    func fetchAll() -> [StockHoldingEntity]
    func save(_ stock: StockHoldingEntity) throws
    func update(_ stock: StockHoldingEntity) throws
    func delete(_ stock: StockHoldingEntity) throws

    // Pagination
    func fetch(pagination: PaginationRequest) -> PaginationResult<StockHoldingEntity>

    // Statistics
    func fetchTotalCount() -> Int
    func fetchTotalInvestedAmount() -> Double

    // 매매일지 연동용 메서드
    func fetchByStockName(_ stockName: String) -> StockHoldingEntity?
    func upsert(_ stock: StockHoldingEntity) throws
    func deleteByStockName(_ stockName: String) throws
}

/// 시드머니 저장소 프로토콜 (SRP - 단일 책임 원칙)
/// 시드머니 관련 저장만 담당합니다.
protocol SeedMoneyStorageProtocol {
    func getSeedMoney() -> Double
    func saveSeedMoney(_ amount: Double)
}
