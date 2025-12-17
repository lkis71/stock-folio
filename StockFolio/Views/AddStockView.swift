import SwiftUI

/// 종목 추가/편집 화면 (화면 설계서 기반)
struct AddStockView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var stockName: String = ""
    @State private var amountText: String = ""
    @State private var validationError: String?
    @FocusState private var focusedField: Field?

    var editingStock: StockHoldingEntity?

    private let validator = StockInputValidator()

    enum Field {
        case name, amount
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 종목명 입력
                VStack(alignment: .leading, spacing: 8) {
                    Text("종목명")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("예: 삼성전자", text: $stockName)
                        .font(.title3)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .focused($focusedField, equals: .name)
                        .onChange(of: stockName) { _, newValue in
                            validateName(newValue)
                        }
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .accessibilityLabel("종목명 입력")
                }
                .padding(.horizontal)

                // 매수 금액 입력
                VStack(alignment: .leading, spacing: 8) {
                    Text("매수 금액")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("₩ 0", text: $amountText)
                        .keyboardType(.numberPad)
                        .font(.title3)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .focused($focusedField, equals: .amount)
                        .onChange(of: amountText) { _, newValue in
                            formatAmountInput(newValue)
                        }
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .accessibilityLabel("매수 금액 입력")
                }
                .padding(.horizontal)

                // 검증 에러 메시지
                if let error = validationError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()

                // 버튼
                VStack(spacing: 12) {
                    Button {
                        saveStock()
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

                    if editingStock != nil {
                        Button(role: .destructive) {
                            deleteStock()
                        } label: {
                            Text("삭제")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(editingStock == nil ? "종목 추가" : "종목 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .accessibilityLabel("닫기")
                    }
                }
            }
            .onAppear {
                if let stock = editingStock {
                    stockName = stock.stockName
                    amountText = stock.purchaseAmount.formattedWithoutSymbol
                }
                focusedField = .name
            }
        }
    }

    private var isValidInput: Bool {
        guard validationError == nil else { return false }

        // 종목명 검증
        guard case .success = validator.validateStockName(stockName) else {
            return false
        }

        // 금액 검증
        guard case .success = validator.validateAmountString(amountText) else {
            return false
        }

        return true
    }

    private func validateName(_ name: String) {
        if name.isEmpty {
            validationError = nil
            return
        }

        switch validator.validateStockName(name) {
        case .success:
            validationError = nil
        case .failure(let error):
            switch error {
            case .empty:
                validationError = nil
            case .tooLong(let max):
                validationError = "종목명은 \(max)자 이내로 입력해주세요"
            case .invalidCharacters:
                validationError = "특수문자는 사용할 수 없습니다"
            default:
                validationError = "올바르지 않은 입력입니다"
            }
        }
    }

    private func formatAmountInput(_ value: String) {
        let filtered = value.filter { $0.isNumber }
        if let number = Double(filtered) {
            amountText = number.formattedWithoutSymbol
        } else if filtered.isEmpty {
            amountText = ""
        }
    }

    private func saveStock() {
        let cleanedAmount = amountText.replacingOccurrences(of: ",", with: "")
        guard let amount = Double(cleanedAmount) else { return }

        if let stock = editingStock {
            viewModel.updateStock(stock, name: stockName.trimmingCharacters(in: .whitespaces), amount: amount)
        } else {
            viewModel.addStock(name: stockName.trimmingCharacters(in: .whitespaces), amount: amount)
        }
        dismiss()
    }

    private func deleteStock() {
        if let stock = editingStock {
            viewModel.deleteStock(stock)
        }
        dismiss()
    }
}

#Preview {
    AddStockView(viewModel: PortfolioViewModel())
}
