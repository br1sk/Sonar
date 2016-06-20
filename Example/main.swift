import Sonar
import Foundation

let env = NSProcessInfo.processInfo().environment
let openRadar = Sonar(service: .OpenRadar(token: env["SONAR_OPENRADAR_TOKEN"]!))
let appleRadar = Sonar(service: .AppleRadar(appleID: env["SONAR_APPLEID"]!, password: env["SONAR_PASSWORD"]!))

func main() {
    let radar = Radar(
        classification: .Feature, product: .BugReporter, reproducibility: .Always,
        title: "Add REST API to Radar", description: "Add REST API to Radar", steps: "N/A",
        expected: "Radar to have a REST API available", actual: "HTML", configuration: "N/A",
        version: "Any", notes: "N/A", ID: 1337
    )

    appleRadar.loginThenCreate(radar: radar) { result in
        print(result.value)
    }

    openRadar.loginThenCreate(radar: radar) { result in
        guard case let .Success(products) = result else {
            print("Error!", result.error)
            return
        }

        print(result.value)
    }
}

main()
dispatch_main()
