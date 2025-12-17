import SwiftUI

/// 종목 리스트 뷰 (화면 설계서 기반)
/// SRP: 종목 목록 표시만 담당
struct StockListView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @State private var selectedStock: StockHoldingEntity?
    @State private var showingEditSheet = false
    @State private var isExpanded = false

    /// 기본 표시 개수 (설계서: 최대 6개)
    private let defaultVisibleCount = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더 (표시개수/전체개수)
            sectionHeader
                .padding(.horizontal)

            if viewModel.holdings.isEmpty {
                emptyListView
            } else {
                stockListContent
            }
        }
    }

    // MARK: - Section Header
    private var sectionHeader: some View {
        HStack {
            if viewModel.holdings.count > defaultVisibleCount {
                Text("보유 종목 (\(displayedCount)/\(viewModel.holdings.count))")
                    .font(.headline)
            } else {
                Text("보유 종목")
                    .font(.headline)
            }

            Spacer()

            // 확장/축소 버튼 (6개 초과 시)
            if viewModel.holdings.count > defaultVisibleCount {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "접기" : "더보기")
                            .font(.subheadline)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                .accessibilityLabel(isExpanded ? "목록 접기" : "더 많은 종목 보기")
            }
        }
    }

    /// 현재 표시되는 종목 수
    private var displayedCount: Int {
        isExpanded ? viewModel.holdings.count : min(defaultVisibleCount, viewModel.holdings.count)
    }

    /// 표시할 종목 목록
    private var displayedHoldings: [(offset: Int, element: StockHoldingEntity)] {
        let holdings = Array(viewModel.holdings.enumerated())
        if isExpanded {
            return holdings
        } else {
            return Array(holdings.prefix(defaultVisibleCount))
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
            ForEach(displayedHoldings, id: \.element.id) { index, holding in
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

            // 더보기 힌트 (접힌 상태에서 6개 초과 시)
            if !isExpanded && viewModel.holdings.count > defaultVisibleCount {
                moreItemsHint
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.holdings)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .padding(.horizontal)
        .sheet(isPresented: $showingEditSheet) {
            if let stock = selectedStock {
                AddStockView(viewModel: viewModel, editingStock: stock)
            }
        }
    }

    // MARK: - More Items Hint
    private var moreItemsHint: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded = true
            }
        } label: {
            HStack {
                Spacer()
                Text("↓ \(viewModel.holdings.count - defaultVisibleCount)개 더보기")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .padding(.vertical, 12)
        }
        .accessibilityLabel("\(viewModel.holdings.count - defaultVisibleCount)개 종목 더 보기")
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
