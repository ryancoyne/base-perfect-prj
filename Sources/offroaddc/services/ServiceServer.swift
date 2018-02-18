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
    var server_url          : String?
    var location_service_id : Int?

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

        return dictionary
    }

}

