import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    private init() {
        let model = NSManagedObjectModel()

        let favoriteEntity = NSEntityDescription()
        favoriteEntity.name = "FavoriteRecipe"
        favoriteEntity.managedObjectClassName = NSStringFromClass(FavoriteRecipe.self)

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

        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = true

        favoriteEntity.properties = [idAttr, titleAttr, tagsAttr, minutesAttr, imageAttr, createdAtAttr]

        let recipeEntity = NSEntityDescription()
        recipeEntity.name = "RecipeEntity"
        recipeEntity.managedObjectClassName = NSStringFromClass(RecipeEntity.self)

        let rIdAttr = NSAttributeDescription()
        rIdAttr.name = "id"
        rIdAttr.attributeType = .stringAttributeType
        rIdAttr.isOptional = false

        let rTitleAttr = NSAttributeDescription()
        rTitleAttr.name = "title"
        rTitleAttr.attributeType = .stringAttributeType
        rTitleAttr.isOptional = true

        let rTagsAttr = NSAttributeDescription()
        rTagsAttr.name = "tags"
        rTagsAttr.attributeType = .transformableAttributeType
        rTagsAttr.isOptional = true
        rTagsAttr.attributeValueClassName = NSStringFromClass(NSArray.self)
        rTagsAttr.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue

        let rMinutesAttr = NSAttributeDescription()
        rMinutesAttr.name = "minutes"
        rMinutesAttr.attributeType = .integer32AttributeType
        rMinutesAttr.isOptional = false

        let rImageAttr = NSAttributeDescription()
        rImageAttr.name = "image"
        rImageAttr.attributeType = .stringAttributeType
        rImageAttr.isOptional = true

        let rCreatedAtAttr = NSAttributeDescription()
        rCreatedAtAttr.name = "createdAt"
        rCreatedAtAttr.attributeType = .dateAttributeType
        rCreatedAtAttr.isOptional = true

        recipeEntity.properties = [rIdAttr, rTitleAttr, rTagsAttr, rMinutesAttr, rImageAttr, rCreatedAtAttr]


        let plannedEntity = NSEntityDescription()
        plannedEntity.name = "PlannedRecipe"
        plannedEntity.managedObjectClassName = NSStringFromClass(PlannedRecipe.self)

        let pIdAttr = NSAttributeDescription()
        pIdAttr.name = "id"
        pIdAttr.attributeType = .stringAttributeType
        pIdAttr.isOptional = false

        let pTitleAttr = NSAttributeDescription()
        pTitleAttr.name = "title"
        pTitleAttr.attributeType = .stringAttributeType
        pTitleAttr.isOptional = true

        let pTagsAttr = NSAttributeDescription()
        pTagsAttr.name = "tags"
        pTagsAttr.attributeType = .transformableAttributeType
        pTagsAttr.isOptional = true
        pTagsAttr.attributeValueClassName = NSStringFromClass(NSArray.self)
        pTagsAttr.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue

        let pMinutesAttr = NSAttributeDescription()
        pMinutesAttr.name = "minutes"
        pMinutesAttr.attributeType = .integer32AttributeType
        pMinutesAttr.isOptional = false

        let pImageAttr = NSAttributeDescription()
        pImageAttr.name = "image"
        pImageAttr.attributeType = .stringAttributeType
        pImageAttr.isOptional = true

        let pCreatedAtAttr = NSAttributeDescription()
        pCreatedAtAttr.name = "createdAt"
        pCreatedAtAttr.attributeType = .dateAttributeType
        pCreatedAtAttr.isOptional = true

        plannedEntity.properties = [pIdAttr, pTitleAttr, pTagsAttr, pMinutesAttr, pImageAttr, pCreatedAtAttr]

        model.entities = [favoriteEntity, recipeEntity, plannedEntity]

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


