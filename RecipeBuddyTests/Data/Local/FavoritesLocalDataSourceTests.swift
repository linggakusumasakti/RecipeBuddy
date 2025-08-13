import Testing
@testable import RecipeBuddy

@Suite(.serialized) struct FavoritesLocalDataSourceTests {
    @Test func toggleFavorite_addsAndRemoves() throws {
        CoreDataStack.shared.clearAllEntities()
        let sut = FavoritesLocalDataSource(stack: CoreDataStack.shared)
        let recipe = TestDataFactory.makeRecipe(id: "R1", title: "Test", tags: [])

        #expect((try? sut.isFavorite(id: recipe.id)) == false)
        #expect((try? sut.toggleFavorite(recipe: recipe)) == true)
        #expect((try? sut.isFavorite(id: recipe.id)) == true)

        #expect((try? sut.toggleFavorite(recipe: recipe)) == false)
        #expect((try? sut.isFavorite(id: recipe.id)) == false)
    }

    @Test func favoriteRecipes_returnsSavedFavorites() throws {
        CoreDataStack.shared.clearAllEntities()
        let sut = FavoritesLocalDataSource(stack: CoreDataStack.shared)
        let r1 = TestDataFactory.makeRecipe(id: "1", title: "One", tags: [])
        let r2 = TestDataFactory.makeRecipe(id: "2", title: "Two", tags: [])
        _ = try sut.toggleFavorite(recipe: r1)
        _ = try sut.toggleFavorite(recipe: r2)

        let favs = try sut.favoriteRecipes()
        #expect(Set(favs.map { $0.id }) == Set(["1", "2"]))
        #expect(favs.first?.createdAt != nil)
    }
}


