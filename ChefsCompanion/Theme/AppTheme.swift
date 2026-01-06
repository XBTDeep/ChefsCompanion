import SwiftUI

/// App-wide theme system with warm, appetizing color palette
struct AppTheme {
    // MARK: - Primary Colors (Warm coral/orange)
    
    /// Vibrant coral/orange - primary brand color
    static let primary = Color(hex: "FF6B35")
    
    /// Light coral for backgrounds
    static let primaryLight = Color(hex: "FFE5DB")
    
    /// Dark coral for pressed states
    static let primaryDark = Color(hex: "E55A2B")
    
    // MARK: - Accent Colors (Warm, appetizing palette)
    
    /// Rich tomato red - for accents
    static let red = Color(hex: "E63946")
    static let redLight = Color(hex: "FFE5E7")
    
    /// Warm burgundy/maroon - for depth
    static let burgundy = Color(hex: "9D4452")
    static let burgundyLight = Color(hex: "F5E6E8")
    
    /// Peachy pink - soft complementary
    static let peach = Color(hex: "FFAB91")
    static let peachLight = Color(hex: "FFF3ED")
    
    /// Golden amber - for highlights
    static let amber = Color(hex: "FF8F00")
    static let amberLight = Color(hex: "FFF3E0")
    
    /// Warm terracotta
    static let terracotta = Color(hex: "C75B39")
    static let terracottaLight = Color(hex: "F9EAE5")
    
    // MARK: - Neutral Colors
    
    /// Background colors
    static let background = Color(hex: "FFF9F5")
    static let cardBackground = Color.white
    
    /// Text colors
    static let textPrimary = Color(hex: "3C3C3C")
    static let textSecondary = Color(hex: "777777")
    static let textMuted = Color(hex: "AFAFAF")
    
    // MARK: - Category Colors (All warm tones)
    
    static func categoryColor(for name: String) -> Color {
        switch name.lowercased() {
        case "beef", "pork", "lamb", "goat":
            return red
        case "chicken":
            return Color(hex: "FF7043") // Warm orange-red
        case "seafood":
            return terracotta
        case "vegetarian", "vegan":
            return Color(hex: "E57373") // Soft red
        case "dessert":
            return burgundy
        case "breakfast":
            return amber
        case "pasta":
            return Color(hex: "FF8A65") // Coral
        case "side", "starter":
            return peach
        default:
            return primary
        }
    }
    
    // MARK: - Shadows
    
    static let cardShadow = Color.black.opacity(0.08)
    static let buttonShadow = Color.black.opacity(0.15)
    
    // MARK: - Corner Radii
    
    static let radiusSmall: CGFloat = 12
    static let radiusMedium: CGFloat = 16
    static let radiusLarge: CGFloat = 24
    static let radiusXL: CGFloat = 32
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Bouncy Button Style

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMedium))
            .shadow(color: AppTheme.cardShadow, radius: 12, x: 0, y: 4)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
}

// MARK: - Shimmer Animation

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.5),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Animated Counter

struct AnimatedCounter: View {
    let value: Int
    
    var body: some View {
        Text("\(value)")
            .contentTransition(.numericText(value: Double(value)))
            .animation(.spring(response: 0.3), value: value)
    }
}

// MARK: - Pulse Animation

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulse() -> some View {
        modifier(PulseAnimation())
    }
}
