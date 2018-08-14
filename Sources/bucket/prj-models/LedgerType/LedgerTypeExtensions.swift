//
//  LedgerTypeExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var ledgerTypeDic : LedgerTypeDictionary {
        get {
            var bc = LedgerTypeDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct LedgerTypeDictionary {
    fileprivate var dic : [String:Any]!
    
    var account_type : String? {
        get {
            return self.dic["account_type"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["account_type"] = newValue!
            } else {
                self.dic.removeValue(forKey: "account_type")
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
