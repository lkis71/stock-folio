import Foundation

/// 통화 포맷터 프로토콜 (SRP - 단일 책임 원칙)
/// 통화 포맷팅만 담당합니다.
protocol CurrencyFormatterProtocol {
    func format(_ amount: Double) -> String
    func formatWithoutSymbol(_ amount: Double) -> String
}
