import Foundation

/// 시드머니 저장소 (SRP - 시드머니 저장만 담당)
/// 주의: 시드머니는 민감한 금융 정보가 아니므로 UserDefaults 사용 가능
final class SeedMoneyStorage: SeedMoneyStorageProtocol {

    private let seedMoneyKey = "seedMoney"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getSeedMoney() -> Double {
        return defaults.double(forKey: seedMoneyKey)
    }

    func saveSeedMoney(_ amount: Double) {
        defaults.set(amount, forKey: seedMoneyKey)
    }
}
