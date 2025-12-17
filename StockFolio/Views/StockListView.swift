import SwiftUI

/// 종목 리스트 뷰 (화면 설계서 기반)
/// SRP: 종목 목록 표시만 담당
struct StockListView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @State private var selectedStock: StockHoldingEntity?
    @State private var showingEditSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("보유 종목")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.holdings.isEmpty {
                emptyListView
            } else {
                stockListContent
            }
        }
    }

    // MARK: - Empty State
    private var emptyListView: some View {
        VStack(spacing: 8) {
            Text("보유 종목이 없습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("+ 버튼을 눌러 종목을 추가하세요")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Stock List Content
    private var stockListContent: some View {
        LazyVStack(spacing: 8) {
            ForEach(Array(viewModel.holdings.enumerated()), id: \.element.id) { index, holding in
                StockRowView(
                    holding: holding,
                    percentage: viewModel.percentage(for: holding),
                    color: stockColor(at: index)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedStock = holding
                    showingEditSheet = true
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity.combined(with: .move(edge: .trailing))
                ))
                .accessibilityElement(children: .combine)
                .accessibilityHint("탭하여 편집")
            }
            .onDelete(perform: viewModel.deleteStocks)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.holdings)
        .padding(.horizontal)
        .sheet(isPresented: $showingEditSheet) {
            if let stock = selectedStock {
                AddStockView(viewModel: viewModel, editingStock: stock)
            }
        }
    }

    // MARK: - Color Helper
    /// 차트와 동일한 색상 팔레트 사용 (화면 설계서 기반)
    private func stockColor(at index: Int) -> Color {
        let baseColors: [Color] = [
            .blue, .green, .orange, .purple, .pink,
            .cyan, .indigo, .mint, .teal, .yellow
        ]
        return baseColors[index % baseColors.count]
    }
}

// MARK: - Stock Row View
/// 개별 종목 행 (SRP 준수)
struct StockRowView: View {
    let holding: StockHoldingEntity
    let percentage: Double
    let color: Color

    var body: some View {
        HStack(spacing: 0) {
            // 좌측 색상 인디케이터 (화면 설계서: 5pt 너비)
            color
                .frame(width: 5)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            HStack {
                // 종목 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(holding.stockName)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    Text(holding.purchaseAmount.currencyFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer()

                // 비중
                Text(String(format: "%.1f%%", percentage))
                    .font(.headline)
                    .foregroundStyle(color)
                    .monospacedDigit()
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StockListView(viewModel: PortfolioViewModel())
}
