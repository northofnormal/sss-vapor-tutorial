import Authentication
import Crypto
import FluentMySQL
import Foundation
import Vapor

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    
    static func generateToken(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension Token: MySQLUUIDModel { }
extension Token: Content { }
extension Token: Migration { }

extension Token: Authentication.Token {
    typealias UserType = User
    static let userIDKey: UserIDKey = \Token.userID
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}

extension Token {
    var user: Parent<Token, User> {
        return parent(\.userID)
    }
}

