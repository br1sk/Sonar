import Alamofire
import Foundation

class OpenRadar: BugTracker {
    private let manager: Alamofire.SessionManager

    init(token: String) {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": token]

        self.manager = Alamofire.SessionManager(configuration: configuration)
    }

    /// Login into open radar. This is actually a NOP for now (token is saved into the session).
    ///
    /// - parameter getTwoFactorCode: A closure to retrieve a two factor auth code from the user
    /// - parameter closure:          A closure that will be called when the login is completed, on success it
    ///                               will contain a list of `Product`s; on failure a `SonarError`.
    func login(getTwoFactorCode: @escaping (_ closure: @escaping (_ code: String?) -> Void) -> Void,
               closure: @escaping (Result<Void, SonarError>) -> Void)
    {
        closure(.success())
    }

    /// Creates a new ticket into open radar (needs authentication first).
    ///
    /// - parameter radar:   The radar model with the information for the ticket.
    /// - parameter closure: A closure that will be called when the login is completed, on success it will
    ///                      contain a radar ID; on failure a `SonarError`.
    func create(radar: Radar, closure: @escaping (Result<Int, SonarError>) -> Void) {
        guard let ID = radar.ID else {
            closure(.failure(SonarError(message: "Invalid radar ID")))
            return
        }

        self.manager
            .request(OpenRadarRouter.create(radar: radar))
            .validate()
            .responseJSON { response in
                guard case .success = response.result else {
                    closure(.failure(SonarError.from(response)))
                    return
                }

                closure(.success(ID))
            }
    }
}
