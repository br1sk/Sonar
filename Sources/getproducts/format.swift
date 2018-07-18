import Sonar

/// Format an array of products into swift source
///
/// - parameter products: The array of products to format
///
/// - returns: A swift source string
func format(_ products: [Product]) -> String {
    var output = ""
    print("extension Product {", to: &output)

    var allIdentifiers: Set<String> = []
    for product in products {
        let identifier = product.name.stripInvalidIdentifierChars().lowercaseFirstLetter()
        allIdentifiers.insert(identifier)
        print(format(product, identifier, baseIndent: 4), to: &output)
    }

    print(format(allIdentifiers: allIdentifiers, baseIndent: 4), to: &output)
    print("}", to: &output)

    return output
}

private func format(_ product: Product, _ identifier: String, baseIndent: Int) -> String {
    let productIndent = String(repeating: " ", count: baseIndent)
    let areaIndent = String(repeating: " ", count: baseIndent * 2)
    var output = ""

    let hasAreas = !product.areas.isEmpty
    if hasAreas {
        print("""
            \(productIndent)public static let \(identifier) = \
            Product(\(product.appleIdentifier), "\(product.name)", "\(product.category)", [
            """, to: &output)

        for area in product.areas {
            print("\(areaIndent)Area(\(area.appleIdentifier), \"\(area.name)\"),", to: &output)
        }

        print("\(productIndent)])", to: &output)
    } else {
        print("""
            \(productIndent)public static let \(identifier) = \
            Product(\(product.appleIdentifier), "\(product.name)", "\(product.category)", [])
            """, terminator: "", to: &output)
    }

    return output
}

private func format(allIdentifiers: Set<String>, baseIndent: Int) -> String {
    let definitionIndent = String(repeating: " ", count: baseIndent)
    let entryIndent = String(repeating: " ", count: baseIndent * 2)
    var output = ""

    print("\(definitionIndent)public static let all: [Product] = [", to: &output)
    for identifier in allIdentifiers {
        print("\(entryIndent).\(identifier),", to: &output)
    }

    print("\(definitionIndent)]", terminator: "", to: &output)
    return output
}
