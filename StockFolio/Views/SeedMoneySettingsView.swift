import SwiftUI

/// 시드머니 설정 화면 (화면 설계서 기반)
struct SeedMoneySettingsView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var seedMoneyText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    private let validator = StockInputValidator()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 입력 섹션
                VStack(alignment: .leading, spacing: 4) {
                    Text("총 시드머니")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("0", text: $seedMoneyText)
                        .keyboardType(.numberPad)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .focused($isTextFieldFocused)
                        .onChange(of: seedMoneyText) { _, newValue in
                            formatInput(newValue)
                        }
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .accessibilityLabel("시드머니 입력")
                }
                .padding(.horizontal)

                // 안내 문구
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text("투자 가능한 총 금액을 입력하세요")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 12)
            .safeAreaInset(edge: .bottom) {
                Button {
                    saveAndDismiss()
                } label: {
                    Text("저장")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(isValidAmount ? Color.accentColor : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(!isValidAmount)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .shadow(color: Color.black.opacity(0.1), radius: 8, y: -2)
                )
            }
            .navigationTitle("시드머니 설정")
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
                if viewModel.seedMoney > 0 {
                    seedMoneyText = viewModel.seedMoney.formattedWithoutSymbol
                }
                isTextFieldFocused = true
            }
        }
    }

    private var isValidAmount: Bool {
        let cleanedText = seedMoneyText.replacingOccurrences(of: ",", with: "")
        guard let amount = Double(cleanedText) else { return false }
        return amount > 0
    }

    private func formatInput(_ value: String) {
        // 숫자와 콤마만 허용 (보안)
        let filtered = value.filter { $0.isNumber }
        if let number = Double(filtered) {
            seedMoneyText = number.formattedWithoutSymbol
        } else if filtered.isEmpty {
            seedMoneyText = ""
        }
    }

    private func saveAndDismiss() {
        let cleanedText = seedMoneyText.replacingOccurrences(of: ",", with: "")
        if let amount = Double(cleanedText) {
            viewModel.saveSeedMoney(amount)
        }
        dismiss()
    }
}

#Preview {
    SeedMoneySettingsView(viewModel: PortfolioViewModel())
}
