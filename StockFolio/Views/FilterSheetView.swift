import SwiftUI

struct FilterSheetView: View {
    @ObservedObject var viewModel: TradingJournalViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var tempFilterType: FilterType
    @State private var tempSelectedDate: Date
    @State private var tempSelectedMonth: Date
    @State private var tempSelectedYear: Int
    @State private var tempSelectedStockName: String
    @State private var isStockSectionExpanded: Bool = false

    private let defaultStockVisibleCount = 10

    init(viewModel: TradingJournalViewModel) {
        self.viewModel = viewModel
        _tempFilterType = State(initialValue: viewModel.filterType)
        _tempSelectedDate = State(initialValue: viewModel.selectedDate)
        _tempSelectedMonth = State(initialValue: viewModel.selectedMonth)
        _tempSelectedYear = State(initialValue: viewModel.selectedYear)
        _tempSelectedStockName = State(initialValue: viewModel.selectedStockName)
    }

    private var displayedStocks: [String] {
        if isStockSectionExpanded {
            return viewModel.allStockNames
        } else {
            return Array(viewModel.allStockNames.prefix(defaultStockVisibleCount))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // 기간 필터 (먼저 배치)
                Section {
                    ForEach(FilterType.allCases, id: \.self) { filterType in
                        Button {
                            tempFilterType = filterType
                        } label: {
                            HStack {
                                Text(filterType.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                if tempFilterType == filterType {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } header: {
                    Text("기간")
                }

                // 기간 상세 선택
                if tempFilterType == .daily {
                    Section {
                        DatePicker(
                            "날짜 선택",
                            selection: $tempSelectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    }
                }

                if tempFilterType == .monthly {
                    Section {
                        DatePicker(
                            "월 선택",
                            selection: $tempSelectedMonth,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                        .frame(height: 120)
                    }
                }

                if tempFilterType == .yearly {
                    Section {
                        Picker("연도 선택", selection: $tempSelectedYear) {
                            ForEach(yearRange, id: \.self) { year in
                                Text("\(year)년").tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                    }
                }

            }
            .listStyle(.insetGrouped)
            .navigationTitle("필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .font(.subheadline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("적용") {
                        applyFilter()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var yearRange: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 10)...currentYear).reversed()
    }

    private func applyFilter() {
        viewModel.filterType = tempFilterType
        viewModel.selectedDate = tempSelectedDate
        viewModel.selectedMonth = tempSelectedMonth
        viewModel.selectedYear = tempSelectedYear
        viewModel.selectedStockName = tempSelectedStockName
        viewModel.applyFilter()
        dismiss()
    }
}

#Preview {
    FilterSheetView(viewModel: TradingJournalViewModel())
}
