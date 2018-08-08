//
//  ContactTypeExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var contactsDic : ContactTypeDictionary {
        get {
            var bc = ContactTypeDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct ContactTypeDictionary {
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
    
    var contactId : Int? {
        get {
            return self.dic["contact_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["contact_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "contact_id")
            }
        }
    }
}


