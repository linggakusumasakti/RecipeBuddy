import Testing
@testable import RecipeBuddy

@Suite(.serialized) struct HomeViewModelTests {
    @MainActor func makeVM(recipes: [Recipe]) -> HomeViewModel {
        let repo = StubRecipeRepository(allRecipes: recipes)
        return HomeViewModel(
            fetchUseCase: FetchRecipesUseCase(repository: repo),
            searchUseCase: SearchRecipesUseCase(repository: repo),
            filterByTagsUseCase: FilterRecipesByTagsUseCase(repository: repo),
            getFavoritesUseCase: GetIsFavoritesUseCase(repository: repo),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: repo)
        )
    }

    @Test @MainActor func load_populatesRecipesAndTags() async {
        let vm = makeVM(recipes: TestDataFactory.sampleRecipes())
        vm.load()
        
        await Task.yield()
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(vm.state == .loaded)
        #expect(vm.recipes.count == 3)
        #expect(vm.availableTags.isEmpty == false)
    }

    @Test @MainActor func search_filtersResults() async {
        let vm = makeVM(recipes: TestDataFactory.sampleRecipes())
        vm.searchText = "tomato"
        vm.onSearchTextChange(vm.searchText)
        await Task.yield()
        try? await Task.sleep(nanoseconds: 800_000_000)
        await Task.yield()
        try? await Task.sleep(nanoseconds: 50_000_000)

        #expect(vm.recipes.count >= 2)
        #expect(vm.state == .loaded)
    }

    @Test @MainActor func toggleTag_filtersByTags() async {
        let vm = makeVM(recipes: TestDataFactory.sampleRecipes())
        vm.load()
        await Task.yield()
        try? await Task.sleep(nanoseconds: 50_000_000)

        vm.toggleTag("pasta")

        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(vm.recipes.map { $0.id } == ["1"])
    }
}


