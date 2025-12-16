import XCTest
@testable import StockFolio

/// InputValidator TDD 테스트 (보안 테스트 포함)
/// RED Phase: 이 테스트들은 구현이 없으므로 실패해야 합니다.
final class InputValidatorTests: XCTestCase {

    // MARK: - Properties
    private var sut: StockInputValidator!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        sut = StockInputValidator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Stock Name Validation Tests

    func test_validateStockName_withValidName_shouldReturnSuccess() {
        // Given
        let validName = "삼성전자"

        // When
        let result = sut.validateStockName(validName)

        // Then
        switch result {
        case .success(let name):
            XCTAssertEqual(name, "삼성전자")
        case .failure:
            XCTFail("Should succeed with valid name")
        }
    }

    func test_validateStockName_withEmptyString_shouldReturnFailure() {
        // Given
        let emptyName = ""

        // When
        let result = sut.validateStockName(emptyName)

        // Then
        switch result {
        case .success:
            XCTFail("Should fail with empty name")
        case .failure(let error):
            XCTAssertEqual(error, .empty)
        }
    }

    func test_validateStockName_withWhitespaceOnly_shouldReturnFailure() {
        // Given
        let whitespaceName = "   "

        // When
        let result = sut.validateStockName(whitespaceName)

        // Then
        switch result {
        case .success:
            XCTFail("Should fail with whitespace only")
        case .failure(let error):
            XCTAssertEqual(error, .empty)
        }
    }

    func test_validateStockName_withTooLongName_shouldReturnFailure() {
        // Given
        let longName = String(repeating: "가", count: 51)

        // When
        let result = sut.validateStockName(longName)

        // Then
        switch result {
        case .success:
            XCTFail("Should fail with too long name")
        case .failure(let error):
            XCTAssertEqual(error, .tooLong(max: 50))
        }
    }

    // MARK: - Security Tests (SQL Injection, XSS)

    func test_validateStockName_withSQLInjection_shouldReturnFailure() {
        // Given
        let sqlInjection = "'; DROP TABLE stocks;--"

        // When
        let result = sut.validateStockName(sqlInjection)

        // Then
        switch result {
        case .success:
            XCTFail("Should reject SQL injection attempt")
        case .failure(let error):
            XCTAssertEqual(error, .invalidCharacters)
        }
    }

    func test_validateStockName_withXSSAttempt_shouldReturnFailure() {
        // Given
        let xssAttempt = "<script>alert('xss')</script>"

        // When
        let result = sut.validateStockName(xssAttempt)

        // Then
        switch result {
        case .success:
            XCTFail("Should reject XSS attempt")
        case .failure(let error):
            XCTAssertEqual(error, .invalidCharacters)
        }
    }

    func test_validateStockName_withSpecialCharacters_shouldReturnFailure() {
        // Given
        let specialChars = "삼성전자@#$%"

        // When
        let result = sut.validateStockName(specialChars)

        // Then
        switch result {
        case .success:
            XCTFail("Should reject special characters")
        case .failure(let error):
            XCTAssertEqual(error, .invalidCharacters)
        }
    }

    // MARK: - Amount Validation Tests

    func test_validateAmount_withValidAmount_shouldReturnSuccess() {
        // Given
        let validAmount = 1_000_000.0

        // When
        let result = sut.validateAmount(validAmount)

        // Then
        switch result {
        case .success(let amount):
            XCTAssertEqual(amount, 1_000_000.0)
        case .failure:
            XCTFail("Should succeed with valid amount")
        }
    }

    func test_validateAmount_withZero_shouldReturnFailure() {
        // Given
        let zeroAmount = 0.0

        // When
        let result = sut.validateAmount(zeroAmount)

        // Then
        switch result {
        case .success:
            XCTFail("Should fail with zero amount")
        case .failure(let error):
            XCTAssertEqual(error, .negativeAmount)
        }
    }

    func test_validateAmount_withNegative_shouldReturnFailure() {
        // Given
        let negativeAmount = -1_000_000.0

        // When
        let result = sut.validateAmount(negativeAmount)

        // Then
        switch result {
        case .success:
            XCTFail("Should fail with negative amount")
        case .failure(let error):
            XCTAssertEqual(error, .negativeAmount)
        }
    }

    func test_validateAmount_withOverflow_shouldReturnFailure() {
        // Given
        let overflowAmount = Double.greatestFiniteMagnitude

        // When
        let result = sut.validateAmount(overflowAmount)

        // Then
        switch result {
        case .success:
            XCTFail("Should fail with overflow amount")
        case .failure(let error):
            XCTAssertEqual(error, .overflow)
        }
    }

    // MARK: - Amount String Validation Tests

    func test_validateAmountString_withValidString_shouldReturnSuccess() {
        // Given
        let validString = "1,000,000"

        // When
        let result = sut.validateAmountString(validString)

        // Then
        switch result {
        case .success(let amount):
            XCTAssertEqual(amount, 1_000_000.0)
        case .failure:
            XCTFail("Should succeed with valid string")
        }
    }

    func test_validateAmountString_withInvalidFormat_shouldReturnFailure() {
        // Given
        let invalidString = "abc"

        // When
        let result = sut.validateAmountString(invalidString)

        // Then
        switch result {
        case .success:
            XCTFail("Should fail with invalid format")
        case .failure(let error):
            XCTAssertEqual(error, .invalidFormat)
        }
    }
}
