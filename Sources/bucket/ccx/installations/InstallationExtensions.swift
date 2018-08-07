//////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//
//////////////////////////////////////////////////////////////////////////////////


extension Dictionary where Key == String, Value == Any {
    var installations : InstallationsDictionary {
        get {
            var bc = InstallationsDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Installation-Key Dictionary Variable Values
struct InstallationsDictionary {
    fileprivate var dic : [String:Any]!
    /// This variable key is "abbreviation". Set nil to remove from the dictionary.
    var devicetoken : String? {
        get {
            return self.dic["devicetoken"] as? String
        }
        set {
            if newValue != nil {
                self.dic["devicetoken"] = newValue!
            } else {
                self.dic.removeValue(forKey: "devicetoken")
            }
        }
    }
    var timezone : String? {
        get {
            return self.dic["timezone"] as? String
        }
        set {
            if newValue != nil {
                self.dic["timezone"] = newValue!
            } else {
                self.dic.removeValue(forKey: "timezone")
            }
        }
    }
    var id : Int? {
        get {
            return self.dic["id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["id"] = newValue.intValue
            } else {
                self.dic.removeValue(forKey: "id")
            }
        }
    }
    var devicetype : String? {
        get {
            return self.dic["devicetype"] as? String
        }
        set {
            if newValue != nil {
                self.dic["devicetype"] = newValue!
            } else {
                self.dic.removeValue(forKey: "devicetype")
            }
        }
    }
    /// This variable key is "statename". Set nil to remove from the dictionary.
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
    var systemname : String? {
        get {
            return self.dic["systemname"] as? String
        }
        set {
            if newValue != nil {
                self.dic["systemname"] = newValue!
            } else {
                self.dic.removeValue(forKey: "systemname")
            }
        }
    }
    var systemversion : String? {
        get {
            return self.dic["systemversion"] as? String
        }
        set {
            if newValue != nil {
                self.dic["systemversion"] = newValue!
            } else {
                self.dic.removeValue(forKey: "systemversion")
            }
        }
    }
    var model : String? {
        get {
            return self.dic["model"] as? String
        }
        set {
            if newValue != nil {
                self.dic["model"] = newValue!
            } else {
                self.dic.removeValue(forKey: "model")
            }
        }
    }
    var localizedmodel : String? {
        get {
            return self.dic["localizedmodel"] as? String
        }
        set {
            if newValue != nil {
                self.dic["localizedmodel"] = newValue!
            } else {
                self.dic.removeValue(forKey: "localizedmodel")
            }
        }
    }
    var identifierforvendor : String? {
        get {
            return self.dic["identifierforvendor"] as? String
        }
        set {
            if newValue != nil {
                self.dic["identifierforvendor"] = newValue!
            } else {
                self.dic.removeValue(forKey: "identifierforvendor")
            }
        }
    }
    var acceptedterms : Int? {
        get {
            return self.dic["acceptedterms"].intValue
        }
        set {
            if newValue != nil {
                self.dic["acceptedterms"] = newValue.intValue
            } else {
                self.dic.removeValue(forKey: "acceptedterms")
            }
        }
    }
    var declinedterms : Int? {
        get {
            return self.dic["declinedterms"].intValue
        }
        set {
            if newValue != nil {
                self.dic["declinedterms"] = newValue.intValue
            } else {
                self.dic.removeValue(forKey: "declinedterms")
            }
        }
    }
}
