import Sonar
import Foundation

let sonar = Sonar()

func main() {
    let env = NSProcessInfo.processInfo().environment
    guard let appleID = env["SONAR_APPLE_ID"], password = env["SONAR_PASSWORD"] else {
        print("Invalid SONAR_APPLE_ID and SONAR_PASSWORD environment variables")
        return
    }

    sonar.login(withAppleID: appleID, password: password) { result in
        guard case let .Success(products) = result else {
            print("Error!", result.error)
            return
        }

        let radar = Radar(
            classification: .Feature, product: products[2], reproducibility: .Always,
            title: "Add REST API to Radar", description: "Add REST API to Radar", steps: "N/A",
            expected: "Radar to have a REST API available", actual: "HTML", configuration: "N/A",
            version: "Any", notes: "N/A"
        )

        sonar.create(radar: radar) { result in
            print(result.value)
        }
    }
}

main()
dispatch_main()
