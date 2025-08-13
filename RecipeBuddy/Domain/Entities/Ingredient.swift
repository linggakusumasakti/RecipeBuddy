import Foundation

public struct Ingredient: Codable, Hashable, Identifiable {
    public var id: String { name + (quantity ?? "") }
    public let name: String
    public let quantity: String?
}


