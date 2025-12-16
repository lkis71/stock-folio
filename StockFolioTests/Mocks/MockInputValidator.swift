import Foundation
@testable import StockFolio

/// 테스트용 Mock Input Validator
final class MockInputValidator: InputValidatorProtocol {
    var shouldFailNameValidation = false
    var shouldFailAmountValidation = false
    var nameValidationError: ValidationError = .empty
    var amountValidationError: ValidationError = .negativeAmount

    func validateStockName(_ name: String) -> Result<String, ValidationError> {
        if shouldFailNameValidation {
            return .failure(nameValidationError)
        }
        return .success(name.trimmingCharacters(in: .whitespaces))
    }

    func validateAmount(_ amount: Double) -> Result<Double, ValidationError> {
        if shouldFailAmountValidation {
            return .failure(amountValidationError)
        }
        return .success(amount)
    }

    func validateAmountString(_ amountString: String) -> Result<Double, ValidationError> {
        if shouldFailAmountValidation {
            return .failure(amountValidationError)
        }
        let cleaned = amountString.replacingOccurrences(of: ",", with: "")
        guard let amount = Double(cleaned) else {
            return .failure(.invalidFormat)
        }
        return .success(amount)
    }
}
