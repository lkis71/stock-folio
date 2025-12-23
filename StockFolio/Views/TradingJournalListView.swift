import SwiftUI

struct TradingJournalListView: View {
    @StateObject private var viewModel = TradingJournalViewModel()
    @State private var showingAddJournal = false
    @State private var selectedJournal: TradingJournalEntity?
    @State private var showingFilterSheet = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.journals.isEmpty {
                    emptyStateView
                } else {
                    journalListView
                }
            }
            .onAppear {
                print("📊 [TradingJournalListView] journals.count: \(viewModel.journals.count), totalCount: \(viewModel.totalTradeCount), hasMore: \(viewModel.hasMore)")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingFilterSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            if !viewModel.selectedStockName.isEmpty {
                                Text(viewModel.selectedStockName)
                                    .font(.caption)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddJournal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddJournal) {
                AddTradingJournalView(viewModel: viewModel)
            }
            .sheet(item: $selectedJournal) { journal in
                AddTradingJournalView(viewModel: viewModel, editingJournal: journal)
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetView(viewModel: viewModel)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("매매 일지가 없습니다")
                .font(.title3)
                .fontWeight(.medium)

            Text("+ 버튼을 눌러 첫 매매 기록을 남겨보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var journalListView: some View {
        List {
            Section {
                TradingJournalStatsView(viewModel: viewModel)
            }

            Section(header: sectionHeader) {
                ForEach(viewModel.journals) { journal in
                    TradingJournalCardView(journal: journal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedJournal = journal
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if let index = viewModel.journals.firstIndex(where: { $0.id == journal.id }) {
                                    viewModel.deleteJournals(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }

                // 로딩 인디케이터
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                // 더보기 버튼 (수동 로드 옵션)
                if viewModel.hasMore && !viewModel.isLoading {
                    Button {
                        viewModel.fetchMore()
                    } label: {
                        HStack {
                            Spacer()
                            Text("↓ 더보기")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }

                // 접기 버튼
                if !viewModel.hasMore && viewModel.journals.count > 10 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.collapseToInitial()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("↑ 접기")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            if viewModel.totalTradeCount > 20 {
                Text("매매 기록 (\(viewModel.journals.count)/\(viewModel.totalTradeCount))")
            } else {
                Text("매매 기록")
            }
        }
    }
}

struct TradingJournalStatsView: View {
    @ObservedObject var viewModel: TradingJournalViewModel

    private var profitColor: Color {
        viewModel.totalRealizedProfit >= 0 ? .red : .blue
    }

    var body: some View {
        VStack(spacing: 6) {
            // 실현 손익 (위)
            HStack {
                Text("실현 손익")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formattedProfitWithRate)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(profitColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            // 매매 통계 (아래)
            HStack(spacing: 0) {
                StatBadge(label: "총", value: viewModel.totalTradeCount, color: .blue)
                Spacer()
                StatBadge(label: "매수", value: viewModel.buyTradeCount, color: .green)
                Spacer()
                StatBadge(label: "매도", value: viewModel.sellTradeCount, color: .red)
            }
        }
        .padding(.vertical, 2)
    }

    private var formattedProfitWithRate: String {
        let priceStr = formattedPrice(viewModel.totalRealizedProfit)
        if viewModel.sellTradeCount > 0 {
            return "\(priceStr) (\(formattedRate(viewModel.totalProfitRate)))"
        }
        return priceStr
    }

    private func formattedPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let sign = price >= 0 ? "+" : ""
        return sign + (formatter.string(from: NSNumber(value: price)) ?? "0") + "원"
    }

    private func formattedRate(_ rate: Double) -> String {
        let sign = rate >= 0 ? "+" : ""
        return sign + String(format: "%.1f", rate) + "%"
    }
}

struct StatBadge: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct TradingJournalCardView: View {
    let journal: TradingJournalEntity

    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 헤더: 종목명 + 날짜 + 매매 유형
            HStack {
                Text(journal.stockName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(formatter.string(from: journal.tradeDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text(journal.tradeType.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(tradeTypeColor.opacity(0.15))
                    .foregroundColor(tradeTypeColor)
                    .cornerRadius(4)
            }

            // 수량×단가 + 매매금액
            HStack {
                Text("\(journal.quantity)주 × \(formattedPrice(journal.price))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(formattedPrice(journal.totalAmount))
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            // 매도 시 실현손익 + 수익률 표시
            if journal.tradeType == .sell {
                HStack(spacing: 8) {
                    Text("손익")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(formattedProfit(journal.realizedProfit)) (\(formattedProfitRate))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(profitColor)
                }
            }

            // 매매 이유
            if !journal.reason.isEmpty {
                Text(journal.reason)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }

    private var tradeTypeColor: Color {
        journal.tradeType == .buy ? .green : .red
    }

    private var profitColor: Color {
        journal.realizedProfit >= 0 ? .red : .blue
    }

    private var profitRate: Double {
        let investedAmount = journal.totalAmount - journal.realizedProfit
        guard investedAmount > 0 else { return 0 }
        return (journal.realizedProfit / investedAmount) * 100
    }

    private var formattedProfitRate: String {
        let rate = profitRate
        let sign = rate >= 0 ? "+" : ""
        return sign + String(format: "%.1f", rate) + "%"
    }

    private func formattedPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return (formatter.string(from: NSNumber(value: price)) ?? "0") + "원"
    }

    private func formattedProfit(_ profit: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let sign = profit >= 0 ? "+" : ""
        return sign + (formatter.string(from: NSNumber(value: profit)) ?? "0") + "원"
    }
}

#Preview {
    TradingJournalListView()
}
