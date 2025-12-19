import XCTest
@testable import StockFolio

/// TradingJournalEntity Model Tests
/// Following TDD Red-Green-Refactor cycle
final class TradingJournalEntityTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_withAllParameters_shouldCreateEntity() {
        // Given
        let id = UUID()
        let tradeType = TradeType.buy
        let tradeDate = Date()
        let stockName = "삼성전자"
        let quantity = 10
        let price = 70000.0
        let reason = "기술적 매수 신호"

        // When
        let entity = TradingJournalEntity(
            id: id,
            tradeType: tradeType,
            tradeDate: tradeDate,
            stockName: stockName,
            quantity: quantity,
            price: price,
            reason: reason
        )

        // Then
        XCTAssertEqual(entity.id, id)
        XCTAssertEqual(entity.tradeType, tradeType)
        XCTAssertEqual(entity.tradeDate, tradeDate)
        XCTAssertEqual(entity.stockName, stockName)
        XCTAssertEqual(entity.quantity, quantity)
        XCTAssertEqual(entity.price, price)
        XCTAssertEqual(entity.reason, reason)
    }

    func test_init_withDefaultParameters_shouldCreateEntity() {
        // Given
        let tradeType = TradeType.sell
        let tradeDate = Date()
        let stockName = "SK하이닉스"
        let quantity = 5
        let price = 120000.0

        // When
        let entity = TradingJournalEntity(
            tradeType: tradeType,
            tradeDate: tradeDate,
            stockName: stockName,
            quantity: quantity,
            price: price
        )

        // Then
        XCTAssertNotNil(entity.id)
        XCTAssertEqual(entity.tradeType, tradeType)
        XCTAssertEqual(entity.stockName, stockName)
        XCTAssertEqual(entity.quantity, quantity)
        XCTAssertEqual(entity.price, price)
        XCTAssertEqual(entity.reason, "")
    }

    // MARK: - Computed Property Tests

    func test_totalAmount_shouldCalculateCorrectly() {
        // Given
        let entity = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 10,
            price: 70000.0
        )

        // When
        let totalAmount = entity.totalAmount

        // Then
        XCTAssertEqual(totalAmount, 700000.0, accuracy: 0.01)
    }

    func test_totalAmount_withZeroQuantity_shouldReturnZero() {
        // Given
        let entity = TradingJournalEntity(
            tradeType: .buy,
            tradeDate: Date(),
            stockName: "삼성전자",
            quantity: 0,
            price: 70000.0
        )

        // When
        let totalAmount = entity.totalAmount

        // Then
        XCTAssertEqual(totalAmount, 0)
    }

    // MARK: - TradeType Tests

    func test_tradeType_buy_shouldHaveGreenColor() {
        // When
        let color = TradeType.buy.color

        // Then
        XCTAssertEqual(color, "green")
    }

    func test_tradeType_sell_shouldHaveRedColor() {
        // When
        let color = TradeType.sell.color

        // Then
        XCTAssertEqual(color, "red")
    }

    func test_tradeType_rawValue_shouldMatchKoreanText() {
        // Then
        XCTAssertEqual(TradeType.buy.rawValue, "매수")
        XCTAssertEqual(TradeType.sell.rawValue, "매도")
    }

    func test_tradeType_allCases_shouldContainBothTypes() {
        // When
        let allCases = TradeType.allCases

        // Then
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.buy))
        XCTAssertTrue(allCases.contains(.sell))
    }
}
