import Foundation

public struct GetIsPlannedUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    public func execute(id: String) -> Bool {
        repository.isPlanned(id: id)
    }
}


