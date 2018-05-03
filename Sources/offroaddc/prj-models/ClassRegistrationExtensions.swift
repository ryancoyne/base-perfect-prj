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

    var user_id : String? {
        get {
            return self.dic["user_id"] as? String
        }
        set {
            if newValue != nil {
                self.dic["user_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "user_id")
            }
        }
    }

    var class_date_id : Int? {
        get {
            return self.dic["class_date_id"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["class_date_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "class_date_id")
            }
        }
    }
    
    var registered : Int? {
        get {
            return self.dic["registered"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["registered"] = newValue!
            } else {
                self.dic.removeValue(forKey: "registered")
            }
        }
    }
    
    var registered_by : String? {
        get {
            return self.dic["registered_by"] as? String
        }
        set {
            if newValue != nil {
                self.dic["registered_by"] = newValue!
            } else {
                self.dic.removeValue(forKey: "registered_by")
            }
        }
    }
    
    var wait_list_order : Int? {
        get {
            return self.dic["wait_list_order"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["wait_list_order"] = newValue!
            } else {
                self.dic.removeValue(forKey: "wait_list_order")
            }
        }
    }
}

