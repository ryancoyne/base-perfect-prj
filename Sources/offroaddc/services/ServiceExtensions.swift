//////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
//////////////////////////////////////////////////////////////////////////////////


extension Dictionary where Key == String, Value == Any {
    var service : ServiceDictionary {
        get {
            var bc = ServiceDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Service-Key Dictionary Variable Values
struct ServiceDictionary {
    fileprivate var dic : [String:Any]!
    var name : String? {
        get {
            return self.dic["name"] as? String
        }
        set {
            if newValue != nil {
                self.dic["name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "name")
            }
        }
    }
    var note : String? {
        get {
            return self.dic["note"] as? String
        }
        set {
            if newValue != nil {
                self.dic["note"] = newValue!
            } else {
                self.dic.removeValue(forKey: "note")
            }
        }
    }
    var server_url : String? {
        get {
            return self.dic["url"] as? String
        }
        set {
            if newValue != nil {
                self.dic["url"] = newValue!
            } else {
                self.dic.removeValue(forKey: "url")
            }
        }
    }
    var username : String? {
        get {
            return self.dic["username"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["username"] = newValue.stringValue
            } else {
                self.dic.removeValue(forKey: "username")
            }
        }
    }
    var password : String? {
        get {
            return self.dic["password"] as? String
        }
        set {
            if newValue != nil {
                self.dic["password"] = newValue!
            } else {
                self.dic.removeValue(forKey: "password")
            }
        }
    }
    var location_service_id : Int? {
        get {
            return self.dic["location_service_id"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["location_service_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "location_service_id")
            }
        }
    }
}
