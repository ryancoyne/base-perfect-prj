//
//  CashoutTypesExtension.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var cashoutGroupDic : CashoutGroupDictionary {
        get {
            var bc = CashoutGroupDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CashoutGroupDictionary {
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
    
    var group_name : String? {
        get {
            return self.dic["group_name"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["group_name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "group_name")
            }
        }
    }

    var display_order : Int? {
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

    var country_id : Int? {
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

    var picture_url : String? {
        get {
            return self.dic["picture_url"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["picture_url"] = newValue!
            } else {
                self.dic.removeValue(forKey: "picture_url")
            }
        }
    }
    
    var iconURL : String? {
        get {
            return self.dic["icon_url"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["icon_url"] = newValue!
            } else {
                self.dic.removeValue(forKey: "icon_url")
            }
        }
    }
    
    var optionLayout : String? {
        get {
            return self.dic["option_layout"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["option_layout"] = newValue!
            } else {
                self.dic.removeValue(forKey: "option_layout")
            }
        }
    }

    var display : Bool? {
        get {
            return self.dic["display"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["display"] = newValue!
            } else {
                self.dic.removeValue(forKey: "display")
            }
        }
    }

}
