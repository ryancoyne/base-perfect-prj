//
//  BadgeExtensions.swift
//
//  Created by Mike Silvers on 01/21/18.
//

extension Dictionary where Key == String, Value == Any {
    var class_date : ClassDateDictionary {
        get {
            var bc = ClassDateDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct ClassDateDictionary {
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

    var start_time : Int? {
        get {
            return self.dic["start_time"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["start_time"] = newValue!
            } else {
                self.dic.removeValue(forKey: "start_time")
            }
        }
    }

    var end_time : Int? {
        get {
            return self.dic["end_time"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["end_time"] = newValue!
            } else {
                self.dic.removeValue(forKey: "end_time")
            }
        }
    }

    var class_id : Int? {
        get {
            return self.dic["class_id"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["class_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "class_id")
            }
        }
    }

    var class_status_id : Int? {
        get {
            return self.dic["class_status_id"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["class_status_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "class_status_id")
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

