import Foundation
import SwiftUI

/// 종목 보유 엔티티 (Model - 데이터만 표현)
struct StockHoldingEntity: Identifiable, Equatable {
    let id: UUID
    var stockName: String
    var quantity: Int
    var averagePrice: Double
    var colorName: String
    let createdAt: Date

    /// 총 투자금액 (수량 × 평균매입가)
    var purchaseAmount: Double {
        Double(quantity) * averagePrice
    }

    init(
        id: UUID = UUID(),
        stockName: String,
        quantity: Int = 0,
        averagePrice: Double = 0,
        colorName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.stockName = stockName
        self.quantity = quantity
        self.averagePrice = averagePrice
        // 색상이 지정되지 않으면 종목명 기반 해시 색상 사용
        self.colorName = colorName ?? StockColor.fromStockName(stockName).rawValue
        self.createdAt = createdAt
    }

    /// 레거시 호환용 생성자 (직접 금액 입력 시 사용)
    init(
        id: UUID = UUID(),
        stockName: String,
        purchaseAmount: Double,
        colorName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.stockName = stockName
        self.quantity = 1
        self.averagePrice = purchaseAmount
        // 색상이 지정되지 않으면 종목명 기반 해시 색상 사용
        self.colorName = colorName ?? StockColor.fromStockName(stockName).rawValue
        self.createdAt = createdAt
    }

    var color: Color {
        StockColor(rawValue: colorName)?.color ?? .blue
    }
}

// MARK: - Stock Colors
enum StockColor: String, CaseIterable {
    // 기본 10색
    case blue, green, orange, purple, pink
    case cyan, indigo, mint, teal, red
    // 확장 10색
    case coral, lavender, amber, emerald, navy
    case salmon, olive, maroon, gold, slate

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
        // 확장 색상
        case .coral: return Color(red: 1.0, green: 0.5, blue: 0.31)
        case .lavender: return Color(red: 0.71, green: 0.49, blue: 0.86)
        case .amber: return Color(red: 1.0, green: 0.75, blue: 0.0)
        case .emerald: return Color(red: 0.31, green: 0.78, blue: 0.47)
        case .navy: return Color(red: 0.0, green: 0.0, blue: 0.5)
        case .salmon: return Color(red: 0.98, green: 0.5, blue: 0.45)
        case .olive: return Color(red: 0.5, green: 0.5, blue: 0.0)
        case .maroon: return Color(red: 0.5, green: 0.0, blue: 0.0)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .slate: return Color(red: 0.44, green: 0.5, blue: 0.56)
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
        // 확장 색상
        case .coral: return "코랄"
        case .lavender: return "라벤더"
        case .amber: return "앰버"
        case .emerald: return "에메랄드"
        case .navy: return "네이비"
        case .salmon: return "살몬"
        case .olive: return "올리브"
        case .maroon: return "마룬"
        case .gold: return "골드"
        case .slate: return "슬레이트"
        }
    }

    /// 밝은 색상인지 판단 (접근성을 위한 체크마크 색상 결정용)
    /// 다크 모드에서 밝아지는 색상들은 검은색 체크마크 사용
    var isLightColor: Bool {
        switch self {
        case .mint, .cyan, .pink, .amber, .gold, .salmon:
            return true
        case .blue, .green, .orange, .purple, .indigo, .teal, .red,
             .coral, .lavender, .emerald, .navy, .olive, .maroon, .slate:
            return false
        }
    }

    static var random: StockColor {
        allCases.randomElement() ?? .blue
    }

    /// 종목명 기반 해시 색상 (동일 종목은 항상 같은 색상)
    static func fromStockName(_ name: String) -> StockColor {
        let hash = abs(name.hashValue)
        let index = hash % allCases.count
        return allCases[index]
    }

    /// 순서(인덱스) 기반 색상 (비중 순서대로 색상 할당)
    static func fromIndex(_ index: Int) -> StockColor {
        let safeIndex = index % allCases.count
        return allCases[safeIndex]
    }
}
