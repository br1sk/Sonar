import Alamofire

/// The service authentication method.
///
/// - appleRadar: Apple's radar system. Authenticated by appleID / password.
/// - openRadar:  Open radar system. Authenticated by a non expiring token.
public enum ServiceAuthentication {
    case appleRadar(appleID: String, password: String)
    case openRadar(token: String)
}

/// This protocol represents a bug tracker (such as Apple's radar or Open Radar).
protocol BugTracker {
    /// Login into bug tracker. This method will use the authentication information provided by the service
    /// enum.
    ///
    /// - parameter getTwoFactorCode: A closure to retrieve a two factor auth code from the user.
    /// - parameter closure:          A closure that will be called when the login is completed,
    ///                               on failure a `SonarError`.
    func login(getTwoFactorCode: @escaping (_ closure: @escaping (_ code: String?) -> Void) -> Void,
               closure: @escaping (Result<Void, SonarError>) -> Void)

    /// Creates a new ticket into the bug tracker (needs authentication first).
    ///
    /// - parameter radar:   The radar model with the information for the ticket.
    /// - parameter closure: A closure that will be called when the login is completed, on success it will
    ///                      contain a radar ID; on failure a `SonarError`.
    func create(radar: Radar, closure: @escaping (Result<Int, SonarError>) -> Void)
}
