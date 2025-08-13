import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var order: FavoriteSortOrder = .newestFirst
    
    private let getFavoritesUseCase: GetIsFavoritesUseCase
    private let getFavoriteRecipesUseCase: GetFavoriteRecipesUseCase
    let getFavoriteRecipeUseCase: GetFavoriteRecipeUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    
    init(
        getFavoritesUseCase: GetIsFavoritesUseCase,
        getFavoriteRecipesUseCase: GetFavoriteRecipesUseCase,
        getFavoriteRecipeUseCase: GetFavoriteRecipeUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase
    ) {
        self.getFavoritesUseCase = getFavoritesUseCase
        self.getFavoriteRecipesUseCase = getFavoriteRecipesUseCase
        self.getFavoriteRecipeUseCase = getFavoriteRecipeUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }
    
    func refresh() {
        Task { await loadFavorites() }
    }
    
    func toggleFavorite(recipe: Recipe) {
        toggleFavoriteUseCase.execute(recipe: recipe)
        Task { await loadFavorites() }
    }
    
    private func loadFavorites() async {
        do {
            let favorites = try await getFavoriteRecipesUseCase.execute(order: order)
            self.recipes = favorites
        } catch {
            self.recipes = []
        }
    }
}


