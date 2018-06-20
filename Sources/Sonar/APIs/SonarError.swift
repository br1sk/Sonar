import Alamofire
import Foundation

/// Represents an error on the communication and/or response parsing.
public struct SonarError: Error {
    /// The message that represents the error condition.
    public let message: String

    /// Used to catch the things we can't gracefully fail.
    static let unknownError = SonarError(message: "Unknown error")

    /// Used when the token expires.
    static let authenticationError = SonarError(message: "Unauthorized, perhaps you have the wrong password")

    init(message: String) {
        self.message = message
    }

    /// Factory to create a `SonarError` based on a `Response`.
    ///
    /// - parameter response: The HTTP resposne that is known to be failed.
    ///
    /// - returns: The error representing the problem.
    static func from<T>(_ response: DataResponse<T>) -> SonarError {
        if response.response?.statusCode == 401 {
            return .authenticationError
        }

        switch response.result {
            case .failure(let error as NSError):
                return SonarError(message: error.localizedDescription)
            default:
                return .unknownError
        }
    }
}
