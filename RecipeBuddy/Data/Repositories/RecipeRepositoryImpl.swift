import Foundation

final class RecipeRepositoryImpl: RecipeRepository {
    private let remote: RecipesRemoteDataSourceProtocol
    private let local: FavoritesLocalDataSourceProtocol
    private let recipesLocal: RecipesLocalDataSourceProtocol

    init(
        remote: RecipesRemoteDataSourceProtocol = RecipesRemoteDataSource(),
        local: FavoritesLocalDataSourceProtocol = FavoritesLocalDataSource(),
        recipesLocal: RecipesLocalDataSourceProtocol = RecipesLocalDataSource()
    ) {
        self.remote = remote
        self.local = local
        self.recipesLocal = recipesLocal
    }

    func fetchAllRecipes() async throws -> [Recipe] {
        do {
            let recipes = try await remote.fetchAll()
            try? recipesLocal.saveAll(recipes: recipes)
            return recipes
        } catch {
            let localRecipes = (try? recipesLocal.getLocalRecipes()) ?? []
            return localRecipes
        }
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
    
    func filterRecipes(byTags tags: Set<String>) async throws -> [Recipe] {
        let all = try await fetchAllRecipes()
        if tags.isEmpty { return all }
        return all.filter { recipe in !Set(recipe.tags).intersection(tags).isEmpty }
    }

    func isFavorite(id: String) -> Bool { (try? local.isFavorite(id: id)) ?? false }
    
    func toggleFavorite(recipe: Recipe) -> Bool { ((try? local.toggleFavorite(recipe: recipe)) ?? false) }
    
    func favoriteRecipes(by order: FavoriteSortOrder) async throws -> [Recipe] {
        let favorites = (try? local.favoriteRecipes()) ?? []
        if favorites.isEmpty { return [] }
        let sorted: [FavoriteRecipe]
        switch order {
        case .oldestFirst:
            sorted = favorites.sorted { (a, b) in
                let aDate = a.createdAt ?? .distantPast
                let bDate = b.createdAt ?? .distantPast
                return aDate < bDate
            }
        case .newestFirst:
            sorted = favorites.sorted { (a, b) in
                let aDate = a.createdAt ?? .distantPast
                let bDate = b.createdAt ?? .distantPast
                return aDate > bDate
            }
        }
        return sorted.map { fav in
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


