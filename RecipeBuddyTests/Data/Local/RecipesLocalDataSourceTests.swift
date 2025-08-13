import Testing
@testable import RecipeBuddy

@Suite(.serialized) struct RecipesLocalDataSourceTests {
    @Test func saveAll_then_getLocalRecipes_returnsSavedAsDomainModels() throws {
        CoreDataIsolation.shared.withLock {
            CoreDataStack.shared.clearAllEntities()
            let sut = RecipesLocalDataSource(stack: CoreDataStack.shared)
            let input = TestDataFactory.sampleRecipes()
            try? sut.saveAll(recipes: input)

            let loaded = try? sut.getLocalRecipes()

            #expect(loaded?.count == input.count)
            #expect(Set(loaded?.map { $0.id } ?? []) == Set(input.map { $0.id }))
            #expect(loaded?.first(where: { $0.id == "1" })?.title == "Spaghetti Bolognese")
        }
    }

    @Test func saveAll_overwritesExisting() throws {
        CoreDataIsolation.shared.withLock {
            CoreDataStack.shared.clearAllEntities()
            let sut = RecipesLocalDataSource(stack: CoreDataStack.shared)
            try? sut.saveAll(recipes: [TestDataFactory.makeRecipe(id: "A", title: "Old", tags: [])])
            try? sut.saveAll(recipes: [TestDataFactory.makeRecipe(id: "B", title: "New", tags: [])])

            let loaded = try? sut.getLocalRecipes()
            #expect((loaded ?? []).map { $0.id } == ["B"])
        }
    }
}


