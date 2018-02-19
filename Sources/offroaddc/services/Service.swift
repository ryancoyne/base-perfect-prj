import Foundation

class Service {
    
    var note       : String?
    var name       : String?
    var service_id : Int?
    var servers    : [ServiceServer]?
    
    init?(json: [String: Any]) {
        guard let _name = json["name"].stringValue,
            let _note = json["note"].stringValue,
            let _service_id = json["service_id"].intValue,
        let _theservers = json["servers"] as? [String:Any]
            else {
                return nil
        }
        
        self.note = _note
        self.name = _name
        self.service_id = _service_id
        
        for (_, value) in _theservers {
            if let _value = value as? [String:Any] {
                if let tmpsrv = ServiceServer(json: _value) {
                    if self.servers.isNil {
                        self.servers = []
                    }
                    self.servers?.append(tmpsrv)
                }
            }

        }
    }
    
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

