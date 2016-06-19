import PackageDescription

let package = Package(
    name: "Sonar",

    dependencies: [
       .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 3),
    ]
)
