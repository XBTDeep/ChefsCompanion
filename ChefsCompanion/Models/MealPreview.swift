import Foundation

/// Response wrapper for filtered meal results
struct MealPreviewResponse: Decodable {
    let meals: [MealPreview]?
}

/// Lightweight meal preview for list displays (from filter endpoints)
struct MealPreview: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let thumbnailURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case thumbnailURL = "strMealThumb"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        if let thumbString = try container.decodeIfPresent(String.self, forKey: .thumbnailURL) {
            thumbnailURL = URL(string: thumbString)
        } else {
            thumbnailURL = nil
        }
    }
    
    init(id: String, name: String, thumbnailURL: URL?) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbnailURL
    }
}

// MARK: - Preview Helpers
extension MealPreview {
    static let preview = MealPreview(
        id: "52772",
        name: "Teriyaki Chicken Casserole",
        thumbnailURL: URL(string: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg")
    )
    
    static let previewList: [MealPreview] = [
        MealPreview(id: "52772", name: "Teriyaki Chicken Casserole", thumbnailURL: URL(string: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg")),
        MealPreview(id: "52773", name: "Honey Teriyaki Salmon", thumbnailURL: URL(string: "https://www.themealdb.com/images/media/meals/xxyupu1468262513.jpg")),
        MealPreview(id: "52777", name: "Mediterranean Pasta Salad", thumbnailURL: URL(string: "https://www.themealdb.com/images/media/meals/wvqpwt1468339226.jpg")),
        MealPreview(id: "52819", name: "Cajun Spiced Fish Tacos", thumbnailURL: URL(string: "https://www.themealdb.com/images/media/meals/uvuyxu1503067369.jpg"))
    ]
}
