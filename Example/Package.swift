import PackageDescription

let package = Package(
    name: "Sonar-Example",

    dependencies: [
       .Package(url: "../", majorVersion: 0),
    ]
)
