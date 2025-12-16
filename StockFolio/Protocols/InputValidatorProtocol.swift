import Foundation

/// 입력 검증 에러 타입
enum ValidationError: Error, Equatable {
    case empty
    case tooLong(max: Int)
    case invalidCharacters
    case negativeAmount
    case overflow
    case invalidFormat
}

/// 입력 검증 프로토콜 (SRP - 단일 책임 원칙)
/// 입력 검증만 담당합니다.
protocol InputValidatorProtocol {
    func validateStockName(_ name: String) -> Result<String, ValidationError>
    func validateAmount(_ amount: Double) -> Result<Double, ValidationError>
    func validateAmountString(_ amountString: String) -> Result<Double, ValidationError>
}
