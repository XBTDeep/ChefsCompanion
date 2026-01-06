import Foundation
import SwiftUI

/// ViewModel for the "Fridge" search feature
@MainActor
final class FridgeSearchViewVM: ObservableObject {
    // MARK: - Published Properties
    
    @Published var searchText: String = ""
    @Published var searchResults: [MealPreview] = []
    @Published var nameSearchResults: [Recipe] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var searchMode: SearchMode = .byName
    
    // MARK: - Computed Properties
    
    /// Parsed ingredients from search text (for fridge search)
    var parsedIngredients: [String] {
        searchText
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    /// Whether there are any search results
    var hasResults: Bool {
        switch searchMode {
        case .byName:
            return !nameSearchResults.isEmpty
        case .byIngredient:
            return !searchResults.isEmpty
        }
    }
    
    /// Whether the search text is valid
    var canSearch: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Types
    
    enum SearchMode: String, CaseIterable {
        case byName = "By Name"
        case byIngredient = "By Ingredient"
        
        var icon: String {
            switch self {
            case .byName:
                return "text.magnifyingglass"
            case .byIngredient:
                return "refrigerator"
            }
        }
        
        var placeholder: String {
            switch self {
            case .byName:
                return "Search recipes..."
            case .byIngredient:
                return "Chicken, Rice, Garlic..."
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let service = MealDBService.shared
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Public Methods
    
    /// Perform debounced search as user types
    func performDebouncedSearch() {
        // Cancel any existing search task
        searchTask?.cancel()
        
        // Don't search if text is empty
        guard canSearch else {
            searchResults = []
            nameSearchResults = []
            errorMessage = nil
            return
        }
        
        // Create a new debounced search task
        searchTask = Task {
            // Wait 300ms before searching (debounce)
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            // Check if task was cancelled during the wait
            guard !Task.isCancelled else { return }
            
            await search()
        }
    }
    
    /// Perform search based on current mode
    func search() async {
        guard canSearch else { return }
        
        isSearching = true
        errorMessage = nil
        
        do {
            switch searchMode {
            case .byName:
                nameSearchResults = try await service.searchMeals(query: searchText)
                searchResults = []
                
            case .byIngredient:
                searchResults = try await service.searchByIngredients(parsedIngredients)
                nameSearchResults = []
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSearching = false
    }
    
    /// Clear search results
    func clearSearch() {
        searchText = ""
        searchResults = []
        nameSearchResults = []
        errorMessage = nil
    }
    
    /// Switch search mode
    func switchMode(to mode: SearchMode) {
        if searchMode != mode {
            searchMode = mode
            clearSearch()
        }
    }
}
