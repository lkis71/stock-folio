import XCTest
@testable import StockFolio

/// Portfolio 계산 로직 테스트
final class PortfolioTests: XCTestCase {

    // MARK: - Total Invested Amount Tests

    func test_totalInvestedAmount_withMultipleHoldings_shouldSumCorrectly() {
        // Given
        let holdings = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 1_000_000),
            StockHoldingEntity(stockName: "SK하이닉스", purchaseAmount: 2_000_000),
            StockHoldingEntity(stockName: "카카오", purchaseAmount: 3_000_000)
        ]
        let portfolio = Portfolio(holdings: holdings, seedMoney: 10_000_000)

        // When
        let total = portfolio.totalInvestedAmount

        // Then
        XCTAssertEqual(total, 6_000_000)
    }

    func test_totalInvestedAmount_withEmptyHoldings_shouldReturnZero() {
        // Given
        let portfolio = Portfolio(holdings: [], seedMoney: 10_000_000)

        // When
        let total = portfolio.totalInvestedAmount

        // Then
        XCTAssertEqual(total, 0)
    }

    // MARK: - Remaining Cash Tests

    func test_remainingCash_shouldCalculateCorrectly() {
        // Given
        let holdings = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 3_000_000)
        ]
        let portfolio = Portfolio(holdings: holdings, seedMoney: 10_000_000)

        // When
        let remaining = portfolio.remainingCash

        // Then
        XCTAssertEqual(remaining, 7_000_000)
    }

    func test_remainingCash_whenOverInvested_shouldReturnZero() {
        // Given
        let holdings = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 15_000_000)
        ]
        let portfolio = Portfolio(holdings: holdings, seedMoney: 10_000_000)

        // When
        let remaining = portfolio.remainingCash

        // Then
        XCTAssertEqual(remaining, 0)
    }

    // MARK: - Invested Percentage Tests

    func test_investedPercentage_shouldCalculateCorrectly() {
        // Given
        let holdings = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 5_000_000)
        ]
        let portfolio = Portfolio(holdings: holdings, seedMoney: 10_000_000)

        // When
        let percentage = portfolio.investedPercentage

        // Then
        XCTAssertEqual(percentage, 50.0, accuracy: 0.01)
    }

    func test_investedPercentage_withZeroSeedMoney_shouldReturnZero() {
        // Given
        let holdings = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 5_000_000)
        ]
        let portfolio = Portfolio(holdings: holdings, seedMoney: 0)

        // When
        let percentage = portfolio.investedPercentage

        // Then
        XCTAssertEqual(percentage, 0)
    }

    func test_investedPercentage_whenOverInvested_shouldCapAt100() {
        // Given
        let holdings = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 15_000_000)
        ]
        let portfolio = Portfolio(holdings: holdings, seedMoney: 10_000_000)

        // When
        let percentage = portfolio.investedPercentage

        // Then
        XCTAssertEqual(percentage, 100.0)
    }

    // MARK: - Cash Percentage Tests

    func test_cashPercentage_shouldCalculateCorrectly() {
        // Given
        let holdings = [
            StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 3_000_000)
        ]
        let portfolio = Portfolio(holdings: holdings, seedMoney: 10_000_000)

        // When
        let percentage = portfolio.cashPercentage

        // Then
        XCTAssertEqual(percentage, 70.0, accuracy: 0.01)
    }

    // MARK: - Holding Percentage Tests

    func test_percentageForHolding_shouldCalculateCorrectly() {
        // Given
        let stock1 = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 4_000_000)
        let stock2 = StockHoldingEntity(stockName: "SK하이닉스", purchaseAmount: 6_000_000)
        let portfolio = Portfolio(holdings: [stock1, stock2], seedMoney: 20_000_000)

        // When
        let percentage1 = portfolio.percentage(for: stock1)
        let percentage2 = portfolio.percentage(for: stock2)

        // Then
        XCTAssertEqual(percentage1, 40.0, accuracy: 0.01)
        XCTAssertEqual(percentage2, 60.0, accuracy: 0.01)
    }

    func test_percentageForHolding_withZeroTotal_shouldReturnZero() {
        // Given
        let stock = StockHoldingEntity(stockName: "삼성전자", purchaseAmount: 0)
        let portfolio = Portfolio(holdings: [stock], seedMoney: 10_000_000)

        // When
        let percentage = portfolio.percentage(for: stock)

        // Then
        XCTAssertEqual(percentage, 0)
    }
}
