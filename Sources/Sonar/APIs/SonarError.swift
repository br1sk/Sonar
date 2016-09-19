import Alamofire

/**
 Represents an error on the communication and/or response parsing.
*/
public struct SonarError: ErrorType {
    /// The message that represents the error condition.
    public let message: String

    /// Used to catch the things we can't gracefully fail.
    static let UnknownError = SonarError(message: "Unknown error")

    /// Used when the token expires.
    static let AuthenticationError = SonarError(message: "Unauthorize")

    init(message: String) {
        self.message = message
    }

    /**
     Factory to create a `SonarError` based on a `Response`.

     - parameter response: The HTTP resposne that is known to be failed.

     - returns: The error representing the problem.
    */
    static func fromResponse<T, U: ErrorType>(response: Response<T, U>) -> SonarError {
        if response.response?.statusCode == 401 {
            return .AuthenticationError
        }

        switch response.result {
            case .Failure(let error as NSError):
                return SonarError(message: error.localizedDescription)
            case .Failure(let error):
                return SonarError(message: String(error))
            default:
                return .UnknownError
        }
    }
}
