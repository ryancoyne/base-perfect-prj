//
//  FormFieldExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var formFieldDic : FormFieldDictionary {
        get {
            var bc = FormFieldDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct FormFieldDictionary {
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
    var length : Int? {
        get {
            return self.dic["length"].intValue
        }
        set {
            if newValue != nil {
                self.dic["length"] = newValue!
            } else {
                self.dic.removeValue(forKey: "length")
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
    var isRequired : Bool? {
        get {
            return self.dic["is_required"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["is_required"] = newValue!
            } else {
                self.dic.removeValue(forKey: "is_required")
            }
        }
    }
    var needsConfirmation : Bool? {
        get {
            return self.dic["needs_confirmation"].boolValue
        }
        set {
            if newValue != nil {
                self.dic["needs_confirmation"] = newValue!
            } else {
                self.dic.removeValue(forKey: "needs_confirmation")
            }
        }
    }
}
