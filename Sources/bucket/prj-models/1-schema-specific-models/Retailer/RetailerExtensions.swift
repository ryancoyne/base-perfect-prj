//
//  RetailerExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var retailerDic : RetailerDictionary {
        get {
            var bc = RetailerDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct RetailerDictionary {
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
    
    var retailerCode : String? {
        get {
            return self.dic["retailer_code"].stringValue?.lowercased()
        }
        set {
            if newValue != nil {
                self.dic["retailer_code"] = newValue!.lowercased()
            } else {
                self.dic.removeValue(forKey: "retailer_code")
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
    var isSuspended : Bool? {
        get {
            return self.dic["is_suspended"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["is_suspended"] = newValue!
            } else {
                self.dic.removeValue(forKey: "is_suspended")
            }
        }
    }
    var isVerified : Bool? {
        get {
            return self.dic["is_verified"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["is_verified"] = newValue!
            } else {
                self.dic.removeValue(forKey: "is_verified")
            }
        }
    }
    var sendSettlementConfirmation : Bool? {
        get {
            return self.dic["send_settlement_confirmation"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["send_settlement_confirmation"] = newValue!
            } else {
                self.dic.removeValue(forKey: "send_settlement_confirmation")
            }
        }
    }
    var ach_transfer_minimum_default : Double? {
        get {
            return self.dic["ach_transfer_minimum_default"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["ach_transfer_minimum_default"] = newValue!
            } else {
                self.dic.removeValue(forKey: "ach_transfer_minimum_default")
            }
        }
    }
}
