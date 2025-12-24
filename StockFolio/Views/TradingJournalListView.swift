import SwiftUI

struct TradingJournalListView: View {
    @ObservedObject var viewModel: TradingJournalViewModel
    @State private var selectedJournal: TradingJournalEntity?

    var body: some View {
        VStack(spacing: 0) {
            // 인라인 기간 필터
            VStack(spacing: 6) {
                filterPicker

                // 기간별 상세 선택
                if viewModel.filterType != .all {
                    dateSelectionView
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 0)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))

            // 데이터 영역 - 고정 높이로 레이아웃 안정화
            journalListView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            print("📊 [TradingJournalListView] journals.count: \(viewModel.journals.count), totalCount: \(viewModel.totalTradeCount), hasMore: \(viewModel.hasMore)")
        }
        .sheet(item: $selectedJournal) { journal in
            AddTradingJournalView(viewModel: viewModel, editingJournal: journal)
        }
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        Picker("기간", selection: $viewModel.filterType) {
            ForEach(FilterType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.filterType) { oldValue, newValue in
            print("📅 [Filter] Type changed: \(oldValue.rawValue) → \(newValue.rawValue)")
            viewModel.applyFilter()
        }
    }

    // MARK: - Date Selection View

    @ViewBuilder
    private var dateSelectionView: some View {
        switch viewModel.filterType {
        case .daily:
            CompactDateButton(selection: $viewModel.selectedDate) { newDate in
                print("📅 [Filter] Daily date changed: \(newDate)")
                viewModel.applyFilter()
            }

        case .monthly:
            MonthYearPicker(selection: $viewModel.selectedMonth) { newDate in
                print("📅 [Filter] Monthly date changed: \(newDate)")
                viewModel.applyFilter()
            }

        case .yearly:
            YearPicker(selection: $viewModel.selectedYear, yearRange: yearRange) { newYear in
                print("📅 [Filter] Yearly changed: \(newYear)")
                viewModel.applyFilter()
            }

        case .all:
            EmptyView()
        }
    }

    private var yearRange: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 10)...currentYear).reversed()
    }

    // MARK: - Compact Date Button (일별)

    struct CompactDateButton: View {
        @Binding var selection: Date
        let onChange: (Date) -> Void
        @State private var showingPicker = false

        private var displayText: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월 d일"
            return formatter.string(from: selection)
        }

        var body: some View {
            Button {
                showingPicker = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(displayText)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .sheet(isPresented: $showingPicker) {
                NavigationStack {
                    DatePicker(
                        "날짜 선택",
                        selection: $selection,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                    .navigationTitle("날짜 선택")
                    .navigationBarTitleDisplayMode(.inline)
                    .onChange(of: selection) { _, newValue in
                        // 날짜 선택 즉시 닫기
                        showingPicker = false
                        onChange(newValue)
                    }
                    .presentationDetents([.medium])
                }
            }
        }
    }

    // MARK: - Year Picker (연별)

    struct YearPicker: View {
        @Binding var selection: Int
        let yearRange: [Int]
        let onChange: (Int) -> Void

        var body: some View {
            Menu {
                Picker("연도", selection: $selection) {
                    ForEach(yearRange, id: \.self) { year in
                        Text(formatYear(year)).tag(year)
                    }
                }
                .onChange(of: selection) { _, newValue in
                    onChange(newValue)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatYear(selection))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }

        private func formatYear(_ year: Int) -> String {
            "\(year)년"
        }
    }

    // MARK: - Month Year Picker (월별)

    struct MonthYearPicker: View {
        @Binding var selection: Date
        let onChange: (Date) -> Void

        private var displayText: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월"
            return formatter.string(from: selection)
        }

        var body: some View {
            Menu {
                Picker("월 선택", selection: $selection) {
                    ForEach(monthYearRange, id: \.self) { date in
                        Text(formatDate(date)).tag(date)
                    }
                }
                .onChange(of: selection) { _, newValue in
                    onChange(newValue)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(displayText)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }

        private var monthYearRange: [Date] {
            let calendar = Calendar.current
            let currentDate = Date()
            var dates: [Date] = []

            // 최근 24개월 (내림차순)
            for i in 0...23 {
                if let date = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                    let components = calendar.dateComponents([.year, .month], from: date)
                    if let monthDate = calendar.date(from: components) {
                        dates.append(monthDate)
                    }
                }
            }

            return dates
        }

        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월"
            return formatter.string(from: date)
        }
    }

    private var journalListView: some View {
        List {
            Section {
                TradingJournalStatsView(viewModel: viewModel)
            }

            Section(header: sectionHeader) {
                if viewModel.journals.isEmpty {
                    // 빈 데이터 상태
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)

                        Text("등록된 매매 기록이 없습니다")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("+ 버튼을 눌러 첫 매매 기록을 남겨보세요")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(viewModel.journals) { journal in
                        TradingJournalCardView(journal: journal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedJournal = journal
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
        .listStyle(.plain)
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
    NavigationStack {
        TradingJournalListView(viewModel: TradingJournalViewModel())
    }
}
