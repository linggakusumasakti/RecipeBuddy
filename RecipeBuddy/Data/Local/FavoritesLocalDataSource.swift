import CoreData
import Foundation

protocol FavoritesLocalDataSourceProtocol {
    func isFavorite(id: String) throws -> Bool
    func toggleFavorite(recipe: Recipe) throws -> Bool
    func favoriteRecipes() throws -> [FavoriteRecipe]
}

final class FavoritesLocalDataSource: FavoritesLocalDataSourceProtocol {
    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) { self.stack = stack }

    func isFavorite(id: String) throws -> Bool {
        try favoriteRecipes().contains { $0.id == id }
    }

    func toggleFavorite(recipe: Recipe) throws -> Bool {
        if try isFavorite(id: recipe.id) {
            try removeFavorite(id: recipe.id)
            return false
        } else {
            try addFavorite(recipe: recipe)
            return true
        }
    }

    func favoriteRecipes() throws -> [FavoriteRecipe] {
        let request = FavoriteRecipe.fetchRequest()
        var items: [FavoriteRecipe] = []
        var fetchError: Error?
        stack.context.performAndWait {
            do { items = try stack.context.fetch(request) } catch { fetchError = error }
        }
        if let error = fetchError { throw error }
        return items
    }

    private func addFavorite(recipe: Recipe) throws {
        var saveError: Error?
        stack.context.performAndWait {
            let context = stack.context
            let entity = NSEntityDescription.insertNewObject(forEntityName: "FavoriteRecipe", into: context) as! FavoriteRecipe
            entity.id = recipe.id
            entity.title = recipe.title
            entity.tags = recipe.tags
            entity.minutes = Int32(recipe.minutes)
            entity.image = recipe.image
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let error = saveError { throw error }
    }

    private func removeFavorite(id: String) throws {
        var saveError: Error?
        stack.context.performAndWait {
            let context = stack.context
            let request = FavoriteRecipe.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            do {
                let items = try context.fetch(request)
                items.forEach { context.delete($0) }
                try context.save()
            } catch { saveError = error }
        }
        if let error = saveError { throw error }
    }
}


