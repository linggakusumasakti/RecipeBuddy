final class AppContainer {
    static let shared = AppContainer()

    let repository: RecipeRepository

    private init() {
        self.repository = RecipeRepositoryImpl()
    }

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchUseCase: FetchRecipesUseCase(repository: repository),
            searchUseCase: SearchRecipesUseCase(repository: repository),
            filterByTagsUseCase: FilterRecipesByTagsUseCase(repository: repository),
            getFavoritesUseCase: GetIsFavoritesUseCase(repository: repository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: repository)
        )
    }

    @MainActor
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            getFavoritesUseCase: GetIsFavoritesUseCase(repository: repository),
            getFavoriteRecipesUseCase: GetFavoriteRecipesUseCase(repository: repository),
            getFavoriteRecipeUseCase: GetFavoriteRecipeUseCase(repository: repository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: repository)
        )
    }
}
