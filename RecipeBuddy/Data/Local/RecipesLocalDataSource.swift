import CoreData
import Foundation

protocol RecipesLocalDataSourceProtocol {
    func saveAll(recipes: [Recipe]) throws
    func getLocalRecipes() throws -> [Recipe]
}

final class RecipesLocalDataSource: RecipesLocalDataSourceProtocol {
    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) { self.stack = stack }

    func saveAll(recipes: [Recipe]) throws {
        var saveError: Error?
        stack.context.performAndWait {
            let context = stack.context
            let fetchRequest = RecipeEntity.fetchRequest()
            do {
                let existing = try context.fetch(fetchRequest)
                existing.forEach { context.delete($0) }
                let now = Date()
                for recipe in recipes {
                    let entity = NSEntityDescription.insertNewObject(forEntityName: "RecipeEntity", into: context) as! RecipeEntity
                    entity.id = recipe.id
                    entity.title = recipe.title
                    entity.tags = recipe.tags
                    entity.minutes = Int32(recipe.minutes)
                    entity.image = recipe.image
                    entity.createdAt = now
                }
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let error = saveError { throw error }
    }

    func getLocalRecipes() throws -> [Recipe] {
        let request = RecipeEntity.fetchRequest()
        var items: [RecipeEntity] = []
        var fetchError: Error?
        stack.context.performAndWait {
            do { items = try stack.context.fetch(request) } catch { fetchError = error }
        }
        if let error = fetchError { throw error }
        return items.map { entity in
            Recipe(
                id: entity.id,
                title: entity.title ?? "",
                tags: entity.tags ?? [],
                minutes: Int(entity.minutes),
                image: entity.image ?? "",
                ingredients: [],
                steps: []
            )
        }
    }
}


