//
//  CashoutTypesExtension.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var codeTransactionRedeemSummaryDic : CodeTransactionRedeemSummaryDictionary {
        get {
            var bc = CodeTransactionRedeemSummaryDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CodeTransactionRedeemSummaryDictionary {
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
    
    var country_id : Int? {
        get {
            return self.dic["country_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["country_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "country_id")
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

}
