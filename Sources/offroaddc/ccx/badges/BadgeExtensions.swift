//
//  BadgeExtensions.swift
//
//  Created by Mike Silvers on 01/21/18.
//

extension Dictionary where Key == String, Value == Any {
    var badge : BadgeDictionary {
        get {
            var bc = BadgeDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct BadgeDictionary {
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
    /// This variable key is "name". Set nil to remove from the dictionary.
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
    /// This variable key is "picture_url". Set nil to remove from the dictionary.
    var picture_url : String? {
        get {
            return self.dic["picture_url"] as? String
        }
        set {
            if newValue != nil {
                self.dic["picture_url"] = newValue!
            } else {
                self.dic.removeValue(forKey: "picture_url")
            }
        }
    }
    var number_required     : Int?    {
        get {
            return self.dic["number_required"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["number_required"] = newValue!
            } else {
                self.dic.removeValue(forKey: "number_required")
            }
        }
    }
    
    var date_expired        : Int?    {
        get {
            return self.dic["date_expired"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["date_expired"] = newValue!
            } else {
                self.dic.removeValue(forKey: "date_expired")
            }
        }
    }
    
    var seconds_required    : Int?    {
        get {
            return self.dic["seconds_required"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["seconds_required"] = newValue!
            } else {
                self.dic.removeValue(forKey: "seconds_required")
            }
        }
    }

}

