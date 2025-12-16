import Foundation

/// 포트폴리오 계산 모델 (SRP - 포트폴리오 계산만 담당)
struct Portfolio {
    let holdings: [StockHoldingEntity]
    let seedMoney: Double

    var totalInvestedAmount: Double {
        holdings.reduce(0) { $0 + $1.purchaseAmount }
    }

    var remainingCash: Double {
        max(0, seedMoney - totalInvestedAmount)
    }

    var investedPercentage: Double {
        guard seedMoney > 0 else { return 0 }
        return min(100, (totalInvestedAmount / seedMoney) * 100)
    }

    var cashPercentage: Double {
        guard seedMoney > 0 else { return 0 }
        return max(0, 100 - investedPercentage)
    }

    func percentage(for holding: StockHoldingEntity) -> Double {
        guard totalInvestedAmount > 0 else { return 0 }
        return (holding.purchaseAmount / totalInvestedAmount) * 100
    }
}
