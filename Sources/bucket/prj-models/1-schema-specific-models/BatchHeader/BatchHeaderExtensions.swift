//
//  CashoutTypesExtension.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

extension Dictionary where Key == String, Value == Any {
    var batchHeaderDic : BatchHeaderDictionary {
        get {
            var bc = BatchHeaderDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct BatchHeaderDictionary {
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
    
    var batch_type : String? {
        get {
            return self.dic["batch_type"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["batch_type"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batch_type")
            }
        }
    }
    
    var fileName : String? {
        get {
            return self.dic["file_name"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["file_name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "file_name")
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
    
    var batch_identifier : String? {
        get {
            return self.dic["batch_identifier"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["batch_identifier"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batch_identifier")
            }
        }
    }

    var current_status : String? {
        get {
            return self.dic["current_status"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["current_status"] = newValue!
            } else {
                self.dic.removeValue(forKey: "current_status")
            }
        }
    }

    var status : Int? {
        get {
            return self.dic["status"].intValue
        }
        set {
            if newValue != nil {
                self.dic["status"] = newValue!
            } else {
                self.dic.removeValue(forKey: "status")
            }
        }
    }
    
    var statusby : String? {
        get {
            return self.dic["status"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["status"] = newValue!
            } else {
                self.dic.removeValue(forKey: "status")
            }
        }
    }

    var initial_send : Int? {
        get {
            return self.dic["initial_send"].intValue
        }
        set {
            if newValue != nil {
                self.dic["initial_send"] = newValue!
            } else {
                self.dic.removeValue(forKey: "initial_send")
            }
        }
    }
    
    var initial_sendby : String? {
        get {
            return self.dic["initial_sendby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["initial_sendby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "initial_sendby")
            }
        }
    }

    var last_send : Int? {
        get {
            return self.dic["last_send"].intValue
        }
        set {
            if newValue != nil {
                self.dic["last_send"] = newValue!
            } else {
                self.dic.removeValue(forKey: "last_send")
            }
        }
    }
    
    var last_sendby : String? {
        get {
            return self.dic["last_sendby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["last_sendby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "last_sendby")
            }
        }
    }
    
    var record_start_date : Int? {
        get {
            return self.dic["record_start_date"].intValue
        }
        set {
            if newValue != nil {
                self.dic["record_start_date"] = newValue!
            } else {
                self.dic.removeValue(forKey: "record_start_date")
            }
        }
    }

    var record_end_date : Int? {
        get {
            return self.dic["record_end_date"].intValue
        }
        set {
            if newValue != nil {
                self.dic["record_end_date"] = newValue!
            } else {
                self.dic.removeValue(forKey: "record_end_date")
            }
        }
    }

}

