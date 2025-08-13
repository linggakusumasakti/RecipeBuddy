import Foundation

final class RecipeRepositoryImpl: RecipeRepository {
    private let remote: RecipesRemoteDataSourceProtocol
    private let local: FavoritesLocalDataSourceProtocol

    init(
        remote: RecipesRemoteDataSourceProtocol = RecipesRemoteDataSource(),
        local: FavoritesLocalDataSourceProtocol = FavoritesLocalDataSource()
    ) {
        self.remote = remote
        self.local = local
    }

    func fetchAllRecipes() async throws -> [Recipe] {
        let recipes = try await remote.fetchAll()
        return recipes
    }

    func searchRecipes(query: String) async throws -> [Recipe] {
        let all = try await fetchAllRecipes()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return all }
        let lower = trimmed.lowercased()
        return all.filter { recipe in
            if recipe.title.lowercased().contains(lower) { return true }
            if recipe.ingredients.contains(where: { $0.name.lowercased().contains(lower) }) { return true }
            return false
        }
    }

    func isFavorite(id: String) -> Bool { (try? local.isFavorite(id: id)) ?? false }
    
    func toggleFavorite(recipe: Recipe) -> Bool { ((try? local.toggleFavorite(recipe: recipe)) ?? false) }
    
    func favoriteRecipes() async throws -> [Recipe] {
        let favorites = (try? local.favoriteRecipes()) ?? []
        if favorites.isEmpty { return [] }
        return favorites.map { fav in
            Recipe(
                id: fav.id,
                title: fav.title ?? "",
                tags: fav.tags ?? [],
                minutes: Int(fav.minutes),
                image: fav.image ?? "",
                ingredients: [],
                steps: []
            )
        }
    }
    
    func favoriteReipe(id: String) async throws -> Recipe? {
        let recipes = await (try? remote.fetchAll()) ?? []
        guard let fav = recipes.first(where: { $0.id == id }) else { return nil }
        return Recipe(
            id: fav.id,
            title: fav.title,
            tags: fav.tags,
            minutes: Int(fav.minutes),
            image: fav.image,
            ingredients: fav.ingredients,
            steps: fav.steps
        )
    }
}


