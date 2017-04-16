import Alamofire
import Foundation

/// Open radar request router.
///
/// - create: The `Route` used to create a new radar.
enum OpenRadarRouter {
    case create(radar: Radar)

    fileprivate static let baseURL = URL(string: "https://openradar.appspot.com")!

    /// The request components including headers and parameters.
    var components: (path: String, method: Alamofire.HTTPMethod, parameters: [String: String]) {
        switch self {
            case .create(let radar):
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MMM-yyyy hh:mm a"

                return (path: "/api/radars/add", method: .post, parameters: [
                    "classification": radar.classification.name,
                    "description": radar.body,
                    "number": radar.ID.map { String($0) } ?? "",
                    "originated": formatter.string(from: Date()),
                    "product": radar.product.name,
                    "product_version": radar.version,
                    "reproducible": radar.reproducibility.name,
                    "status": "Open",
                    "title": radar.title,
                ])
        }
    }
}

extension OpenRadarRouter: URLRequestConvertible {
    /// The URL that will be used for the request.
    var url: URL {
        return self.urlRequest!.url!
    }

    /// The request representation of the route including parameters and HTTP method.
    func asURLRequest() -> URLRequest {
        let (path, method, parameters) = self.components
        let url = OpenRadarRouter.baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return try! URLEncoding().encode(request, with: parameters)
    }
}

