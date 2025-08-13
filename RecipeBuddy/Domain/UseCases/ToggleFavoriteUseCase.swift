import Foundation

public struct ToggleFavoriteUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    @discardableResult
    public func execute(recipe: Recipe) -> Bool {
        let result = repository.toggleFavorite(recipe: recipe)
        return result
    }
}


