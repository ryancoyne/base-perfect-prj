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

    var hoursBetweenProcessing : Int? {
        get {
            return self.dic["hours_between_processing"].intValue
        }
        set {
            if newValue != nil {
                self.dic["hours_between_processing"] = newValue!
            } else {
                self.dic.removeValue(forKey: "hours_between_processing")
            }
        }
    }

    var lastprocessed : Int? {
        get {
            return self.dic["lastprocessed"].intValue
        }
        set {
            if newValue != nil {
                self.dic["lastprocessed"] = newValue!
            } else {
                self.dic.removeValue(forKey: "country_id")
            }
        }
    }

    var lastprocessedBy : String? {
        get {
            return self.dic["lastprocessedby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["lastprocessedby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "lastprocessedby")
            }
        }
    }
    var lastprocessedNote : String? {
        get {
            return self.dic["lastprocessed_note"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["lastprocessed_note"] = newValue!
            } else {
                self.dic.removeValue(forKey: "lastprocessed_note")
            }
        }
    }

}

