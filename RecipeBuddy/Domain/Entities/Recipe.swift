import Foundation

public struct Recipe: Codable, Hashable, Identifiable {
    public let id: String
    public let title: String
    public let tags: [String]
    public let minutes: Int
    public let image: String
    public let ingredients: [Ingredient]
    public let steps: [String]
}


