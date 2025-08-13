import Testing
@testable import RecipeBuddy

@Suite(.serialized) struct RecipeRepositoryImplTests {
    @Test func fetchAllRecipes_remoteSuccess_savesToLocal_andReturns() async throws {
        CoreDataStack.shared.clearAllEntities()
        let favoritesLocal = FavoritesLocalDataSource(stack: CoreDataStack.shared)
        let recipesLocal = RecipesLocalDataSource(stack: CoreDataStack.shared)
        let remote = StubRecipesRemoteDataSource(result: .success(TestDataFactory.sampleRecipes()))
        let sut = RecipeRepositoryImpl(remote: remote, local: favoritesLocal, recipesLocal: recipesLocal)

        let list = try await sut.fetchAllRecipes()
        #expect(list.count == 3)

        let cached = try recipesLocal.getLocalRecipes()
        #expect(cached.count == 3)
    }

    @Test func fetchAllRecipes_remoteFails_returnsLocalCache() async throws {
        CoreDataStack.shared.clearAllEntities()
        let favoritesLocal = FavoritesLocalDataSource(stack: CoreDataStack.shared)
        let recipesLocal = RecipesLocalDataSource(stack: CoreDataStack.shared)
        try recipesLocal.saveAll(recipes: [TestDataFactory.makeRecipe(id: "X", title: "Cached", tags: [])])

        enum E: Error { case boom }
        let remote = StubRecipesRemoteDataSource(result: .failure(E.boom))
        let sut = RecipeRepositoryImpl(remote: remote, local: favoritesLocal, recipesLocal: recipesLocal)

        let list = try await sut.fetchAllRecipes()
        #expect(list.map { $0.id } == ["X"])
    }

    @Test func searchRecipes_filtersByTitleAndIngredients() async throws {
        CoreDataStack.shared.clearAllEntities()
        let favoritesLocal = FavoritesLocalDataSource(stack: CoreDataStack.shared)
        let recipesLocal = RecipesLocalDataSource(stack: CoreDataStack.shared)
        let remote = StubRecipesRemoteDataSource(result: .success(TestDataFactory.sampleRecipes()))
        let sut = RecipeRepositoryImpl(remote: remote, local: favoritesLocal, recipesLocal: recipesLocal)

        let tomato = try await sut.searchRecipes(query: "tomato")
        #expect(tomato.count >= 2)

        let empty = try await sut.searchRecipes(query: "   ")
        #expect(empty.count == 3)
    }

    @Test func filterRecipes_byTags() async throws {
        CoreDataStack.shared.clearAllEntities()
        let favoritesLocal = FavoritesLocalDataSource(stack: CoreDataStack.shared)
        let recipesLocal = RecipesLocalDataSource(stack: CoreDataStack.shared)
        let remote = StubRecipesRemoteDataSource(result: .success(TestDataFactory.sampleRecipes()))
        let sut = RecipeRepositoryImpl(remote: remote, local: favoritesLocal, recipesLocal: recipesLocal)

        let pasta = try await sut.filterRecipes(byTags: ["pasta"]) 
        #expect(pasta.map { $0.id } == ["1"])

        let any = try await sut.filterRecipes(byTags: [])
        #expect(any.count == 3)
    }

    @Test func favoriteRecipes_sorting() async throws {
        CoreDataStack.shared.clearAllEntities()
        let favoritesLocal = FavoritesLocalDataSource(stack: CoreDataStack.shared)
        let recipesLocal = RecipesLocalDataSource(stack: CoreDataStack.shared)
        let remote = StubRecipesRemoteDataSource(result: .success(TestDataFactory.sampleRecipes()))
        let sut = RecipeRepositoryImpl(remote: remote, local: favoritesLocal, recipesLocal: recipesLocal)

        let all = try await sut.fetchAllRecipes()
        let r1 = all.first(where: { $0.id == "1" })
        let r2 = all.first(where: { $0.id == "2" })
        #expect(r1 != nil && r2 != nil)
        if let r1, let r2 {
            #expect(sut.toggleFavorite(recipe: r1) == true)
            try? await Task.sleep(nanoseconds: 50_000_000)
            #expect(sut.toggleFavorite(recipe: r2) == true)
        }

        let newest = try await sut.favoriteRecipes(by: .newestFirst)
        #expect(newest.first?.id == "2")
        let oldest = try await sut.favoriteRecipes(by: .oldestFirst)
        #expect(oldest.first?.id == "1")
    }

    @Test func favoriteReipe_returnsFromRemote() async throws {
        CoreDataStack.shared.clearAllEntities()
        let favoritesLocal = FavoritesLocalDataSource(stack: CoreDataStack.shared)
        let recipesLocal = RecipesLocalDataSource(stack: CoreDataStack.shared)
        let remote = StubRecipesRemoteDataSource(result: .success(TestDataFactory.sampleRecipes()))
        let sut = RecipeRepositoryImpl(remote: remote, local: favoritesLocal, recipesLocal: recipesLocal)

        let r = try await sut.favoriteReipe(id: "2")
        #expect(r?.title == "Chicken Salad")
        let none = try await sut.favoriteReipe(id: "999")
        #expect(none == nil)
    }
}


