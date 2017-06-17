import Alamofire
import Foundation

typealias Components = (path: String, method: HTTPMethod, headers: [String: String],
                        data: Data?, parameters: [String: String])

/// Apple's radar request router.
///
/// - accessToken:        Fetch the access token to be sent in the `Radar-Authentication` header
/// - accountInfo:        Fetch the `myacinfo` cookie based on an apple ID and password
/// - authorizeTwoFactor: The `Route` used to login with two factor auth.
/// - create:             The `Route` used to create a new radar.
/// - sessionID:          Fetch the `JSESSIONID` cookie using the previously set `myacinfo` cookie
/// - viewProblem:        The main apple's radar page.
enum AppleRadarRouter {
    case accountInfo(appleID: String, password: String)
    case authorizeTwoFactor(code: String, scnt: String, sessionID: String)
    case accessToken
    case create(radar: Radar, token: String)
    case sessionID
    case viewProblem
    case uploadAttachment(radarID: Int, attachment: Attachment, token: String)

    fileprivate static let baseURL = URL(string: "https://bugreport.apple.com")!

    /// The request components including headers and parameters.
    var components: Components {
        switch self {
            case .viewProblem:
                return (path: "/problem/viewproblem", method: .get, headers: [:], data: nil, parameters: [:])

            case .authorizeTwoFactor(let code, let scnt, let sessionID):
                let fullURL = "https://idmsa.apple.com/appleauth/auth/verify/trusteddevice/securitycode"
                let headers = [
                    "Accept": "application/json",
                    "Content-Type": "application/json",
                    "scnt": scnt,
                    "X-Apple-App-Id": "21",
                    "X-Apple-ID-Session-Id": sessionID,
                    "X-Apple-Widget-Key": "16452abf721961a1728885bef033f28e",
                    "X-Requested-With": "XMLHttpRequest",
                ]

                let JSON: [String: Any] = [
                    "securityCode": [
                        "code": code,
                    ],
                ]

                let body = try! JSONSerialization.data(withJSONObject: JSON, options: [])
                return (path: fullURL, method: .post, headers: headers, data: body, parameters: [:])

            case .accountInfo(let appleID, let password):
                let fullURL = "https://idmsa.apple.com/appleauth/auth/signin"
                let headers = [
                    "Accept": "application/json, text/javascript, */*; q=0.01",
                    "Content-Type": "application/json",
                    "X-Apple-App-Id": "21",
                    "X-Apple-Widget-Key": "16452abf721961a1728885bef033f28e",
                    "X-Requested-With": "XMLHttpRequest",
                ]

                let JSON: [String: Any] = [
                    "accountName": appleID,
                    "password": password,
                    "rememberMe": false,
                ]

                let body = try! JSONSerialization.data(withJSONObject: JSON, options: [])
                return (path: fullURL, method: .post, headers: headers, data: body, parameters: [:])

            case .sessionID:
                return (path: "/", method: .get, headers: [:], data: nil, parameters: [:])

            case .accessToken:
                let headers = ["Accept": "application/json, text/plain, */*"]
                return (path: "/developerUISignon", method: .get, headers: headers, data: nil,
                        parameters: [:])

            case .create(let radar, let token):
                let JSON: [String: Any] = [
                    "problemTitle": radar.title,
                    "configIDPop": "",
                    "configTitlePop": "",
                    "configDescriptionPop": "",
                    "configurationText": radar.configuration,
                    "notes": radar.notes,
                    "configurationSplit": "Configuration:\r\n",
                    "configurationSplitValue": radar.configuration,
                    "workAroundText": "",
                    "descriptionText": radar.body,
                    "problemAreaTypeCode": radar.area.map { String($0.appleIdentifier) } ?? "",
                    "classificationCode": String(radar.classification.appleIdentifier),
                    "reproducibilityCode": String(radar.reproducibility.appleIdentifier),
                    "component": [
                        "ID": String(radar.product.appleIdentifier),
                        "compName": radar.product.name,
                    ],
                    "draftID": "",
                    "draftFlag": "",
                    "versionBuild": radar.version,
                    "desctextvalidate": radar.body,
                    "stepstoreprvalidate": radar.steps,
                    "experesultsvalidate": radar.expected,
                    "actresultsvalidate": radar.actual,
                    "addnotesvalidate": radar.notes,
                    "hiddenFileSizeNew": "",
                    "attachmentsValue": "\r\n\r\nAttachments:\r\n",
                    "configurationFileCheck": "",
                    "configurationFileFinal": "",
                ]

                let body = try! JSONSerialization.data(withJSONObject: JSON, options: [])
                let headers = [
                    "Referer": AppleRadarRouter.viewProblem.url.absoluteString,
                    "Radar-Authentication": token,
                ]
                return (path: "/developerUI/problem/createNewDevUIProblem", method: .post, headers: headers,
                        data: body, parameters: [:])

            case .uploadAttachment(let radarID, let attachment, let token):
                let escapedName = attachment.filename
                    .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? attachment.filename

                let headers = [
                    "Referer": AppleRadarRouter.viewProblem.url.absoluteString,
                    "Radar-Authentication": token,
                ]

                return (path: "/developerUI/problems/\(radarID)/attachments/\(escapedName)", method: .put,
                        headers: headers, data: nil, parameters: [:])
        }
    }
}

extension AppleRadarRouter: URLRequestConvertible {
    /// The URL that will be used for the request.
    var url: URL {
        return self.urlRequest!.url!
    }

    /// The request representation of the route including parameters and HTTP method.
    func asURLRequest() -> URLRequest {
        let (path, method, headers, data, parameters) = self.components
        let fullURL: URL
        if let url = URL(string: path), url.host != nil {
            fullURL = url
        } else {
            fullURL = AppleRadarRouter.baseURL.appendingPathComponent(path)
        }

        var request = URLRequest(url: fullURL)
        request.httpMethod = method.rawValue
        request.httpBody = data

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if data == nil {
            return try! URLEncoding().encode(request, with: parameters)
        }

        return request
    }
}
