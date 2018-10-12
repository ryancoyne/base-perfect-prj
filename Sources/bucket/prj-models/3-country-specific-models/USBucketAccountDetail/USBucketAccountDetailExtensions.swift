//
//  AddressExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var usBucketAccountDetailDic : USBucketAccountDetailDictionary {
        get {
            var bc = USBucketAccountDetailDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct USBucketAccountDetailDictionary {
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
    var processed : Int? {
        get {
            return self.dic["processed"].intValue
        }
        set {
            if newValue != nil {
                self.dic["processed"] = newValue!
            } else {
                self.dic.removeValue(forKey: "processed")
            }
        }
    }
    var processedby : String? {
        get {
            return self.dic["processedby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["processedby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "processedby")
            }
        }
    }
    var record_type : String? {
        get {
            return self.dic["record_type"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["record_type"] = newValue!
            } else {
                self.dic.removeValue(forKey: "record_type")
            }
        }
    }
    var change_date : String? {
        get {
            return self.dic["change_date"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["change_date"] = newValue!
            } else {
                self.dic.removeValue(forKey: "change_date")
            }
        }
    }
    var change_time : String? {
        get {
            return self.dic["change_time"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["change_time"] = newValue!
            } else {
                self.dic.removeValue(forKey: "change_time")
            }
        }
    }
    var account_number : String? {
        get {
            return self.dic["account_number"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["account_number"] = newValue!
            } else {
                self.dic.removeValue(forKey: "account_number")
            }
        }
    }
    var value_original : Int? {
        get {
            return self.dic["value_original"].intValue
        }
        set {
            if newValue != nil {
                self.dic["value_original"] = newValue!
            } else {
                self.dic.removeValue(forKey: "value_original")
            }
        }
    }
    var value_new : Int? {
        get {
            return self.dic["value_new"].intValue
        }
        set {
            if newValue != nil {
                self.dic["value_new"] = newValue!
            } else {
                self.dic.removeValue(forKey: "value_new")
            }
        }
    }
    var code_number : String? {
        get {
            return self.dic["code_number"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["code_number"] = newValue!
            } else {
                self.dic.removeValue(forKey: "code_number")
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
    var adjustment_reason : Int? {
        get {
            return self.dic["adjustment_reason"].intValue
        }
        set {
            if newValue != nil {
                self.dic["adjustment_reason"] = newValue!
            } else {
                self.dic.removeValue(forKey: "adjustment_reason")
            }
        }
    }
    var disbursement_reason : Int? {
        get {
            return self.dic["disbursement_reason"].intValue
        }
        set {
            if newValue != nil {
                self.dic["disbursement_reason"] = newValue!
            } else {
                self.dic.removeValue(forKey: "disbursement_reason")
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


