public struct Classification: Equatable {
    /// Internal apple's identifier
    public let appleIdentifier: Int

    /// The name of the classification; useful to use as display name (e.g. 'UI/Usability').
    public let name: String

    public static func == (lhs: Classification, rhs: Classification) -> Bool {
        return lhs.appleIdentifier == rhs.appleIdentifier && lhs.name == rhs.name
    }
}
