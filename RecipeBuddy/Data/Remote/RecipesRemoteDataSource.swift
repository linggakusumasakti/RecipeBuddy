import Foundation

protocol RecipesRemoteDataSourceProtocol {
    func fetchAll() async throws -> [Recipe]
}

final class RecipesRemoteDataSource: RecipesRemoteDataSourceProtocol {

    func fetchAll() async throws -> [Recipe] {
        let recipes: [Recipe] = try BundleJSONLoader.load([Recipe].self, filename: "recipes.json")
        return recipes
    }
}


