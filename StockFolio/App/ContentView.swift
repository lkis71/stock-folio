import SwiftUI

struct ContentView: View {
    @StateObject private var portfolioViewModel = PortfolioViewModel()

    var body: some View {
        TabView {
            TradingJournalView()
                .tabItem {
                    Label("매매일지", systemImage: "book.fill")
                }

            MainDashboardView(viewModel: portfolioViewModel)
                .tabItem {
                    Label("포트폴리오", systemImage: "chart.pie.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
