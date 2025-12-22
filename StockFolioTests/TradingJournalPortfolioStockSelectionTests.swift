import XCTest
@testable import StockFolio

/// 매매 기록에서 포트폴리오 종목 선택 기능 테스트
/// TDD Red 단계: 실패하는 테스트 작성
final class TradingJournalPortfolioStockSelectionTests: XCTestCase {

    var sut: TradingJournalViewModel!
    var mockJournalRepository: MockTradingJournalRepository!
    var mockStockRepository: MockStockRepository!

    override func setUp() {
        super.setUp()
        mockJournalRepository = MockTradingJournalRepository()
        mockStockRepository = MockStockRepository()
        sut = TradingJournalViewModel(
            repository: mockJournalRepository,
            stockRepository: mockStockRepository
        )
    }

    override func tearDown() {
        sut = nil
        mockJournalRepository = nil
        mockStockRepository = nil
        super.tearDown()
    }

    // MARK: - 포트폴리오 종목 조회 테스트

    func testFetchPortfolioStocks_WhenStocksExist_ReturnsStockNames() {
        // Given: 포트폴리오에 종목이 존재
        mockStockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1000000),
            StockHoldingEntity(stockName: "SK하이닉스", purchaseAmount: 500000),
            StockHoldingEntity(stockName: "NAVER", purchaseAmount: 300000)
        ]

        // When: 포트폴리오 종목 조회
        sut.fetchPortfolioStocks()

        // Then: 종목명 배열이 정렬되어 반환됨
        XCTAssertEqual(sut.portfolioStocks.count, 3)
        XCTAssertEqual(sut.portfolioStocks[0], "NAVER")
        XCTAssertEqual(sut.portfolioStocks[1], "SK하이닉스")
        XCTAssertEqual(sut.portfolioStocks[2], "삼성전자")
    }

    func testFetchPortfolioStocks_WhenNoStocks_ReturnsEmptyArray() {
        // Given: 포트폴리오가 비어있음
        mockStockRepository.stocks = []

        // When: 포트폴리오 종목 조회
        sut.fetchPortfolioStocks()

        // Then: 빈 배열 반환
        XCTAssertTrue(sut.portfolioStocks.isEmpty)
    }

    func testFetchPortfolioStocks_RemovesDuplicates() {
        // Given: 중복된 종목명이 있는 경우 (실제로는 발생하지 않지만 방어 로직)
        mockStockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1000000),
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 500000)
        ]

        // When: 포트폴리오 종목 조회
        sut.fetchPortfolioStocks()

        // Then: 중복 제거된 종목명 반환
        XCTAssertEqual(sut.portfolioStocks.count, 1)
        XCTAssertEqual(sut.portfolioStocks[0], "삼성전자")
    }

    func testPortfolioStocks_SortedAlphabetically() {
        // Given: 정렬되지 않은 종목들
        mockStockRepository.stocks = [
            StockHoldingEntity(stockName: "카카오", purchaseAmount: 1000000),
            StockHoldingEntity(stockName: "NAVER", purchaseAmount: 500000),
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 300000),
            StockHoldingEntity(stockName: "SK하이닉스", purchaseAmount: 200000)
        ]

        // When: 포트폴리오 종목 조회
        sut.fetchPortfolioStocks()

        // Then: 가나다순으로 정렬됨
        XCTAssertEqual(sut.portfolioStocks[0], "NAVER")
        XCTAssertEqual(sut.portfolioStocks[1], "SK하이닉스")
        XCTAssertEqual(sut.portfolioStocks[2], "삼성전자")
        XCTAssertEqual(sut.portfolioStocks[3], "카카오")
    }

    // MARK: - ViewModel 초기화 테스트

    func testInit_FetchesPortfolioStocksAutomatically() {
        // Given: 포트폴리오에 종목이 존재
        mockStockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1000000)
        ]

        // When: ViewModel 초기화
        let viewModel = TradingJournalViewModel(
            repository: mockJournalRepository,
            stockRepository: mockStockRepository
        )

        // Then: 초기화 시 자동으로 포트폴리오 종목 조회
        XCTAssertEqual(viewModel.portfolioStocks.count, 1)
        XCTAssertEqual(viewModel.portfolioStocks[0], "삼성전자")
    }

    // MARK: - StockRepository 의존성 주입 테스트

    func testViewModel_HasStockRepositoryDependency() {
        // Then: TradingJournalViewModel이 StockRepository를 의존성으로 갖고 있음
        XCTAssertNotNil(sut)
        // 내부적으로 stockRepository가 주입되었는지 확인 (portfolioStocks 조회 가능)
        sut.fetchPortfolioStocks()
        // 에러 없이 실행되면 성공
    }

    // MARK: - 데이터 동기화 테스트

    func testFetchPortfolioStocks_UpdatesPublishedProperty() {
        // Given: 포트폴리오 종목 변경
        mockStockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1000000)
        ]
        sut.fetchPortfolioStocks()
        XCTAssertEqual(sut.portfolioStocks.count, 1)

        // When: 포트폴리오에 종목 추가 후 다시 조회
        mockStockRepository.stocks.append(
            StockHoldingEntity(stockName: "NAVER", purchaseAmount: 500000)
        )
        sut.fetchPortfolioStocks()

        // Then: portfolioStocks가 업데이트됨
        XCTAssertEqual(sut.portfolioStocks.count, 2)
        XCTAssertTrue(sut.portfolioStocks.contains("NAVER"))
    }

    // MARK: - Edge Case 테스트

    func testFetchPortfolioStocks_WithSpecialCharacters() {
        // Given: 특수문자가 포함된 종목명
        mockStockRepository.stocks = [
            StockHoldingEntity(stockName: "삼성SDI", purchaseAmount: 1000000),
            StockHoldingEntity(stockName: "LG에너지솔루션", purchaseAmount: 500000)
        ]

        // When: 포트폴리오 종목 조회
        sut.fetchPortfolioStocks()

        // Then: 특수문자 포함 종목명도 정상 반환
        XCTAssertEqual(sut.portfolioStocks.count, 2)
        XCTAssertTrue(sut.portfolioStocks.contains("삼성SDI"))
        XCTAssertTrue(sut.portfolioStocks.contains("LG에너지솔루션"))
    }

    func testFetchPortfolioStocks_WithEmptyStockName() {
        // Given: 빈 종목명이 있는 경우 (비정상 데이터)
        mockStockRepository.stocks = [
            StockHoldingEntity(stockName: "", purchaseAmount: 1000000),
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 500000)
        ]

        // When: 포트폴리오 종목 조회
        sut.fetchPortfolioStocks()

        // Then: 빈 종목명은 필터링됨
        XCTAssertEqual(sut.portfolioStocks.count, 1)
        XCTAssertEqual(sut.portfolioStocks[0], "삼성전자")
    }

    // MARK: - 성능 테스트

    func testFetchPortfolioStocks_Performance() {
        // Given: 많은 수의 종목
        for i in 1...100 {
            mockStockRepository.stocks.append(
                StockHoldingEntity(stockName: "종목\(i)", purchaseAmount: 1000000)
            )
        }

        // When & Then: 성능 측정
        measure {
            sut.fetchPortfolioStocks()
        }

        XCTAssertEqual(sut.portfolioStocks.count, 100)
    }
}
