import SwiftUI

enum TradingViewMode: String, CaseIterable {
    case calendar = "캘린더"
    case list = "리스트"
}

struct TradingJournalView: View {
    @StateObject private var listViewModel = TradingJournalViewModel()
    @State private var selectedMode: TradingViewMode = .calendar
    @State private var showingAddJournal = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 뷰 모드 선택 세그먼트
                Picker("뷰 모드", selection: $selectedMode) {
                    ForEach(TradingViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                // 선택된 뷰 표시
                Group {
                    switch selectedMode {
                    case .list:
                        TradingJournalListView(viewModel: listViewModel)
                    case .calendar:
                        TradingCalendarView()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddJournal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddJournal) {
                AddTradingJournalView(viewModel: listViewModel)
            }
        }
    }
}

#Preview {
    NavigationView {
        TradingJournalView()
    }
}
