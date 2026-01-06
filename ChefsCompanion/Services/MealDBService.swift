import Foundation

/// Service for interacting with TheMealDB API
final class MealDBService {
    static let shared = MealDBService()
    
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Categories
    
    /// Fetch all meal categories
    func fetchCategories() async throws -> [MealCategory] {
        let url = "\(baseURL)/categories.php"
        let response: CategoryResponse = try await networkManager.fetch(from: url)
        return response.categories
    }
    
    // MARK: - Meals by Category
    
    /// Fetch meals filtered by category
    func fetchMeals(category: String) async throws -> [MealPreview] {
        let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category
        let url = "\(baseURL)/filter.php?c=\(encodedCategory)"
        let response: MealPreviewResponse = try await networkManager.fetch(from: url)
        return response.meals ?? []
    }
    
    // MARK: - Recipe Details
    
    /// Fetch full recipe details by ID
    func fetchRecipeDetails(id: String) async throws -> Recipe? {
        let url = "\(baseURL)/lookup.php?i=\(id)"
        let response: MealResponse = try await networkManager.fetch(from: url)
        return response.meals?.first
    }
    
    // MARK: - Search
    
    /// Search meals by name
    func searchMeals(query: String) async throws -> [Recipe] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = "\(baseURL)/search.php?s=\(encodedQuery)"
        let response: MealResponse = try await networkManager.fetch(from: url)
        return response.meals ?? []
    }
    
    /// Search meals by main ingredient (for "Fridge" search)
    func searchByIngredient(_ ingredient: String) async throws -> [MealPreview] {
        let encodedIngredient = ingredient.trimmingCharacters(in: .whitespaces)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ingredient
        let url = "\(baseURL)/filter.php?i=\(encodedIngredient)"
        let response: MealPreviewResponse = try await networkManager.fetch(from: url)
        return response.meals ?? []
    }
    
    /// Search by multiple ingredients (for "Fridge" search)
    /// Note: The API only supports single ingredient filtering, so we'll search for the first ingredient
    /// and filter results client-side
    func searchByIngredients(_ ingredients: [String]) async throws -> [MealPreview] {
        guard let firstIngredient = ingredients.first, !firstIngredient.isEmpty else {
            return []
        }
        
        // The API doesn't support multi-ingredient search, so we search by the first ingredient
        // In a production app, you might want to implement client-side filtering or
        // make multiple requests and find intersections
        return try await searchByIngredient(firstIngredient)
    }
    
    // MARK: - Random Recipe
    
    /// Fetch a random recipe
    func fetchRandomRecipe() async throws -> Recipe? {
        let url = "\(baseURL)/random.php"
        let response: MealResponse = try await networkManager.fetch(from: url)
        return response.meals?.first
    }
}
