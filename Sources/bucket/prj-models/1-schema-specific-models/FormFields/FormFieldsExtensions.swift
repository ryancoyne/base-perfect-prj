//
//  FormFieldsExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var formFieldsDic : FormFieldsDictionary {
        get {
            var bc = FormFieldsDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct FormFieldsDictionary {
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
    var fieldId : Int? {
        get {
            return self.dic["field_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["field_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "field_id")
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
}
