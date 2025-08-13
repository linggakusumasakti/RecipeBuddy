@testable import RecipeBuddy
import CoreData

struct TestDataFactory {
    static func makeIngredient(_ name: String, qty: String? = nil) -> Ingredient {
        Ingredient(name: name, quantity: qty)
    }

    static func makeRecipe(
        id: String,
        title: String,
        tags: [String],
        minutes: Int = 10,
        image: String = "",
        ingredients: [Ingredient] = [Ingredient(name: "Salt", quantity: nil)],
        steps: [String] = ["Mix", "Cook"]
    ) -> Recipe {
        Recipe(
            id: id,
            title: title,
            tags: tags,
            minutes: minutes,
            image: image,
            ingredients: ingredients,
            steps: steps
        )
    }

    static func sampleRecipes() -> [Recipe] {
        [
            makeRecipe(id: "1", title: "Spaghetti Bolognese", tags: ["pasta", "italian"], ingredients: [makeIngredient("spaghetti"), makeIngredient("beef"), makeIngredient("tomato")]),
            makeRecipe(id: "2", title: "Chicken Salad", tags: ["salad", "healthy"], ingredients: [makeIngredient("chicken"), makeIngredient("lettuce"), makeIngredient("tomato")]),
            makeRecipe(id: "3", title: "Avocado Toast", tags: ["breakfast", "toast"], ingredients: [makeIngredient("bread"), makeIngredient("avocado")])
        ]
    }
}

extension CoreDataStack {
    func clearAllEntities(file: StaticString = #file, line: UInt = #line) {
        let context = self.context
        context.performAndWait {
            do {
                let favRequest = FavoriteRecipe.fetchRequest()
                let favs = try context.fetch(favRequest)
                favs.forEach { context.delete($0) }

                let recipeRequest = RecipeEntity.fetchRequest()
                let recipes = try context.fetch(recipeRequest)
                recipes.forEach { context.delete($0) }

                try context.save()
            } catch {
                assertionFailure("Failed to clear Core Data: \(error)")
            }
        }
    }
}

final class CoreDataIsolation {
    static let shared = CoreDataIsolation()
    private let lock = NSLock()
    private init() {}
    func withLock<T>(_ work: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try work()
    }
}

actor AsyncIsolation {
    static let shared = AsyncIsolation()
    func run<T>(_ work: @Sendable () async throws -> T) async rethrows -> T {
        try await work()
    }
}

final class StubRecipesRemoteDataSource: RecipesRemoteDataSourceProtocol {
    var result: Result<[Recipe], Error>
    init(result: Result<[Recipe], Error>) { self.result = result }
    func fetchAll() async throws -> [Recipe] { try result.get() }
}

final class StubRecipesLocalDataSource: RecipesLocalDataSourceProtocol {
    var stored: [Recipe] = []
    func saveAll(recipes: [Recipe]) throws { stored = recipes }
    func getLocalRecipes() throws -> [Recipe] { stored }
}

final class StubRecipeRepository: RecipeRepository {
    var allRecipes: [Recipe]
    var favorites: Set<String>
    init(allRecipes: [Recipe], favorites: Set<String> = []) {
        self.allRecipes = allRecipes
        self.favorites = favorites
    }

    func fetchAllRecipes() async throws -> [Recipe] { allRecipes }

    func searchRecipes(query: String) async throws -> [Recipe] {
        let lower = query.lowercased()
        return allRecipes.filter { r in
            r.title.lowercased().contains(lower) || r.ingredients.contains { $0.name.lowercased().contains(lower) }
        }
    }

    func filterRecipes(byTags tags: Set<String>) async throws -> [Recipe] {
        guard tags.isEmpty == false else { return allRecipes }
        return allRecipes.filter { !Set($0.tags).intersection(tags).isEmpty }
    }

    func isFavorite(id: String) -> Bool { favorites.contains(id) }

    func toggleFavorite(recipe: Recipe) -> Bool {
        if favorites.contains(recipe.id) { favorites.remove(recipe.id); return false }
        favorites.insert(recipe.id); return true
    }

    func favoriteRecipes(by order: FavoriteSortOrder) async throws -> [Recipe] {
        let favs = allRecipes.filter { favorites.contains($0.id) }
        // No createdAt here; keep original order
        return favs
    }

    func favoriteReipe(id: String) async throws -> Recipe? { allRecipes.first { $0.id == id } }
}


