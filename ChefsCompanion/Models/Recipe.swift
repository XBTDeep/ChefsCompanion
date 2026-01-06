import Foundation

/// Response wrapper for meal search/lookup results
struct MealResponse: Decodable {
    let meals: [Recipe]?
}

/// Full recipe model with all details including ingredients
struct Recipe: Identifiable, Decodable {
    let id: String
    let name: String
    let category: String
    let area: String
    let instructions: String
    let thumbnailURL: URL?
    let youtubeURL: URL?
    let sourceURL: URL?
    let tags: [String]
    let ingredients: [Ingredient]
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case category = "strCategory"
        case area = "strArea"
        case instructions = "strInstructions"
        case thumbnailURL = "strMealThumb"
        case youtubeURL = "strYoutube"
        case sourceURL = "strSource"
        case tags = "strTags"
    }
    
    /// Custom decoder to handle the messy ingredient format (strIngredient1, strIngredient2, etc.)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        area = try container.decodeIfPresent(String.self, forKey: .area) ?? ""
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions) ?? ""
        
        // Handle URLs
        if let thumbString = try container.decodeIfPresent(String.self, forKey: .thumbnailURL) {
            thumbnailURL = URL(string: thumbString)
        } else {
            thumbnailURL = nil
        }
        
        if let ytString = try container.decodeIfPresent(String.self, forKey: .youtubeURL),
           !ytString.isEmpty {
            youtubeURL = URL(string: ytString)
        } else {
            youtubeURL = nil
        }
        
        if let srcString = try container.decodeIfPresent(String.self, forKey: .sourceURL),
           !srcString.isEmpty {
            sourceURL = URL(string: srcString)
        } else {
            sourceURL = nil
        }
        
        // Parse tags
        if let tagsString = try container.decodeIfPresent(String.self, forKey: .tags),
           !tagsString.isEmpty {
            tags = tagsString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        } else {
            tags = []
        }
        
        // Parse ingredients using dynamic keys
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        var parsedIngredients: [Ingredient] = []
        
        for i in 1...20 {
            let ingredientKey = DynamicCodingKey(stringValue: "strIngredient\(i)")!
            let measureKey = DynamicCodingKey(stringValue: "strMeasure\(i)")!
            
            if let ingredientName = try dynamicContainer.decodeIfPresent(String.self, forKey: ingredientKey),
               !ingredientName.trimmingCharacters(in: .whitespaces).isEmpty {
                let measure = try dynamicContainer.decodeIfPresent(String.self, forKey: measureKey) ?? ""
                parsedIngredients.append(Ingredient(
                    name: ingredientName.trimmingCharacters(in: .whitespaces),
                    measure: measure.trimmingCharacters(in: .whitespaces)
                ))
            }
        }
        
        ingredients = parsedIngredients
    }
    
    /// For preview/testing purposes
    init(id: String, name: String, category: String, area: String, instructions: String,
         thumbnailURL: URL?, youtubeURL: URL?, sourceURL: URL?, tags: [String], ingredients: [Ingredient]) {
        self.id = id
        self.name = name
        self.category = category
        self.area = area
        self.instructions = instructions
        self.thumbnailURL = thumbnailURL
        self.youtubeURL = youtubeURL
        self.sourceURL = sourceURL
        self.tags = tags
        self.ingredients = ingredients
    }
}

/// Dynamic coding key for parsing ingredient/measure keys
struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

// MARK: - Preview Helper
extension Recipe {
    static let preview = Recipe(
        id: "52772",
        name: "Teriyaki Chicken Casserole",
        category: "Chicken",
        area: "Japanese",
        instructions: "Preheat oven to 350° F. Spray a 9x13-inch baking pan with non-stick spray.\n\nCombine soy sauce, ½ cup water, brown sugar, ginger and garlic in a small saucepan and cover. Bring to a boil over medium heat. Remove lid and cook for one minute once boiling.\n\nMeanwhile, stir together the corn starch and 2 tablespoons of water in a separate dish until smooth. Once sauce is boiling, add mixture to the saucepan and stir to combine. Cook until the sauce starts to thicken then remove from heat.\n\nPlace the chicken breasts in the prepared pan. Pour one cup of the sauce over top of chicken. Place chicken in oven and bake 35 minutes or until cooked through. Remove from oven and shred chicken in the pan using two forks.",
        thumbnailURL: URL(string: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg"),
        youtubeURL: URL(string: "https://www.youtube.com/watch?v=4aZr5hZXP_s"),
        sourceURL: nil,
        tags: ["Meat", "Casserole"],
        ingredients: [
            Ingredient(name: "soy sauce", measure: "3/4 cup"),
            Ingredient(name: "water", measure: "1/2 cup"),
            Ingredient(name: "brown sugar", measure: "1/4 cup"),
            Ingredient(name: "ground ginger", measure: "1/2 teaspoon"),
            Ingredient(name: "minced garlic", measure: "1/2 teaspoon"),
            Ingredient(name: "cornstarch", measure: "4 Tablespoons"),
            Ingredient(name: "chicken breasts", measure: "2")
        ]
    )
}
