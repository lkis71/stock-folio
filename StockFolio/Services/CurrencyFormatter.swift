import Foundation

/// 통화 포맷터 (SRP - 통화 포맷팅만 담당)
final class CurrencyFormatter: CurrencyFormatterProtocol {

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    private let plainFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    func format(_ amount: Double) -> String {
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }

    func formatWithoutSymbol(_ amount: Double) -> String {
        return plainFormatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

// MARK: - Double Extension for convenience
extension Double {
    var currencyFormatted: String {
        CurrencyFormatter().format(self)
    }
}
