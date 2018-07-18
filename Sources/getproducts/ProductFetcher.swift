@testable import Sonar
import Foundation

final class ProductFetcher {
    private let radar: AppleRadar

    init(username: String, password: String) {
        self.radar = AppleRadar(appleID: username, password: password)
    }

    func fetchAndOutputProducts(closure: @escaping (Result<String, SonarError>) -> Void) {
        self.radar.login(getTwoFactorCode: { closure in
            let code = try? getInput("Two factor auth code:")
            closure(code)
        }, closure: { result in
            switch result {
            case .success:
                self.fetchProducts(closure: closure)
            case .failure(let error):
                closure(.failure(error))
            }
        })
    }

    private func fetchProducts(closure: @escaping (Result<String, SonarError>) -> Void) {
        self.radar.getProductsAndAreas { result in
            switch result {
            case .success(let products):
                closure(.success(format(products)))
            case .failure(let error):
                closure(.failure(error))
            }

            self.hold()
        }
    }

    private func hold() {}
}
