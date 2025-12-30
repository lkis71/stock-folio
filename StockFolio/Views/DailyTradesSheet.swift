import SwiftUI

struct DailyTradesSheet: View {
    let summary: DailyTradingSummary

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TradingJournalViewModel()
    @State private var selectedJournal: TradingJournalEntity?

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: summary.date)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 일일 요약 카드
                    dailySummaryCard

                    // 거래 내역
                    tradeListSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(dateString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton { dismiss() }
                }
            }
            .sheet(item: $selectedJournal) { journal in
                AddTradingJournalView(viewModel: viewModel, editingJournal: journal)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Daily Summary Card

    private var dailySummaryCard: some View {
        VStack(spacing: 12) {
            // 상단: 손익 + 수익률
            HStack(spacing: 16) {
                // 일일 손익
                VStack(alignment: .leading, spacing: 4) {
                    Text("일일 손익")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text(formattedProfit(summary.totalProfit))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(summary.hasProfit ? .red : .blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 수익률
                VStack(alignment: .leading, spacing: 4) {
                    Text("수익률")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text(formattedRate(summary.profitRate))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(summary.hasProfit ? .red : .blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            // 하단: 거래 건수
            HStack {
                Text("거래")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Spacer()

                HStack(spacing: 12) {
                    Label("\(buyCount)", systemImage: "arrow.down.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)

                    Label("\(sellCount)", systemImage: "arrow.up.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Trade List Section

    private var tradeListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 섹션 헤더
            Text("거래 내역")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.leading, 4)

            // 거래 목록 카드
            VStack(spacing: 0) {
                ForEach(Array(summary.trades.sorted(by: { $0.tradeDate > $1.tradeDate }).enumerated()), id: \.element.id) { index, trade in
                    VStack(spacing: 0) {
                        TradingJournalCardView(journal: trade)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedJournal = trade
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)

                        // 구분선 (마지막 항목 제외)
                        if index < summary.trades.count - 1 {
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
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
