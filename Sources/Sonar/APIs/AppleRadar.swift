import Alamofire
import Foundation

final class AppleRadar: BugTracker {
    private let credentials: (appleID: String, password: String)
    private let manager: Alamofire.SessionManager
    private var CSRF: String?

    /**
     - parameter appleID:  Username to be used on `bugreport.apple.com` authentication.
     - parameter password: Password to be used on `bugreport.apple.com` authentication.
    */
    init(appleID: String, password: String) {
        self.credentials = (appleID: appleID, password: password)

        let configuration = URLSessionConfiguration.default
        let cookies = HTTPCookieStorage.shared
        configuration.httpCookieStorage = cookies
        configuration.httpCookieAcceptPolicy = .always

        self.manager = Alamofire.SessionManager(configuration: configuration)
    }

    /**
     Login into radar by an apple ID and password.

     - parameter getTwoFactorCode: A closure to retrieve a two factor auth code from the user.
     - parameter closure:          A closure that will be called when the login is completed, on success it
                                   will contain a list of `Product`s; on failure a `SonarError`.
    */
    func login(getTwoFactorCode: @escaping (_ closure: @escaping (_ code: String?) -> Void) -> Void,
               closure: @escaping (Result<Void, SonarError>) -> Void)
    {
        self.manager
            .request(AppleRadarRouter.Login(appleID: credentials.appleID, password: credentials.password))
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
                    self?.manager
                        .request(AppleRadarRouter.FetchCSRF)
                        .validate()
                        .responseString { response in
                            if case .success(let value) = response.result {
                                self?.handleCSRFResponse(string: value, closure: closure)
                            } else {
                                closure(.failure(SonarError.from(response)))
                            }
                        }
                } else {
                    closure(.failure(SonarError.from(response)))
                }
            }
    }

    /**
     Fetches the list of available products (needs authentication first).

     - parameter closure:  A closure that will be called when the login is completed, on success it will
                           contain a list of `Product`s; on failure a `SonarError`.
    */
    func products(closure: @escaping (Result<[Product], SonarError>) -> Void) {
        guard let CSRF = self.CSRF else {
            closure(.failure(SonarError(message: "User is not logged in")))
            return
        }

        self.manager
            .request(AppleRadarRouter.Products(CSRF: CSRF))
            .validate()
            .responseJSON { response in
                guard case let .success(value) = response.result else {
                    closure(.failure(SonarError.from(response)))
                    return
                }

                let products = (value as? [NSDictionary])?.flatMap(Product.init) ?? []
                closure(.success(products))
            }
    }

    /**
     Creates a new ticket into apple's radar (needs authentication first).

     - parameter radar:   The radar model with the information for the ticket.
     - parameter closure: A closure that will be called when the login is completed, on success it will
                          contain a radar ID; on failure a `SonarError`.
    */
    func create(radar: Radar, closure: @escaping (Result<Int, SonarError>) -> Void) {
        guard let CSRF = self.CSRF else {
            closure(.failure(SonarError(message: "User is not logged in")))
            return
        }

        let route = AppleRadarRouter.Create(radar: radar, CSRF: CSRF)
        let (_, method, headers, body, _) = route.components
        let createMultipart = { (data: MultipartFormData) -> Void in
            data.append(body ?? Data(), withName: "hJsonScreenVal")

            for attachment in radar.attachments {
                data.append(attachment.data, withName: "fileupload", fileName: attachment.filename,
                            mimeType: attachment.mimeType)
            }
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
                            closure(.success(radarID))
                            return
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

    private func handleCSRFResponse(string: String, closure: @escaping (Result<Void, SonarError>) -> Void) {
        if let error = string.match(pattern: "class=\"dserror\".*?>(.*?)</", group: 1) {
            closure(.failure(SonarError(message: error)))
            return
        }

        guard let CSRF = string.match(pattern: "<input.*csrftoken.*value=\"(.*)\"", group: 1) else {
            closure(.failure(SonarError(message: "CSRF not found. Maybe the ID is invalid?")))
            return
        }

        self.CSRF = CSRF
        self.products { result in
            if case let .failure(error) = result {
                closure(.failure(error))
                return
            }

            closure(.success())
        }
    }

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
            .request(AppleRadarRouter.AuthorizeTwoFactor(code: code, scnt: scnt, sessionID: sessionID))
            .validate()
            .responseString { [weak self] response in
                guard case .success = response.result else {
                    closure(.failure(SonarError.from(response)))
                    return
                }

                self?.manager
                    .request(AppleRadarRouter.FetchCSRF)
                    .validate()
                    .responseString { response in
                        if case .success(let value) = response.result {
                            self?.handleCSRFResponse(string: value, closure: closure)
                        } else {
                            closure(.failure(SonarError.from(response)))
                        }
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
