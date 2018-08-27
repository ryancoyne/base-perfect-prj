//
//  CompletedFormsExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var completedFormsDic : CompletedFormsDictionary {
        get {
            var bc = CompletedFormsDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CompletedFormsDictionary {
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
    var optionId : Int? {
        get {
            return self.dic["option_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["option_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "option_id")
            }
        }
    }
    var userId : String? {
        get {
            return self.dic["user_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["field_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "field_id")
            }
        }
    }
    var fieldValue : String? {
        get {
            return self.dic["field_value"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["field_value"] = newValue!
            } else {
                self.dic.removeValue(forKey: "field_value")
            }
        }
    }
    var valueDataType : String? {
        get {
            return self.dic["value_data_type"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["value_data_type"] = newValue!
            } else {
                self.dic.removeValue(forKey: "value_data_type")
            }
        }
    }
    var fieldName : String? {
        get {
            return self.dic["field_name"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["field_name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "field_name")
            }
        }
    }
}

