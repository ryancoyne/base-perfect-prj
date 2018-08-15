//
//  TransactionHistoryExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var codeTransactionHistoryDic : CodeTransactionHistoryDictionary {
        get {
            var bc = CodeTransactionHistoryDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CodeTransactionHistoryDictionary {
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

    var codeTransactionId : Int? {
        get {
            return self.dic["code_transaction_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["code_transaction_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "code_transaction_id")
            }
        }
    }

    var countryId : Int? {
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
    var customerCode : String? {
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
    var customerCodeURL : String? {
        get {
            return self.dic["customer_codeurl"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["customer_codeurl"] = newValue!
            } else {
                self.dic.removeValue(forKey: "customer_codeurl")
            }
        }
    }
    var disputed : Int? {
        get {
            return self.dic["disputed"].intValue
        }
        set {
            if newValue != nil {
                self.dic["disputed"] = newValue!
            } else {
                self.dic.removeValue(forKey: "disputed")
            }
        }
    }
    var disputedBy : String? {
        get {
            return self.dic["disputedby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["disputedby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "disputedby")
            }
        }
    }
    var redeemed : Int? {
        get {
            return self.dic["redeemed"].intValue
        }
        set {
            if newValue != nil {
                self.dic["redeemed"] = newValue!
            } else {
                self.dic.removeValue(forKey: "redeemed")
            }
        }
    }
    var redeemedBy : String? {
        get {
            return self.dic["redeemedby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["redeemedby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "redeemedby")
            }
        }
    }
    
    var archived : Int? {
        get {
            return self.dic["archived"].intValue
        }
        set {
            if newValue != nil {
                self.dic["archived"] = newValue!
            } else {
                self.dic.removeValue(forKey: "archived")
            }
        }
    }
    var archivedBy : String? {
        get {
            return self.dic["archivedby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["archivedby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "archivedby")
            }
        }
    }

    var cashedout : Int? {
        get {
            return self.dic["cashedout"].intValue
        }
        set {
            if newValue != nil {
                self.dic["cashedout"] = newValue!
            } else {
                self.dic.removeValue(forKey: "cashedout")
            }
        }
    }
    var cashedoutBy : String? {
        get {
            return self.dic["cashedoutby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["cashedoutby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "cashedoutby")
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
    var batchId : String? {
        get {
            return self.dic["batch_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["batch_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batch_id")
            }
        }
    }
    var terminalId : Int? {
        get {
            return self.dic["terminal_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["terminal_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "terminal_id")
            }
        }
    }
    var amount : Double? {
        get {
            return self.dic["amount"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["amount"] = newValue!
            } else {
                self.dic.removeValue(forKey: "amount")
            }
        }
    }
    var totalAmount : Double? {
        get {
            return self.dic["total_amount"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["total_amount"] = newValue!
            } else {
                self.dic.removeValue(forKey: "total_amount")
            }
        }
    }
    var clientLocation : String? {
        get {
            return self.dic["clientLocation"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["clientLocation"] = newValue!
            } else {
                self.dic.removeValue(forKey: "clientLocation")
            }
        }
    }
    var clientTransactionId : String? {
        get {
            return self.dic["client_transaction_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["client_transaction_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "client_transaction_id")
            }
        }
    }
}
