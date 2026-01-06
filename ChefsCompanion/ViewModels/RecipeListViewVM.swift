import Foundation
import SwiftUI

/// ViewModel for the recipe list/home feed
@MainActor
final class RecipeListViewVM: ObservableObject {
    // MARK: - Published Properties
    
    @Published var categories: [MealCategory] = []
    @Published var selectedCategory: MealCategory?
    @Published var meals: [MealPreview] = []
    @Published var isLoadingCategories = false
    @Published var isLoadingMeals = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let service = MealDBService.shared
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    // MARK: - Public Methods
    
    /// Load categories and initial meals
    func loadInitialData() async {
        await fetchCategories()
        
        // Auto-select first category if available
        if let firstCategory = categories.first {
            await selectCategory(firstCategory)
        }
    }
    
    /// Fetch all categories
    func fetchCategories() async {
        isLoadingCategories = true
        errorMessage = nil
        
        do {
            categories = try await service.fetchCategories()
        } catch is CancellationError {
            // Task was cancelled - ignore silently
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoadingCategories = false
    }
    
    /// Select a category and fetch its meals
    func selectCategory(_ category: MealCategory) async {
        guard selectedCategory?.id != category.id else { return }
        
        selectedCategory = category
        await fetchMeals(for: category)
    }
    
    /// Fetch meals for a specific category
    func fetchMeals(for category: MealCategory) async {
        isLoadingMeals = true
        errorMessage = nil
        
        do {
            meals = try await service.fetchMeals(category: category.name)
        } catch is CancellationError {
            // Task was cancelled - ignore silently
        } catch {
            errorMessage = error.localizedDescription
            meals = []
        }
        
        isLoadingMeals = false
    }
    
    /// Refresh current category's meals (for pull-to-refresh)
    /// This method guards against task cancellation from SwiftUI's refreshable
    func refresh() async {
        guard let currentCategory = selectedCategory else {
            await loadInitialData()
            return
        }
        
        // Cancel any existing refresh task
        refreshTask?.cancel()
        
        // Create a new task that won't be cancelled by the parent
        refreshTask = Task.detached { [weak self, categoryName = currentCategory.name] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.isLoadingMeals = true
                self.errorMessage = nil
            }
            
            do {
                let fetchedMeals = try await self.service.fetchMeals(category: categoryName)
                await MainActor.run {
                    self.meals = fetchedMeals
                    self.isLoadingMeals = false
                }
            } catch is CancellationError {
                // Ignore cancellation
                await MainActor.run {
                    self.isLoadingMeals = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoadingMeals = false
                }
            }
        }
        
        // Wait for the detached task to complete
        await refreshTask?.value
    }
}
