//
//  BadgeExtensions.swift
//
//  Created by Mike Silvers on 01/21/18.
//

extension Dictionary where Key == String, Value == Any {
    var class_status : ClassStatusDictionary {
        get {
            var bc = ClassStatusDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct ClassStatusDictionary {
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

    var status : String? {
        get {
            return self.dic["status"] as? String
        }
        set {
            if newValue != nil {
                self.dic["status"] = newValue!
            } else {
                self.dic.removeValue(forKey: "status")
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

