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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
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

            Section(header: Text("매매 기록")) {
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
            }
        }
    }
}

struct TradingJournalStatsView: View {
    @ObservedObject var viewModel: TradingJournalViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                StatCardView(
                    title: "총 매매",
                    value: "\(viewModel.totalTradeCount)건",
                    color: .blue
                )

                StatCardView(
                    title: "매수",
                    value: "\(viewModel.buyTradeCount)건",
                    color: .green
                )

                StatCardView(
                    title: "매도",
                    value: "\(viewModel.sellTradeCount)건",
                    color: .red
                )
            }

            HStack(spacing: 16) {
                StatCardView(
                    title: "실현 손익",
                    value: formattedPrice(viewModel.totalRealizedProfit),
                    color: viewModel.totalRealizedProfit >= 0 ? .green : .red
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }

    private func formattedPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let sign = price >= 0 ? "+" : ""
        return sign + (formatter.string(from: NSNumber(value: price)) ?? "0") + "원"
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(journal.stockName)
                    .font(.headline)

                Spacer()

                Text(journal.tradeType.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tradeTypeColor.opacity(0.2))
                    .foregroundColor(tradeTypeColor)
                    .cornerRadius(8)
            }

            HStack {
                Text(formatter.string(from: journal.tradeDate))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(journal.quantity)주 × \(formattedPrice(journal.price))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("\(formattedPrice(journal.totalAmount))")
                .font(.title3)
                .fontWeight(.bold)

            if !journal.reason.isEmpty {
                Text(journal.reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private var tradeTypeColor: Color {
        journal.tradeType == .buy ? .green : .red
    }

    private func formattedPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return (formatter.string(from: NSNumber(value: price)) ?? "0") + "원"
    }
}

#Preview {
    TradingJournalListView()
}
