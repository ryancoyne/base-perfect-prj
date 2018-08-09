//
//  CurrencyExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var currencyDic : CurrencyDictionary {
        get {
            var bc = CurrencyDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CurrencyDictionary {
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
    var localName : String? {
        get {
            return self.dic["local_name"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["local_name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "local_name")
            }
        }
    }
    var codeNumeric : Int? {
        get {
            return self.dic["code_numeric"].intValue
        }
        set {
            if newValue != nil {
                self.dic["code_numeric"] = newValue!
            } else {
                self.dic.removeValue(forKey: "code_numeric")
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
}

