import SwiftUI

@main
struct ChefsCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Main content view with tab navigation
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home/Feed Tab
            RecipeListView()
                .tabItem {
                    Label("Discover", systemImage: "fork.knife")
                }
                .tag(0)
            
            // Search/Fridge Tab
            FridgeSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
        }
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
}
