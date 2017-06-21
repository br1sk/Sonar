public struct Reproducibility: Equatable {
    /// Internal apple's identifier
    public let appleIdentifier: Int

    /// The name of the reproducibility; useful to use as display name (e.g. 'Sometimes').
    public let name: String

    public static func == (lhs: Reproducibility, rhs: Reproducibility) -> Bool {
        return lhs.appleIdentifier == rhs.appleIdentifier && lhs.name == rhs.name
    }
}
