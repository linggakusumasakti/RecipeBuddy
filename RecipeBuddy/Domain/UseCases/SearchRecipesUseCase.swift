import Foundation

public struct SearchRecipesUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    public func execute(query: String) async throws -> [Recipe] {
        try await repository.searchRecipes(query: query)
    }
}


