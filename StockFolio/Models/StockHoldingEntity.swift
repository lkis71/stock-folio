import Foundation
import SwiftUI

/// 종목 보유 엔티티 (Model - 데이터만 표현)
struct StockHoldingEntity: Identifiable, Equatable {
    let id: UUID
    var stockName: String
    var purchaseAmount: Double
    var colorName: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        stockName: String,
        purchaseAmount: Double,
        colorName: String = StockColor.random.rawValue,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.stockName = stockName
        self.purchaseAmount = purchaseAmount
        self.colorName = colorName
        self.createdAt = createdAt
    }

    var color: Color {
        StockColor(rawValue: colorName)?.color ?? .blue
    }
}

// MARK: - Stock Colors
enum StockColor: String, CaseIterable {
    case blue, green, orange, purple, pink
    case cyan, indigo, mint, teal, red

    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        case .cyan: return .cyan
        case .indigo: return .indigo
        case .mint: return .mint
        case .teal: return .teal
        case .red: return .red
        }
    }

    var displayName: String {
        switch self {
        case .blue: return "파랑"
        case .green: return "초록"
        case .orange: return "주황"
        case .purple: return "보라"
        case .pink: return "분홍"
        case .cyan: return "청록"
        case .indigo: return "남색"
        case .mint: return "민트"
        case .teal: return "틸"
        case .red: return "빨강"
        }
    }

    /// 밝은 색상인지 판단 (접근성을 위한 체크마크 색상 결정용)
    /// 다크 모드에서 밝아지는 색상들은 검은색 체크마크 사용
    var isLightColor: Bool {
        switch self {
        case .mint, .cyan, .pink:
            return true
        case .blue, .green, .orange, .purple, .indigo, .teal, .red:
            return false
        }
    }

    static var random: StockColor {
        allCases.randomElement() ?? .blue
    }
}
