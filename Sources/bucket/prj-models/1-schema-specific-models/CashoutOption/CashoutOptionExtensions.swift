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
    var vendorDetail : [String:Any]? {
        get {
            return self.dic["vendor_detail"] as? [String:Any]
        }
        set {
            if newValue != nil {
                self.dic["vendor_detail"] = newValue!
            } else {
                self.dic.removeValue(forKey: "vendor_detail")
            }
        }
    }
    var confirmationDescription : String? {
        get {
            return self.dic["confirmation_description"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["confirmation_description"] = newValue!
            } else {
                self.dic.removeValue(forKey: "confirmation_description")
            }
        }
    }
    var increment : Double? {
        get {
            return self.dic["increment"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["increment"] = newValue!
            } else {
                self.dic.removeValue(forKey: "increment")
            }
        }
    }
    var cashoutSourceId : Int? {
        get {
            return self.dic["cashout_source_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["cashout_source_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "cashout_source_id")
            }
        }
    }
    var groupId : Int? {
        get {
            return self.dic["group_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["group_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "group_id")
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
    var smallPictureURL : String? {
        get {
            return self.dic["sm_picture_url"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["sm_picture_url"] = newValue!
            } else {
                self.dic.removeValue(forKey: "sm_picture_url")
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

