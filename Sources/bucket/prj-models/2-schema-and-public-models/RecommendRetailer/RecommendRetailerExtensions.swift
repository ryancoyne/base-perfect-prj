//
//  AddressExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var recommendRetailerDic : RecommendedRetailerDictionary {
        get {
            var bc = RecommendedRetailerDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct RecommendedRetailerDictionary {
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
            return self.dic["user_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["user_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "user_id")
            }
        }
    }
    var email_to : String? {
        get {
            return self.dic["email_to"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["email_to"] = newValue!
            } else {
                self.dic.removeValue(forKey: "email_to")
            }
        }
    }
    var emailsent : Int? {
        get {
            return self.dic["emailsent"].intValue
        }
        set {
            if newValue != nil {
                self.dic["emailsent"] = newValue!
            } else {
                self.dic.removeValue(forKey: "emailsent")
            }
        }
    }
    var emailsentby : String? {
        get {
            return self.dic["emailsentby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["emailsentby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "emailsentby")
            }
        }
    }
    var state : String? {
        get {
            return self.dic["state"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["state"] = newValue!
            } else {
                self.dic.removeValue(forKey: "state")
            }
        }
    }
    var city : String? {
        get {
            return self.dic["city"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["city"] = newValue!
            } else {
                self.dic.removeValue(forKey: "city")
            }
        }
    }
    var address : String? {
        get {
            return self.dic["address"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["address"] = newValue!
            } else {
                self.dic.removeValue(forKey: "address")
            }
        }
    }
    var postal_code : String? {
        get {
            return self.dic["postal_code"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["postal_code"] = newValue!
            } else {
                self.dic.removeValue(forKey: "postal_code")
            }
        }
    }
    var country_code : String? {
        get {
            return self.dic["country_code"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["country_code"] = newValue!
            } else {
                self.dic.removeValue(forKey: "country_code")
            }
        }
    }
    var phone : String? {
        get {
            return self.dic["phone"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["phone"] = newValue!
            } else {
                self.dic.removeValue(forKey: "phone")
            }
        }
    }

    var name : String? {
        get {
            return self.dic["name"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "name")
            }
        }
    }

    var note : String? {
        get {
            return self.dic["note"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["note"] = newValue!
            } else {
                self.dic.removeValue(forKey: "note")
            }
        }
    }

}


