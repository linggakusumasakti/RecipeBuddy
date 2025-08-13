import Testing
@testable import RecipeBuddy

@Suite(.serialized) struct RecipesRemoteDataSourceTests {
    @Test func fetchAll_loadsFromBundleJSON() async throws {
        let sut = RecipesRemoteDataSource()
        let recipes = try await sut.fetchAll()
        #expect(recipes.isEmpty == false)
        let first = recipes.first
        #expect(first != nil)
        #expect(first?.title.isEmpty == false)
    }
}


