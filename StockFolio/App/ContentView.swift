import SwiftUI

struct ContentView: View {
    @StateObject private var portfolioViewModel = PortfolioViewModel()

    var body: some View {
        TabView {
            MainDashboardView(viewModel: portfolioViewModel)
                .tabItem {
                    Label("포트폴리오", systemImage: "chart.pie.fill")
                }

            TradingJournalListView()
                .tabItem {
                    Label("매매 일지", systemImage: "book.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
