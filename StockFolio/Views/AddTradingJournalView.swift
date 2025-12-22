import SwiftUI

struct AddTradingJournalView: View {
    @ObservedObject var viewModel: TradingJournalViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var tradeType: TradeType = .buy
    @State private var tradeDate: Date = Date()
    @State private var stockName: String = ""
    @State private var quantityText: String = ""
    @State private var priceText: String = ""
    @State private var reason: String = ""
    @State private var validationError: String?
    @FocusState private var focusedField: Field?

    var editingJournal: TradingJournalEntity?

    enum Field {
        case stockName, quantity, price, reason
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("매매 유형")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Picker("매매 유형", selection: $tradeType) {
                            ForEach(TradeType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("매매일")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        DatePicker(
                            "",
                            selection: $tradeDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("종목명")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if viewModel.portfolioStocks.isEmpty {
                            // 빈 포트폴리오 처리
                            VStack(alignment: .leading, spacing: 12) {
                                Menu {
                                    Text("등록된 종목 없음")
                                } label: {
                                    HStack {
                                        Text("종목 선택")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                    }
                                    .font(.title3)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .disabled(true)

                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                    Text("포트폴리오에 종목을 먼저 등록하세요")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            // 정상 동작: Menu로 종목 선택
                            Menu {
                                ForEach(viewModel.portfolioStocks, id: \.self) { stock in
                                    Button {
                                        stockName = stock
                                    } label: {
                                        HStack {
                                            Text(stock)
                                            if stockName == stock {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(stockName.isEmpty ? "종목 선택" : stockName)
                                        .foregroundColor(stockName.isEmpty ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                                .font(.title3)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .accessibilityLabel(stockName.isEmpty ? "종목 선택" : "선택된 종목: \(stockName)")
                            .accessibilityHint("탭하여 포트폴리오 종목 선택")
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("수량")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("0", text: $quantityText)
                            .keyboardType(.numberPad)
                            .font(.title3)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .focused($focusedField, equals: .quantity)
                            .onChange(of: quantityText) { _, newValue in
                                formatQuantityInput(newValue)
                            }
                            .textContentType(.none)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("단가")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("₩ 0", text: $priceText)
                            .keyboardType(.numberPad)
                            .font(.title3)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .focused($focusedField, equals: .price)
                            .onChange(of: priceText) { _, newValue in
                                formatPriceInput(newValue)
                            }
                            .textContentType(.none)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("총액")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(formattedTotalAmount)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(tradeType == .buy ? .green : .red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("매매 이유 (선택)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $reason)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .focused($focusedField, equals: .reason)
                            .scrollContentBackground(.hidden)
                    }
                    .padding(.horizontal)

                    if let error = validationError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
                .padding(.bottom, 140)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    // 저장 버튼: 항상 표시
                    Button {
                        saveJournal()
                    } label: {
                        Text("저장")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isValidInput ? Color.accentColor : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isValidInput)

                    // 완료 버튼: 포커스 시에만 표시
                    if focusedField != nil {
                        Button {
                            focusedField = nil
                        } label: {
                            Text("완료")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .shadow(color: Color.black.opacity(0.1), radius: 8, y: -2)
                )
            }
            .navigationTitle(editingJournal == nil ? "매매 일지 작성" : "매매 일지 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .animation(.interactiveSpring(), value: focusedField)
            .onAppear {
                if let journal = editingJournal {
                    tradeType = journal.tradeType
                    tradeDate = journal.tradeDate
                    stockName = journal.stockName
                    quantityText = "\(journal.quantity)"
                    priceText = journal.price.formattedWithoutSymbol
                    reason = journal.reason
                }
            }
        }
    }

    private var isValidInput: Bool {
        !stockName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(quantityText) ?? 0 > 0 &&
        Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0 > 0 &&
        tradeDate <= Date()
    }

    private var formattedTotalAmount: String {
        let quantity = Int(quantityText) ?? 0
        let price = Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0
        let total = Double(quantity) * price

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return (formatter.string(from: NSNumber(value: total)) ?? "0") + "원"
    }

    private func formatQuantityInput(_ value: String) {
        let filtered = value.filter { $0.isNumber }
        quantityText = filtered
    }

    private func formatPriceInput(_ value: String) {
        let filtered = value.filter { $0.isNumber }
        if let number = Double(filtered) {
            priceText = number.formattedWithoutSymbol
        } else if filtered.isEmpty {
            priceText = ""
        }
    }

    private func saveJournal() {
        let quantity = Int(quantityText) ?? 0
        let price = Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0

        if let journal = editingJournal {
            viewModel.updateJournal(
                journal,
                tradeType: tradeType,
                tradeDate: tradeDate,
                stockName: stockName.trimmingCharacters(in: .whitespaces),
                quantity: quantity,
                price: price,
                reason: reason.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } else {
            viewModel.addJournal(
                tradeType: tradeType,
                tradeDate: tradeDate,
                stockName: stockName.trimmingCharacters(in: .whitespaces),
                quantity: quantity,
                price: price,
                reason: reason.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        dismiss()
    }
}

#Preview {
    AddTradingJournalView(viewModel: TradingJournalViewModel())
}
