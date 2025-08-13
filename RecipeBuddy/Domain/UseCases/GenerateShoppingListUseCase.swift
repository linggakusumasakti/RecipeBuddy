import Foundation

public struct ShoppingListItem: Hashable, Identifiable {
    public var id: String { name.lowercased() }
    public let name: String
    public let quantities: [String]
}

public struct GenerateShoppingListUseCase {
    private let repository: RecipeRepository
    public init(repository: RecipeRepository) { self.repository = repository }
    public func execute() async throws -> [ShoppingListItem] {
        let planned = try await repository.plannedRecipes()
        var nameToQuantities: [String: [String]] = [:]
        for recipe in planned {
            for ingredient in recipe.ingredients {
                let key = ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let qty = ingredient.quantity?.trimmingCharacters(in: .whitespacesAndNewlines)
                var arr = nameToQuantities[key] ?? []
                if let q = qty, q.isEmpty == false {
                    arr.append(q)
                } else {
                    arr.append("")
                }
                nameToQuantities[key] = arr
            }
        }
        return nameToQuantities
            .map { (key, values) in ShoppingListItem(name: key.capitalized, quantities: values) }
            .sorted { $0.name < $1.name }
    }
}


