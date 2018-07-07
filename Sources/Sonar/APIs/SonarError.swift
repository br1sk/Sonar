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

    /// Use when a 412 is received. This happens when you haven't accepted a new agreement
    static let preconditionError = SonarError(
        message: "Precondition failed, try logging in on the web to validate your account")

    init(message: String) {
        self.message = message
    }

    /// Factory to create a `SonarError` based on a `Response`.
    ///
    /// - parameter response: The HTTP resposne that is known to be failed.
    ///
    /// - returns: The error representing the problem.
    static func from<T>(_ response: DataResponse<T>) -> SonarError {
        switch response.response?.statusCode {
        case 401:
            return .authenticationError
        case 412:
			return .preconditionError
        default:
            break
        }

        switch response.result {
            case .failure(let error as NSError):
                return SonarError(message: error.localizedDescription)
            default:
                return .unknownError
        }
    }
}
