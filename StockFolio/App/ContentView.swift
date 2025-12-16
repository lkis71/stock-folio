import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PortfolioViewModel()

    var body: some View {
        MainDashboardView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
