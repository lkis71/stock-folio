import SwiftUI

/// 종목 리스트 뷰 (화면 설계서 기반)
/// SRP: 종목 목록 표시만 담당
struct StockListView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @State private var selectedStock: StockHoldingEntity?

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
        .onAppear {
            print("📊 [StockListView] holdings.count: \(viewModel.holdings.count), totalCount: \(viewModel.totalCount), hasMore: \(viewModel.hasMore)")
        }
    }

    // MARK: - Section Header
    private var sectionHeader: some View {
        HStack {
            if viewModel.totalCount > 10 {
                Text("보유 종목 (\(viewModel.holdings.count)/\(viewModel.totalCount))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } else {
                Text("보유 종목")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
    }

    /// 비중 기준 내림차순 정렬된 종목 목록
    private var sortedHoldings: [(offset: Int, element: StockHoldingEntity)] {
        let sorted = viewModel.holdings.sorted { viewModel.percentage(for: $0) > viewModel.percentage(for: $1) }
        return Array(sorted.enumerated())
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
                ForEach(sortedHoldings, id: \.element.id) { index, holding in
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

                // 로딩 인디케이터
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                // 더보기 버튼
                if viewModel.hasMore && !viewModel.isLoading {
                    Button {
                        viewModel.fetchMore()
                    } label: {
                        HStack {
                            Spacer()
                            Text("↓ 더보기")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            Spacer()
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollDisabled(true)
            .frame(height: calculateListHeight())
            .animation(.easeInOut(duration: 0.3), value: viewModel.holdings)
        }
        .sheet(item: $selectedStock) { stock in
            AddStockView(viewModel: viewModel, editingStock: stock)
        }
    }

    /// List 높이 계산 (각 행 약 52pt + 상하 패딩 + 더보기 버튼)
    private func calculateListHeight() -> CGFloat {
        let rowHeight: CGFloat = 60
        let loadingHeight: CGFloat = viewModel.isLoading ? 44 : 0
        let buttonHeight: CGFloat = (viewModel.hasMore && !viewModel.isLoading) ? 44 : 0
        return CGFloat(viewModel.holdings.count) * rowHeight + loadingHeight + buttonHeight
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
            // 좌측 색상 인디케이터
            color
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            HStack {
                // 종목 정보
                VStack(alignment: .leading, spacing: 2) {
                    Text(holding.stockName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    Text(holding.purchaseAmount.currencyFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer()

                // 비중
                Text(String(format: "%.1f%%", percentage))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    StockListView(viewModel: PortfolioViewModel())
}
