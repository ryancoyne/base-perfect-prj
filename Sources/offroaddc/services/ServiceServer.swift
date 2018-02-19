import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession

class ServiceServer {
    
    var note                : String?
    var name                : String?
    var username            : String?
    var password            : String?
    var server_id           : Int?
    var server_url          : String?
    var location_service_id : String?

    init?(json: [String: Any]) {
        guard let _name = json["name"].stringValue,
            let _note = json["note"].stringValue,
            let _server_id = json["server_id"].intValue,
            let _location_service_id = json["location_service_id"].stringValue,
            let _server_url = json["url"].stringValue,
            let _username = json["username"].stringValue,
            let _password = json["password"].stringValue
            else {
                return nil
        }
        
        self.note                = _note
        self.name                = _name
        self.username            = _username
        self.password            = _password
        self.server_id           = _server_id
        self.server_url          = _server_url
        self.location_service_id = _location_service_id
    }

    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.note.isNotNil {
            dictionary.server.note = self.note
        }
        if self.name.isNotNil {
            dictionary.server.name = self.name
        }
        if self.username.isNotNil {
            dictionary.server.username = self.username
        }
        if self.password.isNotNil {
            dictionary.server.password = self.password
        }
        if self.server_url.isNotNil {
            dictionary.server.server_url = self.server_url
        }
        if self.location_service_id.isNotNil {
            dictionary.server.location_service_id = self.location_service_id
        }
        if self.server_id.isNotNil {
            dictionary.server.server_id = self.server_id
        }

        return dictionary
    }

}

