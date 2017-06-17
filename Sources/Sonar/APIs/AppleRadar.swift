import Alamofire
import Foundation

final class AppleRadar: BugTracker {
    private let credentials: (appleID: String, password: String)
    private let manager: Alamofire.SessionManager
    private var token: String?

    /// - parameter appleID:  Username to be used on `bugreport.apple.com` authentication.
    /// - parameter password: Password to be used on `bugreport.apple.com` authentication.
    init(appleID: String, password: String) {
        self.credentials = (appleID: appleID, password: password)

        let configuration = URLSessionConfiguration.default
        let cookies = HTTPCookieStorage.shared
        configuration.httpCookieStorage = cookies
        configuration.httpCookieAcceptPolicy = .always

        self.manager = Alamofire.SessionManager(configuration: configuration)
    }

    /// Login into radar by an apple ID and password.
    ///
    /// - parameter getTwoFactorCode: A closure to retrieve a two factor auth code from the user.
    /// - parameter closure:          A closure that will be called when the login is completed, on success it
    ///                               will contain a list of `Product`s; on failure a `SonarError`.
    func login(getTwoFactorCode: @escaping (_ closure: @escaping (_ code: String?) -> Void) -> Void,
               closure: @escaping (Result<Void, SonarError>) -> Void)
    {
        self.manager
            .request(AppleRadarRouter.accountInfo(appleID: credentials.appleID,
                                                  password: credentials.password))
            .validate()
            .responseString { [weak self] response in
                if let httpResponse = response.response, httpResponse.statusCode == 409 {
                    getTwoFactorCode { code in
                        if let code = code {
                            self?.handleTwoFactorChallenge(code: code, headers: httpResponse.allHeaderFields,
                                                           closure: closure)
                        } else {
                            closure(.failure(SonarError(message: "No 2 factor auth code provided")))
                        }
                    }
                } else if case .success = response.result {
                    self?.fetchAccessToken(closure: closure)
                } else {
                    closure(.failure(SonarError.from(response)))
                }
            }
    }

    /// Creates a new ticket into apple's radar (needs authentication first).
    ///
    /// - parameter radar:   The radar model with the information for the ticket.
    /// - parameter closure: A closure that will be called when the login is completed, on success it will
    ///                      contain a radar ID; on failure a `SonarError`.
    func create(radar: Radar, closure: @escaping (Result<Int, SonarError>) -> Void) {
        guard let token = self.token else {
            closure(.failure(SonarError(message: "User is not logged in")))
            return
        }

        let route = AppleRadarRouter.create(radar: radar, token: token)
        let (_, method, headers, body, _) = route.components
        let createMultipart = { (data: MultipartFormData) -> Void in
            data.append(body ?? Data(), withName: "hJsonScreenVal")
        }

        self.manager
            .upload(multipartFormData: createMultipart, to: route.url, method: method, headers: headers)
                { result in
                    guard case let .success(upload, _, _) = result else {
                        closure(.failure(.unknownError))
                        return
                    }

                    upload.validate().responseString { response in
                        guard case let .success(value) = response.result else {
                            closure(.failure(SonarError.from(response)))
                            return
                        }

                        if let radarID = Int(value) {
                            return self.uploadAttachments(radarID: radarID, attachments: radar.attachments,
                                                          token: token, closure: closure)
                        }

                        if let json = jsonObject(from: value), json["isError"] as? Bool == true {
                            let message = json["message"] as? String ?? "Unknown error occurred"
                            closure(.failure(SonarError(message: message)))
                        } else {
                            closure(.failure(SonarError(message: "Invalid Radar ID received")))
                        }
                    }
                }
    }

    // MARK: - Private Functions

    private func handleTwoFactorChallenge(code: String, headers: [AnyHashable: Any],
                                          closure: @escaping (Result<Void, SonarError>) -> Void)
    {
        guard let sessionID = headers["X-Apple-ID-Session-Id"] as? String,
            let scnt = headers["scnt"] as? String else
        {
            closure(.failure(SonarError(message: "Missing Session-Id or scnt")))
            return
        }

        self.manager
            .request(AppleRadarRouter.authorizeTwoFactor(code: code, scnt: scnt, sessionID: sessionID))
            .validate()
            .responseString { [weak self] response in
                guard case .success = response.result else {
                    closure(.failure(SonarError.from(response)))
                    return
                }

                self?.manager
                    .request(AppleRadarRouter.sessionID)
                    .validate()
                    .responseString { [weak self] response in
                        if case .success = response.result {
                            self?.fetchAccessToken(closure: closure)
                        } else {
                            closure(.failure(SonarError.from(response)))
                        }
                    }
            }
    }

    private func fetchAccessToken(closure: @escaping (Result<Void, SonarError>) -> Void) {
        self.manager
            .request(AppleRadarRouter.sessionID)
            .validate()
            .response { [weak self] _ in
                self?.manager
                    .request(AppleRadarRouter.accessToken)
                    .validate()
                    .responseJSON { [weak self] response in
                        if case .success(let value) = response.result,
                            let dictionary = value as? NSDictionary,
                            let token = dictionary["accessToken"] as? String
                        {
                            self?.token = token
                            closure(.success())
                        } else {
                            closure(.failure(SonarError.from(response)))
                        }
                    }
            }
    }

    private func uploadAttachments(radarID: Int, attachments: [Attachment], token: String,
                                   closure: @escaping (Result<Int, SonarError>) -> Void)
    {
        if attachments.isEmpty {
            return closure(.success(radarID))
        }

        var successful = true
        let group = DispatchGroup()

        for attachment in attachments {
            group.enter()

            let route = AppleRadarRouter.uploadAttachment(radarID: radarID, attachment: attachment,
                                                          token: token)
            assert(route.components.data == nil, "The data is uploaded manually, not from the route")

            self.manager
                .upload(attachment.data, with: route)
                .validate(statusCode: [201])
                .response { result in
                    defer {
                        group.leave()
                    }

                    successful = successful && result.response?.statusCode == 201
                }
        }

        group.notify(queue: .main) {
            if successful {
                closure(.success(radarID))
            } else {
                closure(.failure(SonarError(message: "Failed to upload attachments")))
            }
        }
    }
}

private func jsonObject(from string: String) -> [String: Any]? {
    guard let data = string.data(using: .utf8) else {
        return nil
    }

    return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
}
