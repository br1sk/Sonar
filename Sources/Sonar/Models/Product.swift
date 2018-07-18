import Foundation

public struct Product: Equatable, Decodable {
    enum CodingKeys: String, CodingKey {
        case appleIdentifier = "componentID"
        case areas
        case category = "section"
        case name
    }

    /// Internal apple's identifier
    public let appleIdentifier: Int
    /// The category of the product (e.g. 'Hardware').
    public let category: String
    /// The name of the product; useful to use as display name (e.g. 'iOS').
    public let name: String
    /// All the areas of the product bugs can be reported against (e.g. 'Calendar')
    /// Not all product's have specific area categories, only the big products do
    public let areas: [Area]

    public static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.appleIdentifier == rhs.appleIdentifier
            && lhs.category == rhs.category
            && lhs.name == rhs.name
            && lhs.areas == rhs.areas
    }

    init(_ appleIdentifier: Int, _ name: String, _ category: String, _ areas: [Area]) {
        self.appleIdentifier = appleIdentifier
        self.category = category
        self.name = name
        self.areas = areas
    }
}
