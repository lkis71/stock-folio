import Foundation

/// 입력 검증기 (SRP - 입력 검증만 담당)
/// 보안: SQL Injection, XSS 등 악의적인 입력을 방지합니다.
final class StockInputValidator: InputValidatorProtocol {

    private let maxNameLength = 50
    private let maxAmount: Double = 999_999_999_999

    // 허용된 문자: 한글, 영문, 숫자, 공백만 허용
    private let allowedCharacterSet: CharacterSet = {
        var set = CharacterSet.alphanumerics
        set.insert(charactersIn: " ")
        // 한글 범위 추가
        set.insert(charactersIn: "\u{AC00}"..."\u{D7A3}")  // 가-힣
        set.insert(charactersIn: "\u{1100}"..."\u{11FF}")  // 한글 자모
        return set
    }()

    func validateStockName(_ name: String) -> Result<String, ValidationError> {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        // 빈 문자열 검사
        guard !trimmed.isEmpty else {
            return .failure(.empty)
        }

        // 길이 검사
        guard trimmed.count <= maxNameLength else {
            return .failure(.tooLong(max: maxNameLength))
        }

        // 특수문자 검사 (SQL Injection, XSS 방지)
        for scalar in trimmed.unicodeScalars {
            if !allowedCharacterSet.contains(scalar) {
                return .failure(.invalidCharacters)
            }
        }

        return .success(trimmed)
    }

    func validateAmount(_ amount: Double) -> Result<Double, ValidationError> {
        // 0 이하 검사
        guard amount > 0 else {
            return .failure(.negativeAmount)
        }

        // 오버플로우 검사
        guard amount <= maxAmount, amount.isFinite else {
            return .failure(.overflow)
        }

        return .success(amount)
    }

    func validateAmountString(_ amountString: String) -> Result<Double, ValidationError> {
        // 콤마 제거 및 파싱
        let cleaned = amountString.replacingOccurrences(of: ",", with: "")

        guard let amount = Double(cleaned) else {
            return .failure(.invalidFormat)
        }

        return validateAmount(amount)
    }
}
