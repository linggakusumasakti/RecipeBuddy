import Foundation

public struct FetchRecipesUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    public func execute() async throws -> [Recipe] {
        try await repository.fetchAllRecipes()
    }
}


