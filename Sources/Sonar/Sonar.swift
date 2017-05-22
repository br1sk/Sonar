import Alamofire
import Foundation

public class Sonar {
    private let tracker: BugTracker

    public init(service: ServiceAuthentication) {
        switch service {
            case .appleRadar(let appleID, let password):
                self.tracker = AppleRadar(appleID: appleID, password: password)

            case .openRadar(let token):
                self.tracker = OpenRadar(token: token)
        }
    }

    /// Login into bug tracker. This method will use the authentication information provided by the service enum.
    ///
    /// - parameter getTwoFactorCode: A closure to retrieve a two factor auth code from the user.
    /// - parameter closure:          A closure that will be called when the login is completed,
    ///                               on failure a `SonarError`.
    public func login(getTwoFactorCode: @escaping (_ closure: @escaping (_ code: String?) -> Void) -> Void,
                      closure: @escaping (Result<Void, SonarError>) -> Void)
    {
        self.tracker.login(getTwoFactorCode: getTwoFactorCode) { result in
            closure(result)
            self.hold()
        }
    }

    /// Creates a new ticket into the bug tracker (needs authentication first).
    ///
    /// - parameter radar:   The radar model with the information for the ticket.
    /// - parameter closure: A closure that will be called when the login is completed, on success it will
    ///                      contain a radar ID; on failure a `SonarError`.
    public func create(radar: Radar, closure: @escaping (Result<Int, SonarError>) -> Void) {
        self.tracker.create(radar: radar) { result in
            closure(result)
            self.hold()
        }
    }

    /// Similar to `create` but logs the user in first.
    ///
    /// - parameter radar:            The radar model with the information for the ticket.
    /// - parameter getTwoFactorCode: A closure to retrieve a two factor auth code from the user.
    /// - parameter closure:          A closure that will be called when the login is completed, on success it
    ///                               will contain a radar ID; on failure a `SonarError`.
    public func loginThenCreate(
        radar: Radar, getTwoFactorCode: @escaping (_ closure: @escaping (_ code: String?) -> Void) -> Void,
        closure: @escaping (Result<Int, SonarError>) -> Void)
    {
        self.tracker.login(getTwoFactorCode: getTwoFactorCode) { result in
            if case let .failure(error) = result {
                closure(.failure(error))
                return
            }

            self.create(radar: radar, closure: closure)
        }
    }

    private func hold() {}
}
