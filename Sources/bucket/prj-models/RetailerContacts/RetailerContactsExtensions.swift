//
//  RetailerContactsExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var retailerContactsDic : RetailerContactsDictionary {
        get {
            var bc = RetailerContactsDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct RetailerContactsDictionary {
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
    
    var userId : String? {
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
    var emailAddress : String? {
        get {
            return self.dic["email_address"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["email_address"] = newValue!
            } else {
                self.dic.removeValue(forKey: "email_address")
            }
        }
    }
    var phoneNumber : String? {
        get {
            return self.dic["phone_number"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["phone_number"] = newValue!
            } else {
                self.dic.removeValue(forKey: "phone_number")
            }
        }
    }
}

