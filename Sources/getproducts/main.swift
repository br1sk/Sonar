import Foundation

let arguments = CommandLine.arguments.dropFirst()
guard let path = arguments.first else {
    print("Usage: getproducts OUTPUTPATH")
    exit(1)
}

let env = ProcessInfo.processInfo.environment
let productFetcher: ProductFetcher

do {
    let username = try env["RADAR_USERNAME"] ?? getInput("Radar Username:")
    let password = try env["RADAR_PASSWORD"] ?? getInput("Radar Password:", secure: true)
    productFetcher = ProductFetcher(username: username, password: password)
} catch InputError.quit {
    exit(0)
} catch let error as NSError {
    print(error.localizedDescription)
    exit(1)
}

productFetcher.fetchAndOutputProducts { result in
    switch result {
    case .success(let output):
        do {
            try output.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
            exit(0)
        } catch let error as NSError {
            print(error.localizedDescription)
            exit(1)
        }
    case .failure(let error):
        print(error.message)
        exit(1)
    }
}

dispatchMain()
