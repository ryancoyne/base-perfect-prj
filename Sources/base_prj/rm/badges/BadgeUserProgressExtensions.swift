//
//  BadgeUserExtensions.swift
//

extension Dictionary where Key == String, Value == Any {
    var badgeuserprogress : BadgeUserProgressDictionary {
        get {
            var bc = BadgeUserProgressDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: BadgeUser-Key Dictionary Variable Values
struct BadgeUserProgressDictionary {
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
    /// This variable key is "badge_id". Set nil to remove from the dictionary.
    var badge_id : Int? {
        get {
            return self.dic["badge_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["badge_id"] = newValue.intValue
            } else {
                self.dic.removeValue(forKey: "badge_id")
            }
        }
    }
    /// This variable key is "badge_id". Set nil to remove from the dictionary.
    var badge_progress_added : Int? {
        get {
            return self.dic["badge_progress_added"].intValue
        }
        set {
            if newValue != nil {
                self.dic["badge_progress_added"] = newValue.intValue
            } else {
                self.dic.removeValue(forKey: "badge_progress_added")
            }
        }
    }

    /// This variable key is "user_id". Set nil to remove from the dictionary.
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
    /// This variable key is "badge_received". Set nil to remove from the dictionary.
    var badge_progress_note : String? {
        get {
            return self.dic["badge_progress_note"] as? String
        }
        set {
            if newValue != nil {
                self.dic["badge_progress_note"] = newValue!
            } else {
                self.dic.removeValue(forKey: "badge_progress_note")
            }
        }
    }
}

