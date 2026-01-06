import Foundation

/// Response wrapper for categories endpoint
struct CategoryResponse: Decodable {
    let categories: [MealCategory]
}

/// Represents a meal category (Beef, Chicken, Dessert, etc.)
struct MealCategory: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let thumbnailURL: URL?
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id = "idCategory"
        case name = "strCategory"
        case thumbnailURL = "strCategoryThumb"
        case description = "strCategoryDescription"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        
        if let thumbString = try container.decodeIfPresent(String.self, forKey: .thumbnailURL) {
            thumbnailURL = URL(string: thumbString)
        } else {
            thumbnailURL = nil
        }
    }
    
    init(id: String, name: String, thumbnailURL: URL?, description: String) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbnailURL
        self.description = description
    }
}

// MARK: - Preview Helpers
extension MealCategory {
    static let preview = MealCategory(
        id: "1",
        name: "Beef",
        thumbnailURL: URL(string: "https://www.themealdb.com/images/category/beef.png"),
        description: "Beef is the culinary name for meat from cattle."
    )
    
    static let previewList: [MealCategory] = [
        MealCategory(id: "1", name: "Beef", thumbnailURL: nil, description: ""),
        MealCategory(id: "2", name: "Chicken", thumbnailURL: nil, description: ""),
        MealCategory(id: "3", name: "Dessert", thumbnailURL: nil, description: ""),
        MealCategory(id: "8", name: "Seafood", thumbnailURL: nil, description: ""),
        MealCategory(id: "11", name: "Vegan", thumbnailURL: nil, description: ""),
        MealCategory(id: "13", name: "Breakfast", thumbnailURL: nil, description: "")
    ]
}
