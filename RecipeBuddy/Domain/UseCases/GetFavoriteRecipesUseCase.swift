import Foundation

public struct GetFavoriteRecipesUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    public func execute(order: FavoriteSortOrder) async throws -> [Recipe] {
        try await repository.favoriteRecipes(by: order)
    }
}



