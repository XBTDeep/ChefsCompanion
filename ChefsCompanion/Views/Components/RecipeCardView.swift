import SwiftUI

/// A beautiful, animated recipe card with Duolingo-style design
struct RecipeCardView: View {
    let meal: MealPreview
    
    @State private var isLoaded = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe image with overlay
            ZStack(alignment: .topTrailing) {
                imageView
                
                // Floating badge
                floatingBadge
            }
            .frame(height: 150)
            .clipped()
            
            // Recipe info
            VStack(alignment: .leading, spacing: 8) {
                Text(meal.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Cute decorative element
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(AppTheme.primary.opacity(0.3 + Double(i) * 0.2))
                            .frame(width: 6, height: 6)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(AppTheme.primary)
                        .font(.title3)
                }
            }
            .padding(14)
            .background(AppTheme.cardBackground)
        }
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
        .shadow(color: AppTheme.cardShadow, radius: isHovered ? 16 : 10, x: 0, y: isHovered ? 8 : 4)
        .scaleEffect(isLoaded ? 1 : 0.8)
        .opacity(isLoaded ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isLoaded = true
            }
        }
    }
    
    @ViewBuilder
    private var imageView: some View {
        AsyncImage(url: meal.thumbnailURL) { phase in
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
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.primary.opacity(0.5))
                            .pulse()
                    }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity.combined(with: .scale(scale: 1.1)))
            case .failure:
                Rectangle()
                    .fill(AppTheme.primaryLight)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.primary.opacity(0.5))
                    }
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private var floatingBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption2)
            Text("Popular")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppTheme.primary)
                .shadow(color: AppTheme.primary.opacity(0.4), radius: 4, y: 2)
        )
        .padding(10)
        .opacity(meal.name.count > 15 ? 0 : 1) // Show only for some cards
    }
}

// MARK: - Preview
#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        RecipeCardView(meal: MealPreview.preview)
        RecipeCardView(meal: MealPreview.previewList[1])
    }
    .padding()
    .background(AppTheme.background)
}
