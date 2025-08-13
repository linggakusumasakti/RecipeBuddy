import Testing
@testable import RecipeBuddy

@Suite struct FavoritesViewModelTests {
    @Test @MainActor func refresh_loadsFavoritesAndToggleUpdates() async {
        let all = TestDataFactory.sampleRecipes()
        let repo = StubRecipeRepository(allRecipes: all)
        let vm = FavoritesViewModel(
            getFavoritesUseCase: GetIsFavoritesUseCase(repository: repo),
            getFavoriteRecipesUseCase: GetFavoriteRecipesUseCase(repository: repo),
            getFavoriteRecipeUseCase: GetFavoriteRecipeUseCase(repository: repo),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: repo)
        )

        vm.refresh()
        await Task.yield()
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.recipes.count == 0)

        _ = repo.toggleFavorite(recipe: all[0])
        _ = repo.toggleFavorite(recipe: all[1])
        vm.refresh()
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.recipes.count == 2)

        // Toggle via VM
        vm.toggleFavorite(recipe: all[0])
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.recipes.count == 1)
    }
}


