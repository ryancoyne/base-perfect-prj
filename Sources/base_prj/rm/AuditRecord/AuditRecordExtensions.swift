//
//  LogExtensions.swift
//  bucket
//
//  Created by Mike Silvers on 9/29/18.
//

extension Dictionary where Key == String, Value == Any {
    var auditRecordDic : AuditRecordDictionary {
        get {
            var bc = AuditRecordDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct AuditRecordDictionary {
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
    
    var session_id : String? {
        get {
            return self.dic["session_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["session_id"] = newValue.stringValue
            } else {
                self.dic.removeValue(forKey: "session_id")
            }
        }
    }
    
    var audit_group : String? {
        get {
            return self.dic["audit_group"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["audit_group"] = newValue.stringValue
            } else {
                self.dic.removeValue(forKey: "audit_group")
            }
        }
    }
    
    var audit_action : String? {
        get {
            return self.dic["audit_action"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["audit_action"] = newValue.stringValue
            } else {
                self.dic.removeValue(forKey: "audit_action")
            }
        }
    }
    
    var row_data : [String:Any]? {
        get {
            if let detailObj = self.dic["row_data"] {
                return detailObj as? [String:Any] ?? [String:Any]()
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                let newval = newValue ?? [String:Any]()
                self.dic["row_data"] = try? newval.jsonEncodedString()
            } else {
                self.dic.removeValue(forKey: "row_data")
            }
        }
    }

    var changed_fields : [String:Any]? {
        get {
            if let detailObj = self.dic["changed_fields"] {
                return detailObj as? [String:Any] ?? [String:Any]()
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                let newval = newValue ?? [String:Any]()
                self.dic["changed_fields"] = try? newval.jsonEncodedString()
            } else {
                self.dic.removeValue(forKey: "changed_fields")
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
