import CoreData
import Foundation

protocol PlannedLocalDataSourceProtocol {
    func isPlanned(id: String) throws -> Bool
    func togglePlanned(recipe: Recipe) throws -> Bool
    func plannedRecipes() throws -> [PlannedRecipe]
}

final class PlannedLocalDataSource: PlannedLocalDataSourceProtocol {
    private let stack: CoreDataStack
    
    init(stack: CoreDataStack = .shared) { self.stack = stack }
    
    func isPlanned(id: String) throws -> Bool {
        try plannedRecipes().contains { $0.id == id }
    }
    
    func togglePlanned(recipe: Recipe) throws -> Bool {
        if try isPlanned(id: recipe.id) {
            try removePlanned(id: recipe.id)
            return false
        } else {
            try addPlanned(recipe: recipe)
            return true
        }
    }
    
    func plannedRecipes() throws -> [PlannedRecipe] {
        let request = PlannedRecipe.fetchRequest()
        var items: [PlannedRecipe] = []
        var fetchError: Error?
        stack.context.performAndWait {
            do { items = try stack.context.fetch(request) } catch { fetchError = error }
        }
        if let error = fetchError { throw error }
        return items
    }
    
    private func addPlanned(recipe: Recipe) throws {
        var saveError: Error?
        stack.context.performAndWait {
            let context = stack.context
            let entity = NSEntityDescription.insertNewObject(forEntityName: "PlannedRecipe", into: context) as! PlannedRecipe
            entity.id = recipe.id
            entity.title = recipe.title
            entity.tags = recipe.tags
            entity.minutes = Int32(recipe.minutes)
            entity.image = recipe.image
            entity.createdAt = Date()
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let error = saveError { throw error }
    }
    
    private func removePlanned(id: String) throws {
        var saveError: Error?
        stack.context.performAndWait {
            let context = stack.context
            let request = PlannedRecipe.fetchRequest()
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


