//
//  ClassCompetitionExtensions.swift
//
//  Created by Mike Silvers on 05/02/18.
//

extension Dictionary where Key == String, Value == Any {
    var class_competition_date : ClassCompetitionDateDictionary {
        get {
            var bc = ClassCompetitionDateDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct ClassCompetitionDateDictionary {
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

    var leader_user_id : String? {
        get {
            return self.dic["leader_user_id"] as? String
        }
        set {
            if newValue != nil {
                self.dic["leader_user_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "leader_user_id")
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
    
    var private_competition : Bool? {
        get {
            return self.dic["private_competition"] as? Bool
        }
        set {
            if newValue != nil {
                self.dic["private_competition"] = newValue!
            } else {
                self.dic.removeValue(forKey: "private_competition")
            }
        }
    }
    
    var competition_type_id : Int? {
        get {
            return self.dic["competition_type_id"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["competition_type_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "competition_type_id")
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

    var number_of_registrations : Int? {
        get {
            return self.dic["number_of_registrations"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["number_of_registrations"] = newValue!
            } else {
                self.dic.removeValue(forKey: "number_of_registrations")
            }
        }
    }

    var number_of_waitlist : Int? {
        get {
            return self.dic["number_of_waitlist"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["number_of_waitlist"] = newValue!
            } else {
                self.dic.removeValue(forKey: "number_of_waitlist")
            }
        }
    }

}

