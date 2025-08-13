import Foundation

public struct FilterRecipesByTagsUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    public func execute(tags: Set<String>) async throws -> [Recipe] {
        try await repository.filterRecipes(byTags: tags)
    }
}


