import Foundation

public protocol RecipeRepository {
    func fetchAllRecipes() async throws -> [Recipe]
    func searchRecipes(query: String) async throws -> [Recipe]
    func filterRecipes(byTags tags: Set<String>) async throws -> [Recipe]
    func isFavorite(id: String) -> Bool
    func toggleFavorite(recipe: Recipe) -> Bool
    func favoriteRecipes(by order: FavoriteSortOrder) async throws -> [Recipe]
    func favoriteReipe(id: String) async throws -> Recipe?
}


