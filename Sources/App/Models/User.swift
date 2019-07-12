import Authentication
import FluentMySQL
import Vapor

final class User: Codable {
    var id: UUID?
    var name: String
    var userName: String
    var password: String
    
    init(name: String, userName: String, password: String) {
        self.name = name
        self.userName = userName
        self.password = password
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var userName: String
        
        init(id: UUID?, name: String, userName: String) {
            self.id = id
            self.name = name
            self.userName = userName
        }
    }
}

extension User: MySQLUUIDModel { }
extension User: Content { }
extension User: Migration { }
extension User: Parameter { }

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.userName
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
    
    func convertToPublic() -> User.Public {
        return User.Public(id: self.id, name: self.name, userName: self.userName)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

extension User.Public: Content {  }
