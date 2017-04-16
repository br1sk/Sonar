# Sonar

An interface to create radars on [Apple's bug tracker](https://radar.apple.com)
and [Open Radar](https://openradar.appspot.com/) frictionless from swift.

## Example

### Login

```swift
let openRadar = Sonar(service: .openRadar(token: "abcdefg"))
openRadar.login(
    getTwoFactorCode: { _ in fatalError("OpenRadar doesn't support 2 factor" })
{ result in
    guard case let .success = result else {
        return
    }

    print("Logged in!")
}
```

### Create radar

```swift
let radar = Radar(
    classification: .feature, product: .bugReporter, reproducibility: .always,
    title: "Add REST API to Radar", description: "Add REST API to Radar", steps: "N/A",
    expected: "Radar to have a REST API available", actual: "API not provided",
    configuration: "N/A", version: "Any", notes: "N/A", attachments: []
)

let openRadar = Sonar(service: .openRadar(token: "abcdefg"))
openRadar.create(radar: radar) { result in
    // Check to see if the request succeeded
}
```

### Login and Create radar on the same call

```swift
let radar = Radar(
    classification: .feature, product: .bugReporter, reproducibility: .always,
    title: "Add REST API to Radar", description: "Add REST API to Radar", steps: "N/A",
    expected: "Radar to have a REST API available", actual: "API not provided",
    configuration: "N/A", version: "Any", notes: "N/A", attachments: []
)

let appleRadar = Sonar(service: .appleRadar(appleID: "a", password: "b"))
appleRadar.loginThenCreate(
    radar: radar,
    getTwoFactorCode: { closure in
        let code = // Somehow get 2 factor auth code for user
        closure(code)
    })
{ result in
    switch result {
    case .success(let value):
        print(value) // This is the radar ID!
    case .failure(let error):
        print(error)
    }
}
```
