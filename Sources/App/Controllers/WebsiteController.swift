import Vapor

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        // GET
        router.get(use: indexHandler)
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
        router.get("user", User.parameter, use: userHandler)
        router.get("allUsers", use: allUsersHandler)
        router.get("allCategories", use: allCategoriesHandler)
        router.get("category", Category.parameter, use: categoryHandler)
        router.get("acronyms", "create", use: createAcronymHandler)
        router.get("acronyms", Acronym.parameter, "edit", use: editAcronymHandler)
        
        // POST
        router.post(Acronym.self, at: "acronyms", "create", use: createAcronymPostHandler)
        router.post("acronyms", Acronym.parameter, "edit", use: editAcronymPostHandler)
        router.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler )
    }
    
    // GET 
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            let context = IndexContext(title: "Homepage", acronyms: acronyms)
            return try req.view().render("index", context)
        }
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            return acronym.user.get(on: req).flatMap(to: View.self) { user in
                let  context = AcronymContext(title: acronym.longVersion, acronym: acronym, user: user)
                return try req.view().render("acronym", context)
            }
        }
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            let context = try UserContext(title: user.userName, user: user, acronyms: user.acronyms.query(on: req).all())
            return try req.view().render("user", context)
        }
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self).flatMap(to: View.self) { category in
            let context = try CategoryContext(title: category.name, category: category, acronyms: category.acronyms.query(on: req).all())
            return try req.view().render("category", context)
        }
    }

    func allUsersHandler(_ req: Request) throws -> Future<View> {
        let context = AllUsersContext(users: User.query(on: req).all())
        return try req.view().render("allUsers", context)
    }
    
    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        let context = AllCategoriesContext(categories: Category.query(on: req).all())
        return try req.view().render("allCategories", context)
    }
    
    func createAcronymHandler(_ req: Request) throws -> Future<View> {
        let context = CreateAcronymContext(users: User.query(on: req).all())
        return try req.view().render("createAcronym", context)
    }
    
    
    func editAcronymHandler(_ req: Request) throws -> Future<View> {
        return try flatMap(to: View.self, req.parameters.next(Acronym.self), User.query(on: req).all()) { acronym, users in
            let context = EditAcronymContext(title: acronym.shortVersion, acronym: acronym, users: users)
            return try req.view().render("createAcronym", context)
        }
    }
    
    // POST
    func createAcronymPostHandler(_ req: Request, acronym: Acronym) throws -> Future<Response> {
        return acronym.save(on: req).map(to: Response.self) { acronym in
            guard let id = acronym.id else {
                return req.redirect(to: "/")
            }
            return req.redirect(to: "/acronyms/\(id)")
        }
    }

    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Acronym.self).flatMap(to: Response.self) { acronym in
            let updatedAcronym = try req.content.syncDecode(Acronym.self)
            acronym.shortVersion = updatedAcronym.shortVersion
            acronym.longVersion = updatedAcronym.longVersion
            acronym.userID = updatedAcronym.userID
            
            return acronym.save(on: req).map(to: Response.self) { savedAcronym in
                guard let id = savedAcronym.id else {
                    return req.redirect(to: "/")
                }
                return req.redirect(to: "/acronyms/\(id)")
            }
        }
    }
    
    func deleteAcronymHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Acronym.self).flatMap(to: Response.self) { acronym in
            return acronym.delete(on: req).transform(to: req.redirect(to: "/"))
        }
    }
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: Future<[Acronym]>
}

struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let acronyms: Future<[Acronym]>
}

struct AllUsersContext: Encodable {
    let title =  "All Users"
    let users: Future<[User]>
}

struct AllCategoriesContext: Encodable {
    let title = "All Categories"
    let categories: Future<[Category]>
}

struct CreateAcronymContext: Encodable {
    let title = "Create Acronym"
    let users: Future<[User]>
}

struct EditAcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let users: [User]
    let editing = true
}
