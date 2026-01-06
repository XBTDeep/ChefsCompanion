import SwiftUI

/// Main recipe list/home feed view with Duolingo-style design
struct RecipeListView: View {
    @StateObject private var viewModel = RecipeListViewVM()
    @State private var showWelcome = true
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Welcome header
                    welcomeHeader
                    
                    // Category filter pills
                    categoriesSection
                    
                    // Recipe grid
                    recipesSection
                }
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primary)
                        
                        Text("Chef's Companion")
                            .font(.headline)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("What's cooking? 👨‍🍳")
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Discover delicious recipes today!")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                        .fontDesign(.rounded)
                }
                
                Spacer()
                
                // Animated mascot area
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryLight)
                        .frame(width: 60, height: 60)
                    
                    Text("🍳")
                        .font(.largeTitle)
                        .offset(y: showWelcome ? -2 : 2)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showWelcome)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Stats bar
            HStack(spacing: 0) {
                statItem(icon: "flame.fill", value: "\(viewModel.meals.count)", label: "Recipes", color: AppTheme.primary)
                
                Divider()
                    .frame(height: 30)
                
                statItem(icon: "square.grid.2x2.fill", value: "\(viewModel.categories.count)", label: "Categories", color: AppTheme.red)
                
                Divider()
                    .frame(height: 30)
                
                statItem(icon: "star.fill", value: "Free", label: "Forever", color: AppTheme.amber)
            }
            .padding(.vertical, 12)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
            .shadow(color: AppTheme.cardShadow, radius: 8, y: 4)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
        .onAppear {
            showWelcome = true
        }
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                    .contentTransition(.numericText())
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary)
                .fontDesign(.rounded)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Browse Categories")
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                if viewModel.isLoadingCategories {
                    ProgressView()
                        .tint(AppTheme.primary)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        CategoryPillView(
                            category: category,
                            isSelected: viewModel.selectedCategory?.id == category.id
                        ) {
                            Task {
                                await viewModel.selectCategory(category)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Recipes Section
    
    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let category = viewModel.selectedCategory {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(category.name) Recipes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("\(viewModel.meals.count) delicious options")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .fontDesign(.rounded)
                    }
                    
                    Spacer()
                    
                    Text(emojiForCategory(category.name))
                        .font(.largeTitle)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            
            if viewModel.isLoadingMeals {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if viewModel.meals.isEmpty {
                emptyView
            } else {
                recipesGrid
            }
        }
    }
    
    private func emojiForCategory(_ name: String) -> String {
        switch name.lowercased() {
        case "beef": return "🥩"
        case "chicken": return "🍗"
        case "dessert": return "🍰"
        case "lamb": return "🍖"
        case "pasta": return "🍝"
        case "pork": return "🥓"
        case "seafood": return "🦐"
        case "vegan": return "🥬"
        case "vegetarian": return "🥕"
        case "breakfast": return "🍳"
        default: return "🍽️"
        }
    }
    
    private var recipesGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(viewModel.meals.enumerated()), id: \.element.id) { index, meal in
                NavigationLink(destination: RecipeDetailView(mealId: meal.id)) {
                    RecipeCardView(meal: meal)
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "fork.knife")
                    .font(.largeTitle)
                    .foregroundColor(AppTheme.primary)
                    .rotationEffect(.degrees(showWelcome ? -10 : 10))
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showWelcome)
            }
            
            Text("Cooking up recipes...")
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Text("😅")
                    .font(.system(size: 40))
            }
            
            VStack(spacing: 8) {
                Text("Oops!")
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
                    await viewModel.refresh()
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
                .padding(.vertical, 12)
                .background(AppTheme.primary)
                .clipShape(Capsule())
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 40)
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 80, height: 80)
                
                Text("🍽️")
                    .font(.system(size: 40))
            }
            
            VStack(spacing: 8) {
                Text("No recipes yet")
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Select a category to explore")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Preview
#Preview {
    RecipeListView()
}
