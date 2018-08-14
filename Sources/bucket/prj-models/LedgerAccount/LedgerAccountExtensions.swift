//
//  LedgerAccountExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var ledgerAccountDict : LedgerAccountDictionary {
        get {
            var bc = LedgerAccountDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct LedgerAccountDictionary {
    fileprivate var dic : [String:Any]!
    /// This variable key is "id". Set nil to remove from the dictionary.
    var ledger_account_type_id : Int? {
        get {
            return self.dic["ledger_account_type_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["ledger_account_type_id"] = newValue.intValue
            } else {
                self.dic.removeValue(forKey: "ledger_account_type_id")
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
