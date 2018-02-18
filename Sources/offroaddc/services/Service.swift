import Foundation

class Service {
    
    var note       : String?
    var name       : String?
    var service_id : Int?
    var servers    : [ServiceServer]?
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.note.isNotNil {
            dictionary.service.note = self.note
        }
        if self.name.isNotNil {
            dictionary.service.name = self.name
        }
        if self.service_id.isNotNil {
            dictionary.service.service_id = self.service_id
        }
        if self.servers.isNotNil {
            dictionary.service.servers = self.servers
        }

        return dictionary
    }

}

