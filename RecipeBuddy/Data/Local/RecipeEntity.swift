import CoreData
import Foundation

@objc(RecipeEntity)
final class RecipeEntity: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var tags: [String]?
    @NSManaged var minutes: Int32
    @NSManaged var image: String?
    @NSManaged var createdAt: Date?
}

extension RecipeEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<RecipeEntity> { NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity") }
}


