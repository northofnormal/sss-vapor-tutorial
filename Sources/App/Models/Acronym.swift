import FluentMySQL
import Vapor

final class Acronym: Codable {
    var id: Int?
    var shortVersion: String
    var longVersion: String
    var userID: User.ID
    
    init(shortVersion: String, longVersion: String, userID: User.ID) {
        self.shortVersion = shortVersion
        self.longVersion = longVersion
        self.userID = userID
    }
}

extension Acronym: MySQLModel { }
extension Acronym: Content { }
extension Acronym: Migration { }
extension Acronym: Parameter { }

extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
    
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}
