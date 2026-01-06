import SwiftUI

/// A playful, Duolingo-style pill button for category selection
struct CategoryPillView: View {
    let category: MealCategory
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    private var categoryColor: Color {
        AppTheme.categoryColor(for: category.name)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                // Category emoji/icon
                categoryIcon
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    // Shadow layer for 3D effect
                    if isSelected {
                        RoundedRectangle(cornerRadius: AppTheme.radiusXL)
                            .fill(categoryColor.opacity(0.3))
                            .offset(y: 3)
                    }
                    
                    // Main pill
                    RoundedRectangle(cornerRadius: AppTheme.radiusXL)
                        .fill(isSelected ? categoryColor : AppTheme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.radiusXL)
                                .stroke(isSelected ? .clear : categoryColor.opacity(0.3), lineWidth: 2)
                        )
                }
            )
            .foregroundColor(isSelected ? .white : categoryColor)
        }
        .buttonStyle(BouncyButtonStyle())
    }
    
    @ViewBuilder
    private var categoryIcon: some View {
        Text(emojiForCategory)
            .font(.title3)
    }
    
    private var emojiForCategory: String {
        switch category.name.lowercased() {
        case "beef": return "🥩"
        case "chicken": return "🍗"
        case "dessert": return "🍰"
        case "lamb": return "🍖"
        case "miscellaneous": return "🍽️"
        case "pasta": return "🍝"
        case "pork": return "🥓"
        case "seafood": return "🦐"
        case "side": return "🥗"
        case "starter": return "🥟"
        case "vegan": return "🥬"
        case "vegetarian": return "🥕"
        case "breakfast": return "🍳"
        case "goat": return "🐐"
        default: return "🍴"
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 12) {
            CategoryPillView(
                category: MealCategory.preview,
                isSelected: true,
                action: {}
            )
            
            CategoryPillView(
                category: MealCategory(id: "2", name: "Chicken", thumbnailURL: nil, description: ""),
                isSelected: false,
                action: {}
            )
            
            CategoryPillView(
                category: MealCategory(id: "3", name: "Seafood", thumbnailURL: nil, description: ""),
                isSelected: false,
                action: {}
            )
        }
        .padding()
    }
    .background(AppTheme.background)
}
