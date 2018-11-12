//
//  TerminalExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var terminalDic : TerminalDictionary {
        get {
            var bc = TerminalDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct TerminalDictionary {
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
    
    var posId : Int? {
        get {
            return self.dic["pos_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["pos_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "pos_id")
            }
        }
    }
    var addressId : Int? {
        get {
            return self.dic["address_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["address_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "address_id")
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
    var serialNumber : String? {
        get {
            return self.dic["serial_number"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["serial_number"] = newValue!
            } else {
                self.dic.removeValue(forKey: "serial_number")
            }
        }
    }
    var terminalKey : String? {
        get {
            return self.dic["terminal_key"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["terminal_key"] = newValue!
            } else {
                self.dic.removeValue(forKey: "terminal_key")
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
    var isApproved : Bool? {
        get {
            return self.dic["is_approved"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["is_approved"] = newValue!
            } else {
                self.dic.removeValue(forKey: "is_approved")
            }
        }
    }
    var isSampleOnly : Bool? {
        get {
            return self.dic["is_sample_only"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["is_sample_only"] = newValue!
            } else {
                self.dic.removeValue(forKey: "is_sample_only")
            }
        }
    }
    var requireEmployeeId : Bool? {
        get {
            return self.dic["require_employee_id"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["require_employee_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "require_employee_id")
            }
        }
    }
}
