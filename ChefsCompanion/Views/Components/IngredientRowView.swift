import SwiftUI

/// A colorful, playful ingredient row with Duolingo-style design
struct IngredientRowView: View {
    let ingredient: Ingredient
    let index: Int
    
    @State private var isVisible = false
    
    private var accentColor: Color {
        let colors: [Color] = [
            AppTheme.primary,
            AppTheme.red,
            AppTheme.terracotta,
            AppTheme.amber,
            AppTheme.burgundy
        ]
        return colors[index % colors.count]
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Animated number badge
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Circle()
                    .stroke(accentColor, lineWidth: 2)
                    .frame(width: 36, height: 36)
                
                Text("\(index)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(accentColor)
            }
            .scaleEffect(isVisible ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(index) * 0.05), value: isVisible)
            
            // Ingredient name with icon
            HStack(spacing: 6) {
                Text(ingredientEmoji)
                    .font(.body)
                
                Text(ingredient.name.capitalized)
                    .font(.body)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .opacity(isVisible ? 1 : 0)
            .offset(x: isVisible ? 0 : -20)
            .animation(.spring(response: 0.4).delay(Double(index) * 0.05 + 0.1), value: isVisible)
            
            Spacer()
            
            // Measure with background
            Text(ingredient.measure)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(accentColor.opacity(0.12))
                )
                .opacity(isVisible ? 1 : 0)
                .animation(.spring(response: 0.4).delay(Double(index) * 0.05 + 0.2), value: isVisible)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .onAppear {
            isVisible = true
        }
    }
    
    private var ingredientEmoji: String {
        let name = ingredient.name.lowercased()
        
        if name.contains("chicken") { return "🍗" }
        if name.contains("beef") || name.contains("steak") { return "🥩" }
        if name.contains("fish") || name.contains("salmon") || name.contains("tuna") { return "🐟" }
        if name.contains("egg") { return "🥚" }
        if name.contains("milk") || name.contains("cream") { return "🥛" }
        if name.contains("cheese") { return "🧀" }
        if name.contains("butter") { return "🧈" }
        if name.contains("onion") { return "🧅" }
        if name.contains("garlic") { return "🧄" }
        if name.contains("tomato") { return "🍅" }
        if name.contains("pepper") { return "🌶️" }
        if name.contains("carrot") { return "🥕" }
        if name.contains("potato") { return "🥔" }
        if name.contains("rice") { return "🍚" }
        if name.contains("pasta") || name.contains("spaghetti") { return "🍝" }
        if name.contains("bread") { return "🍞" }
        if name.contains("oil") { return "🫒" }
        if name.contains("honey") { return "🍯" }
        if name.contains("sugar") { return "🍬" }
        if name.contains("salt") { return "🧂" }
        if name.contains("lemon") || name.contains("lime") { return "🍋" }
        if name.contains("apple") { return "🍎" }
        if name.contains("banana") { return "🍌" }
        if name.contains("mushroom") { return "🍄" }
        if name.contains("broccoli") { return "🥦" }
        if name.contains("lettuce") || name.contains("salad") { return "🥬" }
        if name.contains("corn") { return "🌽" }
        if name.contains("shrimp") || name.contains("prawn") { return "🦐" }
        if name.contains("water") { return "💧" }
        if name.contains("wine") { return "🍷" }
        if name.contains("soy") { return "🫙" }
        
        return "•"
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        ForEach(Array(Recipe.preview.ingredients.prefix(5).enumerated()), id: \.element.id) { index, ingredient in
            IngredientRowView(ingredient: ingredient, index: index + 1)
            if index < 4 {
                Divider()
                    .padding(.leading, 54)
            }
        }
    }
    .padding()
    .background(AppTheme.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
    .padding()
    .background(AppTheme.background)
}
