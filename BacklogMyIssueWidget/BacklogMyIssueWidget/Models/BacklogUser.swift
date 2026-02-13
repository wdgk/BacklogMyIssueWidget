import Foundation

struct BacklogUser: Codable, Identifiable {
    let id: Int
    let name: String
    let userId: String?
}
