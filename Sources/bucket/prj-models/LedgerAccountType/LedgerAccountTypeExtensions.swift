//
//  LedgerAccountTypeExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var ledgerAccountTypeDict : LedgerAccountTypeDictionary {
        get {
            var bc = LedgerAccountTypeDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct LedgerAccountTypeDictionary {
    fileprivate var dic : [String:Any]!
    /// This variable key is "id". Set nil to remove from the dictionary.
    
    var account_group : String? {
        get {
            return self.dic["account_group"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["account_group"] = newValue!
            } else {
                self.dic.removeValue(forKey: "account_group")
            }
        }
    }
    var description : String? {
        get {
            return self.dic["description"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["description"] = newValue!
            } else {
                self.dic.removeValue(forKey: "description")
            }
        }
    }
    var title : String? {
        get {
            return self.dic["title"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["title"] = newValue!
            } else {
                self.dic.removeValue(forKey: "title")
            }
        }
    }
}
