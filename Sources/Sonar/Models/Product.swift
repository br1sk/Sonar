import Foundation

public struct Product: Equatable {
    /// Internal apple's identifier
    public let appleIdentifier: Int
    /// The category of the product (e.g. 'Hardware').
    public let category: String
    /// The name of the product; useful to use as display name (e.g. 'iOS').
    public let name: String

    public static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.appleIdentifier == rhs.appleIdentifier
            && lhs.category == rhs.category
            && lhs.name == rhs.name
    }
}
