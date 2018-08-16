//
//  AddressExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var accountTotalDic : AccountTotalDictionary {
        get {
            var bc = AccountTotalDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct AccountTotalDictionary {
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
    var balance : Double? {
        get {
            return self.dic["balance"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["balance"] = newValue!
            } else {
                self.dic.removeValue(forKey: "balance")
            }
        }
    }
}


