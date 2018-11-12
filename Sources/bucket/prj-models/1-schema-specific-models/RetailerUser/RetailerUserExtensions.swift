//
//  RetailerUserExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var retailerUserDic : RetailerUserDictionary {
        get {
            var bc = RetailerUserDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: RetailerUser Dictionary Variable Values
struct RetailerUserDictionary {
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
    
    var retailerId : Int? {
        get {
            return self.dic["retailer_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["retailer_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "retailer_id")
            }
        }
    }
    var userCustomId : String? {
        get {
            return self.dic["user_custom_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["user_custom_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "user_custom_id")
            }
        }
    }
    var accountId : String? {
        get {
            return self.dic["account_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["account_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "account_id")
            }
        }
    }
    var dateStart : Int? {
        get {
            return self.dic["date_start"].intValue
        }
        set {
            if newValue != nil {
                self.dic["date_start"] = newValue!
            } else {
                self.dic.removeValue(forKey: "date_start")
            }
        }
    }
    var dateEnd : Int? {
        get {
            return self.dic["date_end"].intValue
        }
        set {
            if newValue != nil {
                self.dic["date_end"] = newValue!
            } else {
                self.dic.removeValue(forKey: "date_end")
            }
        }
    }
    var mayUseTerminal : Bool? {
        get {
            return self.dic["may_use_terminal"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["may_use_terminal"] = newValue!
            } else {
                self.dic.removeValue(forKey: "may_use_terminal")
            }
        }
    }
}
