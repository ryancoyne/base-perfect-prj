//
//  LedgerExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var ledgerDic : LedgerDictionary {
        get {
            var bc = LedgerDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct LedgerDictionary {
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
    
    var ledger_account_id : Int? {
        get {
            return self.dic["ledger_account_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["ledger_account_id"] = newValue.intValue
            } else {
                self.dic.removeValue(forKey: "ledger_account_id")
            }
        }
    }
    
    var ledger_type_id : Int? {
        get {
            return self.dic["ledger_type_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["ledger_type_id"] = newValue.intValue
            } else {
                self.dic.removeValue(forKey: "ledger_type_id")
            }
        }
    }
    
    var wallet_entry : Bool? {
        get {
            return self.dic["wallet_entry"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["wallet_entry"] = newValue.boolValue
            } else {
                self.dic.removeValue(forKey: "wallet_entry")
            }
        }
    }
    
    var wallet_bucket_user_id : String? {
        get {
            return self.dic["wallet_bucket_user_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["wallet_bucket_user_id"] = newValue.stringValue
            } else {
                self.dic.removeValue(forKey: "wallet_bucket_user_id")
            }
        }
    }
    
    var credit : Double? {
        get {
            return self.dic["credit"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["credit"] = newValue.doubleValue
            } else {
                self.dic.removeValue(forKey: "credit")
            }
        }
    }
    
    var debit : Double? {
        get {
            return self.dic["double"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["double"] = newValue.doubleValue
            } else {
                self.dic.removeValue(forKey: "double")
            }
        }
    }
    
    var customer_code : String? {
        get {
            return self.dic["customer_code"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["customer_code"] = newValue!
            } else {
                self.dic.removeValue(forKey: "customer_code")
            }
        }
    }
    var blockchain_audit : String? {
        get {
            return self.dic["blockchain_audit"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["blockchain_audit"] = newValue!
            } else {
                self.dic.removeValue(forKey: "blockchain_audit")
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
}
