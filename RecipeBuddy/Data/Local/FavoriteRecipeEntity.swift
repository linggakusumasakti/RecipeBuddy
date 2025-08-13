import CoreData
import Foundation

@objc(FavoriteRecipe)
final class FavoriteRecipe: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var tags: [String]?
    @NSManaged var minutes: Int32
    @NSManaged var image: String?
    @NSManaged var createdAt: Date?
}

extension FavoriteRecipe {
    @nonobjc class func fetchRequest() -> NSFetchRequest<FavoriteRecipe> { NSFetchRequest<FavoriteRecipe>(entityName: "FavoriteRecipe") }
}


