import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    private init() {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "FavoriteRecipe"
        entity.managedObjectClassName = NSStringFromClass(FavoriteRecipe.self)

        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .stringAttributeType
        idAttr.isOptional = false

        let titleAttr = NSAttributeDescription()
        titleAttr.name = "title"
        titleAttr.attributeType = .stringAttributeType
        titleAttr.isOptional = true

        let tagsAttr = NSAttributeDescription()
        tagsAttr.name = "tags"
        tagsAttr.attributeType = .transformableAttributeType
        tagsAttr.isOptional = true
        tagsAttr.attributeValueClassName = NSStringFromClass(NSArray.self)
        tagsAttr.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue

        let minutesAttr = NSAttributeDescription()
        minutesAttr.name = "minutes"
        minutesAttr.attributeType = .integer32AttributeType
        minutesAttr.isOptional = false

        let imageAttr = NSAttributeDescription()
        imageAttr.name = "image"
        imageAttr.attributeType = .stringAttributeType
        imageAttr.isOptional = true

        entity.properties = [idAttr, titleAttr, tagsAttr, minutesAttr, imageAttr]
        model.entities = [entity]

        container = NSPersistentContainer(name: "RecipeBuddyModel", managedObjectModel: model)

        let appSupportURLs = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        if let appSupportURL = appSupportURLs.first {
            let storeURL = appSupportURL.appendingPathComponent("RecipeBuddy.sqlite")
            do { try FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: true) } catch { }
            let description = NSPersistentStoreDescription(url: storeURL)
            description.type = NSSQLiteStoreType
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Unresolved Core Data error: \(error)") }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext { container.viewContext }
}


