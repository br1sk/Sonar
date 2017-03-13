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

     - parameter closure: A closure that will be called when the login is completed, on success it will
                          contain a list of `Product`s; on failure a `SonarError`.
    */
    func login(closure: @escaping (Result<Void, SonarError>) -> Void) {
        self.manager
            .request(AppleRadarRouter.Login(appleID: credentials.appleID, password: credentials.password))
            .validate()
            .responseString { [weak self] response in
                guard case let .success(value) = response.result else {
                    closure(.failure(SonarError.from(response)))
                    return
                }

                if let error = value.match(pattern: "class=\"dserror\".*?>(.*?)</", group: 1) {
                    closure(.failure(SonarError(message: error)))
                    return
                }

                guard let CSRF = value.match(pattern: "<input.*csrftoken.*value=\"(.*)\"", group: 1) else {
                    closure(.failure(SonarError(message: "CSRF not found. Maybe the ID is invalid?")))
                    return
                }

                self?.CSRF = CSRF
                self?.products { result in
                    if case let .failure(error) = result {
                        closure(.failure(error))
                        return
                    }

                    closure(.success())
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

                        guard let radarID = Int(value) else {
                            if let json = jsonObject(from: value), json["isError"] as? Bool == true {
                                let message = json["message"] as? String ?? "Unknown error occurred"
                                closure(.failure(SonarError(message: message)))
                            } else {
                                closure(.failure(SonarError(message: "Invalid Radar ID received")))
                            }

                            return
                        }

                        closure(.success(radarID))
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
