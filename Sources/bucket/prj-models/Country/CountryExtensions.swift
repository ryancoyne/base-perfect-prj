//
//  CountryExtensions.swift
//  COpenSSL
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var countryDic : CountryDictionary {
        get {
            var bc = CountryDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CountryDictionary {
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
            return self.dic["name"] as? String
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
            return self.dic["local_name"] as? String
        }
        set {
            if newValue != nil {
                self.dic["local_name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "local_name")
            }
        }
    }
    var codeNumeric : String? {
        get {
            return self.dic["code_numeric"] as? String
        }
        set {
            if newValue != nil {
                self.dic["code_numeric"] = newValue!
            } else {
                self.dic.removeValue(forKey: "code_numeric")
            }
        }
    }
    var codeAlpha2 : String? {
        get {
            return self.dic["code_alpha_2"] as? String
        }
        set {
            if newValue != nil {
                self.dic["code_alpha_2"] = newValue!
            } else {
                self.dic.removeValue(forKey: "code_alpha_2")
            }
        }
    }
    var codeAlpha3 : String? {
        get {
            return self.dic["code_alpha_3"] as? String
        }
        set {
            if newValue != nil {
                self.dic["code_alpha_3"] = newValue!
            } else {
                self.dic.removeValue(forKey: "code_alpha_3")
            }
        }
    }
}
