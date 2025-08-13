import CoreData
import Foundation

@objc(PlannedRecipe)
final class PlannedRecipe: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var tags: [String]?
    @NSManaged var minutes: Int32
    @NSManaged var image: String?
    @NSManaged var createdAt: Date?
}

extension PlannedRecipe {
    @nonobjc class func fetchRequest() -> NSFetchRequest<PlannedRecipe> { NSFetchRequest<PlannedRecipe>(entityName: "PlannedRecipe") }
}


