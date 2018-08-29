//
//  AddressExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var usBankDic : USBankDictionary {
        get {
            var bc = USBankDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct USBankDictionary {
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
    var retailerContactId : Int? {
        get {
            return self.dic["retailer_contact_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["retailer_contact_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "retailer_contact_id")
            }
        }
    }
    var address1 : String? {
        get {
            return self.dic["address1"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["address1"] = newValue!
            } else {
                self.dic.removeValue(forKey: "address1")
            }
        }
    }
    var address2 : String? {
        get {
            return self.dic["address2"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["address2"] = newValue!
            } else {
                self.dic.removeValue(forKey: "address2")
            }
        }
    }
    var address3 : String? {
        get {
            return self.dic["address3"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["address3"] = newValue!
            } else {
                self.dic.removeValue(forKey: "address3")
            }
        }
    }
    var city : String? {
        get {
            return self.dic["city"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["city"] = newValue!
            } else {
                self.dic.removeValue(forKey: "city")
            }
        }
    }
    var state : String? {
        get {
            return self.dic["state"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["state"] = newValue!
            } else {
                self.dic.removeValue(forKey: "state")
            }
        }
    }
    var postalCode : String? {
        get {
            return self.dic["postal_code"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["postal_code"] = newValue!
            } else {
                self.dic.removeValue(forKey: "postal_code")
            }
        }
    }
    var ach_transfer_minimum : Double? {
        get {
            return self.dic["ach_transfer_minimum"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["ach_transfer_minimum"] = newValue!
            } else {
                self.dic.removeValue(forKey: "ach_transfer_minimum")
            }
        }
    }

}


