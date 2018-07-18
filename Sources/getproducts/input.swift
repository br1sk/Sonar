import Foundation

enum InputError: Error {
    /// CTRL-D was pressed
    case quit
}

/// Ask the user for an input string
/// NOTE: If the user enters an empty string, we re-ask recursively
///
/// - parameter prompt: This is printed on the same line as the input before asking
///
/// - throws: InputError.quit if the user presses CTRL-D
///
/// - returns: The input from the user
func getInput(_ prompt: String, secure: Bool = false) throws -> String {
    let input: String?

    if secure {
        let cString = getpass("\(prompt) ")
        input = cString.flatMap { String(validatingUTF8: $0) }
    } else {
        print(prompt, terminator: " ")
        input = readLine()
    }

    switch input {
    case let line? where line.isEmpty:
        return try getInput(prompt, secure: secure)
    case let line?:
        return line
    case nil:
        throw InputError.quit
    }
}
