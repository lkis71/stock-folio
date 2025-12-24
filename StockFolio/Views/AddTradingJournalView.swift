import SwiftUI

struct AddTradingJournalView: View {
    @ObservedObject var viewModel: TradingJournalViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var tradeType: TradeType = .buy
    @State private var tradeDate: Date = Date()
    @State private var stockName: String = ""
    @State private var quantityText: String = ""
    @State private var priceText: String = ""
    @State private var realizedProfitText: String = ""
    @State private var isProfit: Bool = true
    @State private var reason: String = ""
    @State private var validationError: String?
    @State private var datePickerId = UUID()
    @State private var showingDeleteAlert = false
    @FocusState private var focusedField: Field?

    var editingJournal: TradingJournalEntity?

    enum Field {
        case stockName, quantity, price, realizedProfit, reason
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 매매 유형 + 매매일 (한 줄)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("매매 유형")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("매매 유형", selection: $tradeType) {
                                ForEach(TradeType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("매매일")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            DatePicker("", selection: $tradeDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .id(datePickerId)
                                .onChange(of: tradeDate) { _, _ in
                                    focusedField = nil
                                    datePickerId = UUID()
                                }
                        }
                    }
                    .padding(.horizontal)

                    // 종목 입력 (직접 입력 + 포트폴리오 선택)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("종목")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            TextField("종목명 입력", text: $stockName)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .focused($focusedField, equals: .stockName)

                            if !viewModel.portfolioStocks.isEmpty {
                                Menu {
                                    ForEach(viewModel.portfolioStocks, id: \.self) { stock in
                                        Button {
                                            stockName = stock
                                            focusedField = nil
                                        } label: {
                                            HStack {
                                                Text(stock)
                                                if stockName == stock {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "list.bullet")
                                        .font(.subheadline)
                                        .foregroundColor(.accentColor)
                                        .frame(width: 44, height: 44)
                                        .background(Color(.secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 수량 + 단가 (한 줄)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("수량")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("0", text: $quantityText)
                                .keyboardType(.numberPad)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .focused($focusedField, equals: .quantity)
                                .onChange(of: quantityText) { _, newValue in
                                    formatQuantityInput(newValue)
                                }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("단가")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("0", text: $priceText)
                                .keyboardType(.numberPad)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .focused($focusedField, equals: .price)
                                .onChange(of: priceText) { _, newValue in
                                    formatPriceInput(newValue)
                                }
                        }
                    }
                    .padding(.horizontal)

                    // 총액
                    HStack {
                        Text("총액")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(formattedTotalAmount)
                            .font(.headline)
                            .foregroundColor(tradeType == .buy ? .green : .red)
                    }
                    .padding(.horizontal)

                    // 매도 시에만 실현손익 입력 표시
                    if tradeType == .sell {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("실현손익")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                Picker("", selection: $isProfit) {
                                    Text("수익").tag(true)
                                    Text("손실").tag(false)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 100)

                                TextField("0", text: $realizedProfitText)
                                    .keyboardType(.numberPad)
                                    .font(.subheadline)
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .focused($focusedField, equals: .realizedProfit)
                                    .onChange(of: realizedProfitText) { _, newValue in
                                        formatRealizedProfitInput(newValue)
                                    }

                                Text(formattedProfitRate)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background((calculatedRealizedProfit >= 0 ? Color.green : Color.red).opacity(0.15))
                                    .foregroundColor(calculatedRealizedProfit >= 0 ? .green : .red)
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // 매매 이유
                    VStack(alignment: .leading, spacing: 4) {
                        Text("매매 이유 (선택)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("간단한 메모", text: $reason, axis: .vertical)
                            .lineLimit(2...4)
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .focused($focusedField, equals: .reason)
                    }
                    .padding(.horizontal)

                    if let error = validationError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 100)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Button {
                        saveJournal()
                    } label: {
                        Text("저장")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(isValidInput ? Color.accentColor : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(!isValidInput)

                    if focusedField != nil {
                        Button {
                            focusedField = nil
                        } label: {
                            Text("완료")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
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

                if editingJournal != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("삭제 확인", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    deleteJournal()
                }
            } message: {
                Text("이 매매 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.")
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
                    // 실현손익 로드 (매도인 경우)
                    if journal.tradeType == .sell {
                        isProfit = journal.realizedProfit >= 0
                        realizedProfitText = abs(journal.realizedProfit).formattedWithoutSymbol
                    }
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

    private func formatRealizedProfitInput(_ value: String) {
        let filtered = value.filter { $0.isNumber }
        if let number = Double(filtered) {
            realizedProfitText = number.formattedWithoutSymbol
        } else if filtered.isEmpty {
            realizedProfitText = ""
        }
    }

    private var calculatedRealizedProfit: Double {
        let amount = Double(realizedProfitText.replacingOccurrences(of: ",", with: "")) ?? 0
        return isProfit ? amount : -amount
    }

    private var calculatedProfitRate: Double {
        let quantity = Int(quantityText) ?? 0
        let price = Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0
        let sellAmount = Double(quantity) * price
        let profit = calculatedRealizedProfit
        let investedAmount = sellAmount - profit
        guard investedAmount > 0 else { return 0 }
        return (profit / investedAmount) * 100
    }

    private var formattedProfitRate: String {
        let rate = calculatedProfitRate
        let sign = rate >= 0 ? "+" : ""
        return sign + String(format: "%.1f", rate) + "%"
    }

    private func saveJournal() {
        let quantity = Int(quantityText) ?? 0
        let price = Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0
        let realizedProfit = tradeType == .sell ? calculatedRealizedProfit : 0

        if let journal = editingJournal {
            viewModel.updateJournal(
                journal,
                tradeType: tradeType,
                tradeDate: tradeDate,
                stockName: stockName.trimmingCharacters(in: .whitespaces),
                quantity: quantity,
                price: price,
                realizedProfit: realizedProfit,
                reason: reason.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } else {
            viewModel.addJournal(
                tradeType: tradeType,
                tradeDate: tradeDate,
                stockName: stockName.trimmingCharacters(in: .whitespaces),
                quantity: quantity,
                price: price,
                realizedProfit: realizedProfit,
                reason: reason.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        dismiss()
    }

    private func deleteJournal() {
        guard let journal = editingJournal else { return }

        if let index = viewModel.journals.firstIndex(where: { $0.id == journal.id }) {
            viewModel.deleteJournals(at: IndexSet(integer: index))
        }
        dismiss()
    }
}

#Preview {
    AddTradingJournalView(viewModel: TradingJournalViewModel())
}
