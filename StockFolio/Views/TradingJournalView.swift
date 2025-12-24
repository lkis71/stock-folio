import SwiftUI

enum TradingViewMode: String, CaseIterable {
    case calendar = "캘린더"
    case list = "리스트"

    var icon: String {
        switch self {
        case .calendar: return "calendar"
        case .list: return "list.bullet"
        }
    }
}

struct TradingJournalView: View {
    @StateObject private var listViewModel = TradingJournalViewModel()
    @State private var selectedMode: TradingViewMode = .calendar
    @State private var showingAddJournal = false
    @Namespace private var tabAnimation

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 커스텀 탭 선택
                viewModeSelector
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                // 선택된 뷰 표시 - ZStack으로 위치 고정
                ZStack {
                    TradingCalendarView()
                        .opacity(selectedMode == .calendar ? 1 : 0)
                        .allowsHitTesting(selectedMode == .calendar)

                    TradingJournalListView(viewModel: listViewModel)
                        .opacity(selectedMode == .list ? 1 : 0)
                        .allowsHitTesting(selectedMode == .list)
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
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddJournal) {
                AddTradingJournalView(viewModel: listViewModel)
            }
        }
    }

    // MARK: - View Mode Selector

    private var viewModeSelector: some View {
        HStack(spacing: 0) {
            ForEach(TradingViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .medium))

                        Text(mode.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedMode == mode ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if selectedMode == mode {
                            Capsule()
                                .fill(Color.accentColor)
                                .matchedGeometryEffect(id: "TAB", in: tabAnimation)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationView {
        TradingJournalView()
    }
}
