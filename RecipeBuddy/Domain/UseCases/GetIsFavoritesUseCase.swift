import Foundation

public struct GetIsFavoritesUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    public func execute(id: String) -> Bool { repository.isFavorite(id: id) }
}


