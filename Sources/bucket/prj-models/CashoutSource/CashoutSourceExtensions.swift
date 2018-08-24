//
//  CashoutOptionExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var cashoutSourceDic : CashoutSourceDictionary {
        get {
            var bc = CashoutSourceDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CashoutSourceDictionary {
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
    
    var sourceId : String? {
        get {
            return self.dic["source_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["source_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "source_id")
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
    var website : String? {
        get {
            return self.dic["website"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["website"] = newValue!
            } else {
                self.dic.removeValue(forKey: "website")
            }
        }
    }
    var longDescription : String? {
        get {
            return self.dic["long_description"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["long_description"] = newValue!
            } else {
                self.dic.removeValue(forKey: "long_description")
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

