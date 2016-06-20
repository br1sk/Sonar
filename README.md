# Sonar

An interface to create radars on [Apple's bug tracker](https://radar.apple.com)
and [Open Radar](https://openradar.appspot.com/) frictionless from swift.

## Example

### Login

```swift
let openRadar = Sonar(service: .OpenRadar(token: "abcdefg"))
openRadar.login { result in
    guard case let .Success = result else {
        return
    }

    print("Logged in!")
}
```

### Create radar

```swift
let radar = Radar(
    classification: .Feature, product: .BugReporter, reproducibility: .Always,
    title: "Add REST API to Radar", description: "Add REST API to Radar", steps: "N/A",
    expected: "Radar to have a REST API available", actual: "HTML", configuration: "N/A",
    version: "Any", notes: "N/A"
)

let openRadar = Sonar(service: .OpenRadar(token: "abcdefg"))
openRadar.create(radar: radar) { result in
    print(result.value) // This is the radar ID!
}
```

### Login and create radar on the same request

```swift
let radar = Radar(
    classification: .Feature, product: .BugReporter, reproducibility: .Always,
    title: "Add REST API to Radar", description: "Add REST API to Radar", steps: "N/A",
    expected: "Radar to have a REST API available", actual: "HTML", configuration: "N/A",
    version: "Any", notes: "N/A"
)

let appleRadar = Sonar(service: .AppleRadar(appleID: "a", password: "b"))
appleRadar.loginThenCreate(radar: radar) { result in
    print(result.value) // This is the radar ID!
}
```
