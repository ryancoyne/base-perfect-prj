//
//  BadgeExtensions.swift
//
//  Created by Mike Silvers on 01/21/18.
//

extension Dictionary where Key == String, Value == Any {
    var class_registration : ClassRegistrationDictionary {
        get {
            var bc = ClassRegistrationDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct ClassRegistrationDictionary {
    fileprivate var dic : [String:Any]!
    /// This variable key is "id". Set nil to remove from the dictionary.
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

    var source : String? {
        get {
            return self.dic["source"] as? String
        }
        set {
            if newValue != nil {
                self.dic["source"] = newValue!.lowercased()
            } else {
                self.dic.removeValue(forKey: "source")
            }
        }
    }

    var account_id : String? {
        get {
            return self.dic["account_id"] as? String
        }
        set {
            if newValue != nil {
                self.dic["account_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "account_id")
            }
        }
    }
    
    var source_id : String? {
        get {
            return self.dic["source_id"] as? String
        }
        set {
            if newValue != nil {
                self.dic["source_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "source_id")
            }
        }
    }
    
    var source_location_id : String? {
        get {
            return self.dic["source_location_id"] as? String
        }
        set {
            if newValue != nil {
                self.dic["source_location_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "source_location_id")
            }
        }
    }
    
    var name_first : String? {
        get {
            return self.dic["name_first"] as? String
        }
        set {
            if newValue != nil {
                self.dic["name_first"] = newValue!
            } else {
                self.dic.removeValue(forKey: "name_first")
            }
        }
    }
    
    var name_last : String? {
        get {
            return self.dic["name_last"] as? String
        }
        set {
            if newValue != nil {
                self.dic["name_last"] = newValue!
            } else {
                self.dic.removeValue(forKey: "name_last")
            }
        }
    }
    
    var name_full : String? {
        get {
            return self.dic["name_full"] as? String
        }
        set {
            if newValue != nil {
                self.dic["name_full"] = newValue!
            } else {
                self.dic.removeValue(forKey: "name_full")
            }
        }
    }
    
    var nickname : String? {
        get {
            return self.dic["nickname"] as? String
        }
        set {
            if newValue != nil {
                self.dic["nickname"] = newValue!
            } else {
                self.dic.removeValue(forKey: "nickname")
            }
        }
    }

    var email : String? {
        get {
            return self.dic["email"] as? String
        }
        set {
            if newValue != nil {
                self.dic["email"] = newValue!.lowercased()
            } else {
                self.dic.removeValue(forKey: "email")
            }
        }
    }

    var weight    : Float?    {
        get {
            return self.dic["weight"] as? Float
        }
        set {
            if newValue != nil {
                self.dic["weight"] = newValue!
            } else {
                self.dic.removeValue(forKey: "weight")
            }
        }
    }

    var gender : String? {
        get {
            return self.dic["gender"] as? String
        }
        set {
            if newValue != nil {
                self.dic["gender"] = newValue!.lowercased()
            } else {
                self.dic.removeValue(forKey: "gender")
            }
        }
    }
    
    var phone    : String?    {
        get {
            return self.dic["phone"] as? String
        }
        set {
            if newValue != nil {
                self.dic["phone"] = newValue!
            } else {
                self.dic.removeValue(forKey: "phone")
            }
        }
    }

    var status    : String?    {
        get {
            return self.dic["status"] as? String
        }
        set {
            if newValue != nil {
                self.dic["status"] = newValue!.lowercased()
            } else {
                self.dic.removeValue(forKey: "status")
            }
        }
    }

}

