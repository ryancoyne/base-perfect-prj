//
//  BadgeExtensions.swift
//
//  Created by Mike Silvers on 01/21/18.
//

extension Dictionary where Key == String, Value == Any {
    var class_main : ClassMainDictionary {
        get {
            var bc = ClassMainDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct ClassMainDictionary {
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

    var class_type_id : Int? {
        get {
            return self.dic["class_type_id"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["class_type_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "class_type_id")
            }
        }
    }
    
    var studio_id : Int? {
        get {
            return self.dic["studio_id"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["studio_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "studio_id")
            }
        }
    }
    
    var description : String? {
        get {
            return self.dic["description"] as? String
        }
        set {
            if newValue != nil {
                self.dic["description"] = newValue!
            } else {
                self.dic.removeValue(forKey: "description")
            }
        }
    }
}

