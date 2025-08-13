import Foundation

public struct GetFavoriteRecipeUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    public func execute(id: String) async throws -> Recipe? {
        try await repository.favoriteReipe(id: id)
    }
}



