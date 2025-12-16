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
            VStack(spacing: 24) {
                // 입력 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text("총 시드머니")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("₩ 0", text: $seedMoneyText)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .padding()
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
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text("투자 가능한 총 금액을 입력하세요")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                Spacer()

                // 버튼
                VStack(spacing: 12) {
                    Button {
                        saveAndDismiss()
                    } label: {
                        Text("저장")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isValidAmount ? Color.accentColor : Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isValidAmount)

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
                    seedMoneyText = formatNumber(viewModel.seedMoney)
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
            seedMoneyText = formatNumber(number)
        } else if filtered.isEmpty {
            seedMoneyText = ""
        }
    }

    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? ""
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
