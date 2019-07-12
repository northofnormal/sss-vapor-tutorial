import Vapor

struct CategoryController: RouteCollection {
    
    func boot(router: Router) throws {
        let categoryRoute = router.grouped("api", "category")
        // GET
        categoryRoute.get(use: getAllHandler)
        categoryRoute.get(Category.parameter, use: getHandler)
        categoryRoute.get(Category.parameter, "acronyms", use: getAcronymsHandler)
        
        // POST
        categoryRoute.post(Category.self, use: createHandler)
        
        // Put
        categoryRoute.put(Category.parameter, use: updateHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
    
    func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
        return category.save(on: req)
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Category.self).flatMap(to: [Acronym].self) { category in
            return try category.acronyms.query(on: req).all()
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Category> {
        return try flatMap(to: Category.self, req.parameters.next(Category.self), req.content.decode(Category.self)) { category, updatedCategory in
            category.name = updatedCategory.name
            return category.save(on: req)
        }
    }
    
}
