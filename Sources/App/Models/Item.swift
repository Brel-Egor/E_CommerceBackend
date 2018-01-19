import PostgreSQLProvider

final class Item: Model {
    let storage = Storage()
    let itemName: String
    let price: Double
    let description: String
    let pictUrl: String
   
    
    init(itemName: String, price: Double, description: String, pictUrl: String) {
        self.itemName = itemName
        self.price = price
        self.description = description
        self.pictUrl = pictUrl
    }
    
    init(row: Row) throws {
        self.itemName = try row.get("itemName")
        self.price = try row.get("price")
        self.description = try row.get("description")
        self.pictUrl = try row.get("pictUrl")
    }
    
}

extension Item: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("itemName", itemName)
        try row.set("price", price)
        try row.set("description", description)
        try row.set("pictUrl", pictUrl)
        return row
    }
}

extension Item: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (item) in
            item.id()
            item.string("itemName")
            item.double("price")
            item.string("description")
            item.string("pictUrl")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Item: JSONRepresentable {
    func makeJSON() throws -> JSON {
        let json = try JSON(node:[
            "id": id,
            "name": itemName,
            "price": price,
            "description": description,
            "pictUrl": pictUrl,
            ])
        return json
    }
}

