import SwiftUI

/// Search view with warm, appetizing design
struct FridgeSearchView: View {
    @StateObject private var viewModel = FridgeSearchViewVM()
    @FocusState private var isSearchFocused: Bool
    @State private var showContent = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                searchHeader
                
                // Search mode picker
                searchModePicker
                
                // Search bar
                searchBar
                
                // Results
                resultsSection
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primary)
                        
                        Text("Find Recipes")
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring.delay(0.2)) {
                    showContent = true
                }
            }
        }
    }
    
    // MARK: - Search Header
    
    private var searchHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.searchMode == .byIngredient ? "What's in your fridge? 🥗" : "Search recipes 🔍")
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(viewModel.searchMode == .byIngredient
                     ? "Find recipes with ingredients you have"
                     : "Discover your next favorite dish")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .fontDesign(.rounded)
            }
            
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(viewModel.searchMode == .byIngredient ? AppTheme.peachLight : AppTheme.primaryLight)
                    .frame(width: 50, height: 50)
                
                Text(viewModel.searchMode == .byIngredient ? "🧊" : "📖")
                    .font(.title2)
            }
            .scaleEffect(showContent ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showContent)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Search Mode Picker
    
    private var searchModePicker: some View {
        HStack(spacing: 12) {
            ForEach(FridgeSearchViewVM.SearchMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.switchMode(to: mode)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: mode.icon)
                            .font(.subheadline)
                        
                        Text(mode.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .fontDesign(.rounded)
                    .foregroundColor(viewModel.searchMode == mode ? .white : AppTheme.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            if viewModel.searchMode == mode {
                                RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                                    .fill(mode == .byName ? AppTheme.primary : AppTheme.red)
                                    .shadow(color: (mode == .byName ? AppTheme.primary : AppTheme.red).opacity(0.3), radius: 8, y: 4)
                            } else {
                                RoundedRectangle(cornerRadius: AppTheme.radiusMedium)
                                    .fill(AppTheme.cardBackground)
                                    .shadow(color: AppTheme.cardShadow, radius: 4, y: 2)
                            }
                        }
                    )
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.textMuted)
                        .font(.body)
                    
                    TextField(viewModel.searchMode.placeholder, text: $viewModel.searchText)
                        .font(.body)
                        .fontDesign(.rounded)
                        .focused($isSearchFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            Task {
                                await viewModel.search()
                            }
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.clearSearch()
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
                .padding(14)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
                .shadow(color: AppTheme.cardShadow, radius: 6, y: 3)
                
                Button {
                    isSearchFocused = false
                    Task {
                        await viewModel.search()
                    }
                } label: {
                    Image(systemName: "arrow.right")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(viewModel.canSearch ? AppTheme.primary : AppTheme.textMuted)
                                .shadow(color: AppTheme.primary.opacity(viewModel.canSearch ? 0.3 : 0), radius: 8, y: 4)
                        )
                }
                .buttonStyle(BouncyButtonStyle())
                .disabled(!viewModel.canSearch || viewModel.isSearching)
            }
            
            // Ingredient chips for fridge mode
            if viewModel.searchMode == .byIngredient && !viewModel.parsedIngredients.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(viewModel.parsedIngredients.enumerated()), id: \.element) { index, ingredient in
                            HStack(spacing: 6) {
                                Text(ingredientEmoji(for: ingredient))
                                Text(ingredient)
                                    .fontWeight(.medium)
                            }
                            .font(.caption)
                            .fontDesign(.rounded)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(chipColor(for: index).opacity(0.15))
                            )
                            .foregroundColor(chipColor(for: index))
                            .scaleEffect(showContent ? 1 : 0)
                            .animation(.spring(response: 0.3).delay(Double(index) * 0.1), value: showContent)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private func chipColor(for index: Int) -> Color {
        let colors = [AppTheme.primary, AppTheme.red, AppTheme.terracotta, AppTheme.burgundy, AppTheme.amber]
        return colors[index % colors.count]
    }
    
    private func ingredientEmoji(for ingredient: String) -> String {
        let name = ingredient.lowercased()
        if name.contains("chicken") { return "🍗" }
        if name.contains("beef") { return "🥩" }
        if name.contains("rice") { return "🍚" }
        if name.contains("egg") { return "🥚" }
        if name.contains("potato") { return "🥔" }
        if name.contains("tomato") { return "🍅" }
        if name.contains("cheese") { return "🧀" }
        if name.contains("fish") { return "🐟" }
        if name.contains("garlic") { return "🧄" }
        if name.contains("onion") { return "🧅" }
        return "🥗"
    }
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        ScrollView {
            if viewModel.isSearching {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if !viewModel.hasResults && !viewModel.searchText.isEmpty {
                noResultsView
            } else if viewModel.searchText.isEmpty {
                placeholderView
            } else {
                resultsGrid
            }
        }
    }
    
    private var resultsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            let resultCount = viewModel.searchMode == .byName ? viewModel.nameSearchResults.count : viewModel.searchResults.count
            
            HStack {
                Text("\(resultCount) recipe\(resultCount == 1 ? "" : "s") found")
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("🎉")
                    .font(.title2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            LazyVGrid(columns: columns, spacing: 16) {
                if viewModel.searchMode == .byName {
                    ForEach(viewModel.nameSearchResults) { recipe in
                        NavigationLink(destination: RecipeDetailView(mealId: recipe.id)) {
                            RecipeCardView(meal: MealPreview(
                                id: recipe.id,
                                name: recipe.name,
                                thumbnailURL: recipe.thumbnailURL
                            ))
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                } else {
                    ForEach(viewModel.searchResults) { meal in
                        NavigationLink(destination: RecipeDetailView(mealId: meal.id)) {
                            RecipeCardView(meal: meal)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                    .foregroundColor(AppTheme.primary)
                    .rotationEffect(.degrees(showContent ? 0 : -20))
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showContent)
            }
            
            VStack(spacing: 8) {
                Text("Searching...")
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Finding the best recipes for you")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .fontDesign(.rounded)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Text("😓")
                .font(.system(size: 60))
            
            VStack(spacing: 8) {
                Text("Search failed")
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task {
                    await viewModel.search()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(AppTheme.red)
                .clipShape(Capsule())
                .shadow(color: AppTheme.red.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .padding(.horizontal, 40)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 24) {
            Text("🤔")
                .font(.system(size: 60))
            
            VStack(spacing: 8) {
                Text("No recipes found")
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Try different search terms")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .fontDesign(.rounded)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    private var placeholderView: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(viewModel.searchMode == .byIngredient ? AppTheme.peachLight : AppTheme.primaryLight)
                    .frame(width: 100, height: 100)
                
                Text(viewModel.searchMode == .byIngredient ? "🧊" : "🔍")
                    .font(.system(size: 50))
                    .scaleEffect(showContent ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showContent)
            }
            
            VStack(spacing: 12) {
                Text(viewModel.searchMode == .byIngredient ? "What's in your fridge?" : "Ready to explore?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(viewModel.searchMode == .byIngredient
                     ? "Enter ingredients separated by commas\ne.g., Chicken, Rice, Garlic"
                     : "Type a dish name to discover recipes")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
            }
            
            // Suggestion chips
            VStack(spacing: 10) {
                Text("Try these:")
                    .font(.caption)
                    .foregroundColor(AppTheme.textMuted)
                    .fontDesign(.rounded)
                
                HStack(spacing: 10) {
                    ForEach(viewModel.searchMode == .byIngredient
                            ? ["🍗 Chicken", "🥩 Beef", "🍝 Pasta"]
                            : ["🍕 Pizza", "🍔 Burger", "🍜 Soup"], id: \.self) { suggestion in
                        Button {
                            let clean = suggestion.dropFirst(2).trimmingCharacters(in: .whitespaces)
                            viewModel.searchText = String(clean)
                            Task {
                                await viewModel.search()
                            }
                        } label: {
                            Text(suggestion)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(AppTheme.cardBackground)
                                .clipShape(Capsule())
                                .shadow(color: AppTheme.cardShadow, radius: 4, y: 2)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
            }
            .opacity(showContent ? 1 : 0)
            .animation(.spring.delay(0.3), value: showContent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#Preview {
    FridgeSearchView()
}
