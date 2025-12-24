import SwiftUI

/// 메인 대시보드 화면 (화면 설계서 기반)
struct MainDashboardView: View {
    @ObservedObject var viewModel: PortfolioViewModel
    @State private var showingAddStock = false
    @State private var showingSeedMoneySettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.holdings.isEmpty && viewModel.seedMoney == 0 {
                    emptyStateView
                } else {
                    mainContentView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // 설정 버튼 (왼쪽)
                    Button {
                        showingSeedMoneySettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("설정")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    // 종목 추가 버튼 (오른쪽)
                    Button {
                        showingAddStock = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("종목 추가")
                }
            }
            .sheet(isPresented: $showingAddStock) {
                AddStockView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSeedMoneySettings) {
                SeedMoneySettingsView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Main Content
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                SeedMoneySectionView(viewModel: viewModel)

                if !viewModel.holdings.isEmpty {
                    PortfolioChartView(viewModel: viewModel)
                }

                StockListView(viewModel: viewModel)
            }
            .padding(.vertical)
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("아직 보유 종목이 없습니다")
                .font(.title2)
                .fontWeight(.semibold)

            Text("설정에서 시드머니를 입력하고\n+ 버튼을 눌러 종목을 추가해보세요")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingSeedMoneySettings = true
            } label: {
                Text("시드머니 설정하기")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .padding()
    }
}

// MARK: - Seed Money Section
/// 투자 금액/남은 현금 요약 (컴팩트 버전)
struct SeedMoneySectionView: View {
    @ObservedObject var viewModel: PortfolioViewModel

    var body: some View {
        HStack(spacing: 12) {
            InvestmentSummaryCard(
                title: "투자",
                amount: viewModel.totalInvestedAmount,
                percentage: viewModel.investedPercentage,
                color: .blue
            )

            InvestmentSummaryCard(
                title: "현금",
                amount: viewModel.remainingCash,
                percentage: viewModel.cashPercentage,
                color: .green
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Investment Summary Card
struct InvestmentSummaryCard: View {
    let title: String
    let amount: Double
    let percentage: Double
    let color: Color

    var body: some View {
        HStack(spacing: 0) {
            // 좌측 색상 인디케이터
            color
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(amount.currencyFormatted)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                Text(String(format: "%.1f%%", percentage))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(amount.currencyFormatted), \(String(format: "%.1f", percentage))%")
    }
}

#Preview {
    MainDashboardView(viewModel: PortfolioViewModel())
}
