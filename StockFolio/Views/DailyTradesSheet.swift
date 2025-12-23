import SwiftUI

struct DailyTradesSheet: View {
    let summary: DailyTradingSummary

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TradingJournalViewModel()
    @State private var selectedJournal: TradingJournalEntity?

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: summary.date)
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    // 일일 요약
                    dailySummaryView
                }

                Section(header: Text("거래 내역 (\(summary.tradeCount)건)")) {
                    ForEach(summary.trades.sorted(by: { $0.tradeDate > $1.tradeDate })) { trade in
                        TradingJournalCardView(journal: trade)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedJournal = trade
                            }
                    }
                }
            }
            .navigationTitle(dateString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(item: $selectedJournal) { journal in
                AddTradingJournalView(viewModel: viewModel, editingJournal: journal)
            }
        }
    }

    // MARK: - Daily Summary View

    private var dailySummaryView: some View {
        VStack(spacing: 8) {
            // 손익
            HStack {
                Text("일일 손익")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(formattedProfit(summary.totalProfit))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(summary.hasProfit ? .red : .blue)
            }

            // 수익률
            if abs(summary.profitRate) >= 0.1 {
                HStack {
                    Text("수익률")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(formattedRate(summary.profitRate))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(summary.hasProfit ? .red : .blue)
                }
            }

            // 거래 건수
            HStack {
                Text("거래 건수")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 8) {
                    Text("매수 \(buyCount)건")
                        .font(.caption)
                        .foregroundColor(.green)

                    Text("매도 \(sellCount)건")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helper Properties

    private var buyCount: Int {
        summary.trades.filter { $0.tradeType == .buy }.count
    }

    private var sellCount: Int {
        summary.trades.filter { $0.tradeType == .sell }.count
    }

    // MARK: - Helper Methods

    private func formattedProfit(_ profit: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let sign = profit >= 0 ? "+" : ""
        return sign + (formatter.string(from: NSNumber(value: profit)) ?? "0") + "원"
    }

    private func formattedRate(_ rate: Double) -> String {
        let sign = rate >= 0 ? "+" : ""
        return sign + String(format: "%.1f%%", rate)
    }
}

#Preview {
    DailyTradesSheet(
        summary: DailyTradingSummary(
            date: Date(),
            tradeCount: 3,
            totalProfit: 50000,
            profitRate: 5.2,
            trades: [
                TradingJournalEntity(
                    tradeType: .buy,
                    tradeDate: Date(),
                    stockName: "삼성전자",
                    quantity: 10,
                    price: 70000,
                    reason: "기술적 반등 예상"
                ),
                TradingJournalEntity(
                    tradeType: .sell,
                    tradeDate: Date(),
                    stockName: "삼성전자",
                    quantity: 10,
                    price: 75000,
                    realizedProfit: 50000,
                    reason: "목표가 도달"
                )
            ]
        )
    )
}
