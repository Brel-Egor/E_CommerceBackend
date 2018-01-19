import PostgreSQLProvider

final class ItemRequest: Model {
    let storage = Storage()
    let contactData: String
    let description: String
    
    
    init(contactData: String, description: String) {
        self.contactData = contactData
        self.description = description
    }
    
    init(row: Row) throws {
        self.contactData = try row.get("contactData")
        self.description = try row.get("description")
    }
    
}

extension ItemRequest: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("contactData", contactData)
        try row.set("description", description)
        return row
    }
}

extension ItemRequest: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (item) in
            item.id()
            item.string("contactData")
            item.string("description")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension ItemRequest: JSONRepresentable {
    func makeJSON() throws -> JSON {
        let json = try JSON(node:[
            "id": id,
            "contactData": contactData,
            "description": description,
            ])
        return json
    }
}


