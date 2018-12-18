//
//  BadgeUserExtensions.swift
//

extension Dictionary where Key == String, Value == Any {
    var notifications : NotificationsDictionary {
        get {
            var bc = NotificationsDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: BadgeUser-Key Dictionary Variable Values
struct NotificationsDictionary {
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
}
