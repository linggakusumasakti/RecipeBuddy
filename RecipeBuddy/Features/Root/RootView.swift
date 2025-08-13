import SwiftUI

struct RootView: View {
    private let container: AppContainer

    init(container: AppContainer = .shared) {
        self.container = container
    }

    var body: some View {
        TabView {
            HomeView(container: container)
                .tabItem { Label("Home", systemImage: "house.fill") }
            FavoritesView(container: container)
                .tabItem { Label("Favorites", systemImage: "heart.fill") }
            PlanView(container: container)
                .tabItem { Label("Plan", systemImage: "calendar") }
        }
        .accentColor(Theme.Colors.primary)
        .preferredColorScheme(.dark)
        .tint(Theme.Colors.accent)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}

#Preview {
    RootView()
}


