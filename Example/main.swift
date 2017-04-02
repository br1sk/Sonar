import Foundation
import Sonar

func main() {
    let env = ProcessInfo().environment
    let openRadar = Sonar(service: .OpenRadar(token: env["SONAR_OPENRADAR_TOKEN"]!))
    let appleRadar = Sonar(service: .AppleRadar(appleID: env["SONAR_APPLEID"]!,
                                                password: env["SONAR_PASSWORD"]!))
    let radar = Radar(
        classification: .Feature, product: .BugReporter, reproducibility: .Always,
        title: "Add REST API to Radar", description: "Add REST API to Radar", steps: "N/A",
        expected: "Radar to have a REST API available", actual: "HTML", configuration: "N/A",
        version: "Any", notes: "N/A", attachments: [], ID: 1337
    )

    appleRadar.loginThenCreate(
        radar: radar,
        getTwoFactorCode: { closure in
            print("Enter your 2 factor auth code:")
            closure(readLine())
        })
    { result in
        switch result {
        case .success(let value):
            print(value)
        case .failure(let error):
            print(error)
        }
    }

    openRadar.loginThenCreate(
        radar: radar,
        getTwoFactorCode: { closure in
            assertionFailure("Not handling open radar 2 factor auth")
            closure(nil)
        })
    { result in
        switch result {
        case .success(let value):
            print(value)
        case .failure(let error):
            print(error)
        }
    }
}

main()
dispatchMain()
