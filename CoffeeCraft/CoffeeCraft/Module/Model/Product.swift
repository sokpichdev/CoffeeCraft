import Foundation

struct Product: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var imageURL: String
    var customizations: [String: [String]]? // e.g. ["Size": ["Small", "Medium", "Large"]]
}
