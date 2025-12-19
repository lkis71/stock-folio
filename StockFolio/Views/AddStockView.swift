import SwiftUI

/// 종목 추가/편집 화면 (화면 설계서 기반)
struct AddStockView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var stockName: String = ""
    @State private var amountText: String = ""
    @State private var selectedColor: StockColor = .random
    @State private var validationError: String?
    @FocusState private var focusedField: Field?

    var editingStock: StockHoldingEntity?

    private let validator = StockInputValidator()

    enum Field {
        case name, amount
    }

    var body: some View {
        NavigationStack {
            ScrollView {
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

                    // 색상 선택
                    VStack(alignment: .leading, spacing: 8) {
                        Text("차트 색상")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                            ForEach(StockColor.allCases, id: \.self) { color in
                                Button {
                                    selectedColor = color
                                } label: {
                                    Circle()
                                        .fill(color.color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(color.isLightColor ? .black : .white)
                                                .opacity(selectedColor == color ? 1 : 0)
                                                .shadow(color: color.isLightColor ? .white.opacity(0.8) : .black.opacity(0.3), radius: 2)
                                        )
                                }
                                .accessibilityLabel(color.displayName)
                                .accessibilityAddTraits(selectedColor == color ? .isSelected : [])
                                .accessibilityHint(selectedColor == color ? "선택됨" : "탭하여 선택")
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("차트 색상 선택")
                    }
                    .padding(.horizontal)

                    // 검증 에러 메시지
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
                // 빈 영역 탭 시 키보드와 버튼 숨김
                focusedField = nil
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    // 저장 버튼 (항상 표시)
                    Button {
                        saveStock()
                    } label: {
                        Text("저장")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .opacity(isValidInput ? 1.0 : 0.5)
                    }
                    .disabled(!isValidInput)

                    // 완료 버튼 (입력 중일 때만 표시)
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
            .animation(.interactiveSpring(), value: focusedField)
            .onAppear {
                if let stock = editingStock {
                    stockName = stock.stockName
                    amountText = stock.purchaseAmount.formattedWithoutSymbol
                    selectedColor = StockColor(rawValue: stock.colorName) ?? .blue
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
            viewModel.updateStock(stock, name: stockName.trimmingCharacters(in: .whitespaces), amount: amount, colorName: selectedColor.rawValue)
        } else {
            viewModel.addStock(name: stockName.trimmingCharacters(in: .whitespaces), amount: amount, colorName: selectedColor.rawValue)
        }
        dismiss()
    }

    // deleteStock 함수 제거됨 - 종목 리스트에서 스와이프로 삭제
}

#Preview {
    AddStockView(viewModel: PortfolioViewModel())
}
