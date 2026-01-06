import SwiftUI

/// Recipe detail view with Duolingo-style playful design
struct RecipeDetailView: View {
    let mealId: String
    
    @StateObject private var viewModel = RecipeDetailViewVM()
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if let recipe = viewModel.recipe {
                recipeContent(recipe)
            }
        }
        .background(AppTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let recipe = viewModel.recipe {
                    Text(recipe.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)
                }
            }
        }
        .task {
            await viewModel.loadRecipe(id: mealId)
            withAnimation(.spring(response: 0.5)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Recipe Content
    
    private func recipeContent(_ recipe: Recipe) -> some View {
        VStack(spacing: 0) {
            // Hero image
            heroImage(recipe)
            
            // Content sections
            VStack(spacing: 24) {
                // Title and meta
                headerSection(recipe)
                
                // Quick stats
                quickStats(recipe)
                
                // YouTube video if available
                if let youtubeURL = viewModel.youtubeEmbedURL {
                    videoSection(url: youtubeURL)
                }
                
                // Ingredients with servings calculator
                ingredientsSection
                
                // Instructions
                instructionsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
    }
    
    // MARK: - Hero Image
    
    private func heroImage(_ recipe: Recipe) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: recipe.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primaryLight, AppTheme.primary.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            ProgressView()
                                .tint(AppTheme.primary)
                                .scaleEffect(1.5)
                        }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(AppTheme.primaryLight)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                Text("Image unavailable")
                                    .font(.caption)
                            }
                            .foregroundColor(AppTheme.primary.opacity(0.5))
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 300)
            .clipped()
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Category badge
            if !recipe.category.isEmpty {
                HStack(spacing: 6) {
                    Text(emojiForCategory(recipe.category))
                    Text(recipe.category)
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(AppTheme.categoryColor(for: recipe.category))
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                )
                .padding(20)
            }
        }
    }
    
    private func emojiForCategory(_ name: String) -> String {
        switch name.lowercased() {
        case "beef": return "🥩"
        case "chicken": return "🍗"
        case "dessert": return "🍰"
        case "seafood": return "🦐"
        case "vegan": return "🥬"
        case "vegetarian": return "🥕"
        case "pasta": return "🍝"
        case "breakfast": return "🍳"
        default: return "🍽️"
        }
    }
    
    // MARK: - Header Section
    
    private func headerSection(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.name)
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundColor(AppTheme.textPrimary)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            
            if !recipe.area.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "globe")
                        .foregroundColor(AppTheme.terracotta)
                    
                    Text(recipe.area)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .font(.subheadline)
                .fontDesign(.rounded)
            }
            
            // Tags
            if !recipe.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(recipe.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppTheme.primaryLight)
                            .foregroundColor(AppTheme.primary)
                            .clipShape(Capsule())
                    }
                }
                .opacity(showContent ? 1 : 0)
                .animation(.spring.delay(0.1), value: showContent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Quick Stats
    
    private func quickStats(_ recipe: Recipe) -> some View {
        HStack(spacing: 0) {
            statItem(icon: "list.bullet", value: "\(recipe.ingredients.count)", label: "Ingredients", color: AppTheme.primary)
            
            Divider()
                .frame(height: 40)
            
            statItem(icon: "clock.fill", value: "30", label: "Minutes", color: AppTheme.red)
            
            Divider()
                .frame(height: 40)
            
            statItem(icon: "person.2.fill", value: "\(viewModel.servingSize)", label: "Servings", color: AppTheme.terracotta)
        }
        .padding(.vertical, 16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
        .shadow(color: AppTheme.cardShadow, radius: 8, y: 4)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.spring.delay(0.2), value: showContent)
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.body)
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundColor(AppTheme.textPrimary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary)
                .fontDesign(.rounded)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Video Section
    
    private func videoSection(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "play.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Text("Watch Tutorial")
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            YouTubePlayerContainerView(url: url)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
                .shadow(color: AppTheme.cardShadow, radius: 8, y: 4)
        }
        .opacity(showContent ? 1 : 0)
        .animation(.spring.delay(0.3), value: showContent)
    }
    
    // MARK: - Ingredients Section
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with servings calculator
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.amber.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "carrot.fill")
                            .foregroundColor(AppTheme.amber)
                            .font(.caption)
                    }
                    
                    Text("Ingredients")
                        .font(.headline)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                // Servings stepper
                HStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.decrementServings()
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.servingSize > 1 ? AppTheme.primary : AppTheme.textMuted)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(viewModel.servingSize > 1 ? AppTheme.primaryLight : Color.gray.opacity(0.1))
                            )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .disabled(viewModel.servingSize <= 1)
                    
                    Text("\(viewModel.servingSize)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(minWidth: 28)
                        .contentTransition(.numericText(value: Double(viewModel.servingSize)))
                    
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.incrementServings()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.servingSize < 12 ? AppTheme.primary : AppTheme.textMuted)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(viewModel.servingSize < 12 ? AppTheme.primaryLight : Color.gray.opacity(0.1))
                            )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .disabled(viewModel.servingSize >= 12)
                }
            }
            
            // Ingredients list
            VStack(spacing: 0) {
                ForEach(Array(viewModel.adjustedIngredients.enumerated()), id: \.element.id) { index, ingredient in
                    IngredientRowView(ingredient: ingredient, index: index + 1)
                    
                    if index < viewModel.adjustedIngredients.count - 1 {
                        Divider()
                            .padding(.leading, 54)
                    }
                }
            }
            .padding(16)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
            .shadow(color: AppTheme.cardShadow, radius: 8, y: 4)
        }
        .opacity(showContent ? 1 : 0)
        .animation(.spring.delay(0.4), value: showContent)
    }
    
    // MARK: - Instructions Section
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(AppTheme.burgundy.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "book.fill")
                        .foregroundColor(AppTheme.burgundy)
                        .font(.caption)
                }
                
                Text("Instructions")
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Text(viewModel.formattedInstructions)
                .font(.body)
                .fontDesign(.rounded)
                .foregroundColor(AppTheme.textPrimary)
                .lineSpacing(8)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
                .shadow(color: AppTheme.cardShadow, radius: 8, y: 4)
        }
        .padding(.bottom, 40)
        .opacity(showContent ? 1 : 0)
        .animation(.spring.delay(0.5), value: showContent)
    }
    
    // MARK: - Loading/Error Views
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryLight)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.primary)
                    .rotationEffect(.degrees(showContent ? 0 : 360))
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: showContent)
            }
            
            VStack(spacing: 8) {
                Text("Preparing recipe...")
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("This won't take long!")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .fontDesign(.rounded)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 150)
        .onAppear {
            showContent = true
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Text("😢")
                .font(.system(size: 60))
            
            VStack(spacing: 8) {
                Text("Something went wrong")
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
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                    Text("Go Back")
                }
                .font(.headline)
                .fontDesign(.rounded)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(AppTheme.primary)
                .clipShape(Capsule())
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
        .padding(.horizontal, 40)
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x - spacing)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        RecipeDetailView(mealId: "52772")
    }
}
