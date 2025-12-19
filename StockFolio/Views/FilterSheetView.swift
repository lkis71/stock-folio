import SwiftUI

struct FilterSheetView: View {
    @ObservedObject var viewModel: TradingJournalViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var tempFilterType: FilterType
    @State private var tempSelectedDate: Date
    @State private var tempSelectedMonth: Date
    @State private var tempSelectedYear: Int

    init(viewModel: TradingJournalViewModel) {
        self.viewModel = viewModel
        _tempFilterType = State(initialValue: viewModel.filterType)
        _tempSelectedDate = State(initialValue: viewModel.selectedDate)
        _tempSelectedMonth = State(initialValue: viewModel.selectedMonth)
        _tempSelectedYear = State(initialValue: viewModel.selectedYear)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(FilterType.allCases, id: \.self) { filterType in
                        Button {
                            tempFilterType = filterType
                        } label: {
                            HStack {
                                Text(filterType.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if tempFilterType == filterType {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                } header: {
                    Text("필터 종류")
                }

                if tempFilterType == .daily {
                    Section {
                        DatePicker(
                            "날짜 선택",
                            selection: $tempSelectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    } header: {
                        Text("날짜 선택")
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
                    } header: {
                        Text("월 선택")
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
                    } header: {
                        Text("연도 선택")
                    }
                }
            }
            .navigationTitle("필터 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("적용") {
                        applyFilter()
                    }
                }
            }
        }
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
        viewModel.applyFilter()
        dismiss()
    }
}

#Preview {
    FilterSheetView(viewModel: TradingJournalViewModel())
}
