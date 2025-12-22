import Foundation
import CoreData

struct TradingJournalFilter {
    let filterType: FilterType
    let date: Date?
    let year: Int?
    let month: Int?
    let stockName: String?

    func toPredicate() -> NSPredicate? {
        var predicates: [NSPredicate] = []

        // filterType별 날짜 필터
        let calendar = Calendar.current
        switch filterType {
        case .daily:
            if let date = date {
                let startOfDay = calendar.startOfDay(for: date)
                guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                    break
                }
                predicates.append(NSPredicate(format: "tradeDate >= %@ AND tradeDate < %@", startOfDay as NSDate, endOfDay as NSDate))
            }
        case .monthly:
            if let year = year, let month = month {
                var components = DateComponents()
                components.year = year
                components.month = month
                components.day = 1

                guard let startDate = calendar.date(from: components),
                      let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
                    break
                }
                predicates.append(NSPredicate(format: "tradeDate >= %@ AND tradeDate < %@", startDate as NSDate, endDate as NSDate))
            }
        case .yearly:
            if let year = year {
                var components = DateComponents()
                components.year = year
                components.month = 1
                components.day = 1

                guard let startDate = calendar.date(from: components),
                      let endDate = calendar.date(byAdding: .year, value: 1, to: startDate) else {
                    break
                }
                predicates.append(NSPredicate(format: "tradeDate >= %@ AND tradeDate < %@", startDate as NSDate, endDate as NSDate))
            }
        case .all:
            break
        }

        // stockName 필터
        if let stockName = stockName, !stockName.isEmpty {
            predicates.append(NSPredicate(format: "stockName == %@", stockName))
        }

        return predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
