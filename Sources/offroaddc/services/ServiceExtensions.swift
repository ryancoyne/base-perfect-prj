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
    var service_id : Int? {
        get {
            return self.dic["service_id"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["service_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "service_id")
            }
        }
    }
    var servers : [ServiceServer]? {
        get {
            return self.dic["servers"] as? [ServiceServer]
        }
        set {
            if newValue != nil {
                self.dic["servers"] = newValue!
            } else {
                self.dic.removeValue(forKey: "servers")
            }
        }
    }
}
