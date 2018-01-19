import Vapor
import Foundation
extension Droplet {
    func setupRoutes() throws {

        get("Items") { req in
            let items = try Item.all()
            return try JSON(node: ["items":try items.makeJSON()])
        }
        
        get("Requests") { req in
            let requests = try ItemRequest.all()
            return try JSON(node: ["requests":try requests.makeJSON()])
        }
        
        get("Form_request") { req in
            return try self.view.make("Form_request.html")
        }
        
        get("Form_upload") { req in
            return try self.view.make("Form_upload.html")
        }
        
        get("Form_delete") { req in
            return try self.view.make("Form_delete.html")
        }
        
        post("delete") { req in
            print((req.data["id"]?.string)!)
            guard let itemID = Int((req.data["id"]?.string)!) else {return "failure"}
            guard let item = try Item.find(itemID) else {
                return "failure"
            }
            let imageName = item.pictUrl
            let workPath = self.config.workDir
            let imageFolder = "Public/images"
            let deleteURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(imageName, isDirectory: false)
            let fileManager = FileManager.default
            do{
                try fileManager.removeItem(at: deleteURL)
            } catch let error as NSError{
                print(error.debugDescription)
                return "failure"
            }
            try item.delete()
            return try JSON(node: ["type": "success", "message": "user with id \(itemID) were successfully deleted"])
        }
        
        post("request") { req in
            guard let contactData = req.data["contactData"]?.string else {return "failure"}
            guard let description = req.data["description"]?.string else {return "failure"}
            try ItemRequest(contactData: contactData, description: description).save()
            return "Success"
        }
        
        post("upload") { req in
            guard let itemName = req.data["name"]?.string else {return "failure"}
            guard let price = Double((req.data["price"]?.string)!) else {return "failure"}
            guard let description = req.data["description"]?.string else {return "failure"}
           
            print(req.data)
            guard let fileData = req.formData?["image"]?.part.body else {
                return "failure"
            }
            
            let workPath = self.config.workDir
            let imageName = UUID().uuidString + ".png"
            let imageFolder = "Public/images"
            let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(imageName, isDirectory: false)
            
            do {
                let data = Data(bytes: fileData)
                try data.write(to: saveURL)
            } catch {
                return "failure"
            }
            
            try Item(itemName: itemName, price: price, description: description, pictUrl: imageName).save()
            return "\(workPath)\(imageFolder)\(imageName)"
        }
        
    }
}
