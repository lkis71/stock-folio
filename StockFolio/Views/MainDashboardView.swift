import SwiftUI

/// 메인 대시보드 화면 (화면 설계서 기반)
/// v3.0: 포트폴리오는 매매일지 기반으로만 관리 (직접 입력 제거)
struct MainDashboardView: View {
    @ObservedObject var viewModel: PortfolioViewModel
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
                // v2.0: StatCard 스타일 통계 섹션
                PortfolioStatisticsSection(
                    viewModel: viewModel,
                    onSeedMoneyTap: {
                        showingSeedMoneySettings = true
                    }
                )

                if !viewModel.holdings.isEmpty {
                    PortfolioChartView(viewModel: viewModel)
                }
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

            Text("매매일지에서 매수 기록을 추가하면\n포트폴리오에 자동으로 반영됩니다")
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

// MARK: - Legacy Components (deprecated in v2.0)
// InvestmentSummaryCard 및 SeedMoneySectionView는 PortfolioStatisticsSection으로 대체됨

#Preview {
    MainDashboardView(viewModel: PortfolioViewModel())
}
