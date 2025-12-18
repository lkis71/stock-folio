import SwiftUI

/// 종목 리스트 뷰 (화면 설계서 기반)
/// SRP: 종목 목록 표시만 담당
struct StockListView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @State private var selectedStock: StockHoldingEntity?
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

    /// 비중 기준 내림차순 정렬된 종목 목록
    private var sortedHoldings: [StockHoldingEntity] {
        viewModel.holdings.sorted { viewModel.percentage(for: $0) > viewModel.percentage(for: $1) }
    }

    /// 표시할 종목 목록 (비중 기준 내림차순 정렬)
    private var displayedHoldings: [(offset: Int, element: StockHoldingEntity)] {
        let holdings = Array(sortedHoldings.enumerated())
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
        VStack(spacing: 0) {
            // List를 사용하여 swipeActions 활성화
            List {
                ForEach(displayedHoldings, id: \.element.id) { index, holding in
                    StockRowView(
                        holding: holding,
                        percentage: viewModel.percentage(for: holding),
                        color: holding.color
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedStock = holding
                    }
                    // 스와이프 삭제 기능 (화면 설계서: 스와이프로 삭제)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.deleteStock(holding)
                            }
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .accessibilityElement(children: .combine)
                    .accessibilityHint("탭하여 편집, 스와이프하여 삭제")
                }
            }
            .listStyle(.plain)
            .scrollDisabled(true)
            .frame(height: calculateListHeight())
            .animation(.easeInOut(duration: 0.3), value: viewModel.holdings)
            .animation(.easeInOut(duration: 0.3), value: isExpanded)

            // 더보기 힌트 (접힌 상태에서 6개 초과 시)
            if !isExpanded && viewModel.holdings.count > defaultVisibleCount {
                moreItemsHint
                    .padding(.horizontal)
            }
        }
        .sheet(item: $selectedStock) { stock in
            AddStockView(viewModel: viewModel, editingStock: stock)
        }
    }

    /// List 높이 계산 (각 행 약 72pt + 상하 패딩 8pt)
    private func calculateListHeight() -> CGFloat {
        let rowHeight: CGFloat = 80
        return CGFloat(displayedCount) * rowHeight
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
