import Foundation
import SwiftUI

/// ViewModel for the recipe detail screen
@MainActor
final class RecipeDetailViewVM: ObservableObject {
    // MARK: - Published Properties
    
    @Published var recipe: Recipe?
    @Published var servingSize: Int = 2
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    
    /// Base serving size (original recipe assumed to serve 2)
    private let baseServings = 2
    
    /// Ingredients adjusted for current serving size
    var adjustedIngredients: [Ingredient] {
        guard let recipe = recipe else { return [] }
        return recipe.ingredients.map { $0.adjusted(for: servingSize, baseServings: baseServings) }
    }
    
    /// Formatted instructions with proper line breaks
    var formattedInstructions: String {
        recipe?.instructions
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// YouTube embed URL for WKWebView
    var youtubeEmbedURL: URL? {
        guard let youtubeURL = recipe?.youtubeURL,
              let videoID = extractYouTubeVideoID(from: youtubeURL) else {
            return nil
        }
        return URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1")
    }
    
    // MARK: - Private Properties
    
    private let service = MealDBService.shared
    
    // MARK: - Public Methods
    
    /// Load recipe details by ID
    func loadRecipe(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            recipe = try await service.fetchRecipeDetails(id: id)
            if recipe == nil {
                errorMessage = "Recipe not found"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Load from existing recipe (when navigating from search)
    func loadRecipe(_ recipe: Recipe) {
        self.recipe = recipe
    }
    
    /// Increment serving size
    func incrementServings() {
        if servingSize < 12 {
            servingSize += 1
        }
    }
    
    /// Decrement serving size
    func decrementServings() {
        if servingSize > 1 {
            servingSize -= 1
        }
    }
    
    /// Reset serving size to default
    func resetServings() {
        servingSize = baseServings
    }
    
    // MARK: - Private Methods
    
    /// Extract video ID from YouTube URL
    private func extractYouTubeVideoID(from url: URL) -> String? {
        let urlString = url.absoluteString
        
        // Handle youtube.com/watch?v=VIDEO_ID format
        if urlString.contains("youtube.com/watch") {
            if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
                return queryItems.first(where: { $0.name == "v" })?.value
            }
        }
        
        // Handle youtu.be/VIDEO_ID format
        if urlString.contains("youtu.be") {
            return url.lastPathComponent
        }
        
        // Handle youtube.com/embed/VIDEO_ID format
        if urlString.contains("youtube.com/embed") {
            return url.lastPathComponent
        }
        
        return nil
    }
}
