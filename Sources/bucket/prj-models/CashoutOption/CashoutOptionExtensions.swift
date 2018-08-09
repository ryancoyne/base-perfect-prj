//
//  CashoutOptionExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var cashoutOptionsDic : CashoutOptionsDictionary {
        get {
            var bc = CashoutOptionsDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CashoutOptionsDictionary {
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
    var typeId : Int? {
        get {
            return self.dic["type_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["type_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "type_id")
            }
        }
    }
    var formId : Int? {
        get {
            return self.dic["form_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["form_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "form_id")
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
    var displayOrder : Int? {
        get {
            return self.dic["display_order"].intValue
        }
        set {
            if newValue != nil {
                self.dic["display_order"] = newValue!
            } else {
                self.dic.removeValue(forKey: "display_order")
            }
        }
    }
    var minimum : Double? {
        get {
            return self.dic["minimum"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["minimum"] = newValue!
            } else {
                self.dic.removeValue(forKey: "minimum")
            }
        }
    }
    var maximum : Double? {
        get {
            return self.dic["maximum"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["maximum"] = newValue!
            } else {
                self.dic.removeValue(forKey: "maximum")
            }
        }
    }
    var pictureURL : String? {
        get {
            return self.dic["pictureURL"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["pictureURL"] = newValue!
            } else {
                self.dic.removeValue(forKey: "pictureURL")
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
}

