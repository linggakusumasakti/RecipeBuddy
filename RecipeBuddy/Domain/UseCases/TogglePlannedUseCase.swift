import Foundation

public struct TogglePlannedUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    @discardableResult
    public func execute(recipe: Recipe) -> Bool {
        repository.togglePlanned(recipe: recipe)
    }
}


