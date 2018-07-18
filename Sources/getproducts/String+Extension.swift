extension String {
    /// Strip characters that would case an identifier to be invalid
    ///
    /// - returns: A string with spaces and other special characters stripped
    func stripInvalidIdentifierChars() -> String {
        return self
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "&", with: "")
            .replacingOccurrences(of: "/", with: "")
    }

    /// Lowercase the first letter of the current string
    ///
    /// - returns: A new string with the first letter lowercased
    func lowercaseFirstLetter() -> String {
        return self.prefix(1).lowercased() + self.dropFirst()
    }
}
