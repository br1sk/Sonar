// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Sonar",
    products: [
        .executable(name: "getproducts", targets: ["getproducts"]),
        .library(name: "Sonar", targets: ["Sonar"]),
    ],
    dependencies: [
       .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMinor(from: "4.7.2"))
    ],
    targets: [
        .target(name: "Sonar", dependencies: ["Alamofire"]),
        .target(name: "getproducts", dependencies: ["Sonar"]),
    ]
)
