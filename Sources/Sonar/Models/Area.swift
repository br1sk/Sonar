public struct Area: Equatable {
    /// Internal apple's identifier
    public let appleIdentifier: Int

    /// The name of the area; useful to use as display name (e.g. 'App Switcher').
    public let name: String

    public init(appleIdentifier: Int, name: String) {
        self.appleIdentifier = appleIdentifier
        self.name = name
    }

    public static func == (lhs: Area, rhs: Area) -> Bool {
        return lhs.appleIdentifier == rhs.appleIdentifier && lhs.name == rhs.name
    }
}
