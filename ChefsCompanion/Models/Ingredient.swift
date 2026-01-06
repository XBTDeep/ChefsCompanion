import Foundation

/// Represents a single ingredient with its name and measurement
struct Ingredient: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let measure: String
    
    /// Returns the ingredient with adjusted measure for different serving sizes
    func adjusted(for servings: Int, baseServings: Int = 2) -> Ingredient {
        // Try to parse numeric values from measure and adjust them
        guard servings != baseServings else { return self }
        
        let multiplier = Double(servings) / Double(baseServings)
        let adjustedMeasure = adjustMeasure(measure, by: multiplier)
        
        return Ingredient(name: name, measure: adjustedMeasure)
    }
    
    private func adjustMeasure(_ measure: String, by multiplier: Double) -> String {
        // Pattern to find numbers (including fractions like 1/2)
        let pattern = #"(\d+\.?\d*|\d+/\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return measure
        }
        
        var result = measure
        let matches = regex.matches(in: measure, range: NSRange(measure.startIndex..., in: measure))
        
        // Process matches in reverse to maintain string indices
        for match in matches.reversed() {
            if let range = Range(match.range, in: measure) {
                let numberString = String(measure[range])
                if let adjusted = adjustNumber(numberString, by: multiplier) {
                    result.replaceSubrange(range, with: adjusted)
                }
            }
        }
        
        return result
    }
    
    private func adjustNumber(_ str: String, by multiplier: Double) -> String? {
        var value: Double = 0
        
        if str.contains("/") {
            // Handle fractions like "1/2"
            let parts = str.split(separator: "/")
            if parts.count == 2,
               let numerator = Double(parts[0]),
               let denominator = Double(parts[1]),
               denominator != 0 {
                value = numerator / denominator
            } else {
                return nil
            }
        } else if let num = Double(str) {
            value = num
        } else {
            return nil
        }
        
        let adjusted = value * multiplier
        
        // Format nicely - show as integer if whole number
        if adjusted.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(adjusted))
        } else {
            return String(format: "%.1f", adjusted)
        }
    }
}
