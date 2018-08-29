//
//  CompletedFormsDetailExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/29/18.
//

extension Dictionary where Key == String, Value == Any {
    var cfDetailDic : CompletedFormsDetailDictionary {
        get {
            var bc = CompletedFormsDetailDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CompletedFormsDetailDictionary {
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
    
    var cfHeaderId : Int? {
        get {
            return self.dic["cf_header_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["cf_header_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "cf_header_id")
            }
        }
    }
    
    var batch_group : String? {
        get {
            return self.dic["batch_group"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["batch_group"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batch_group")
            }
        }
    }
    
    var batch_order : Int? {
        get {
            return self.dic["batch_order"].intValue
        }
        set {
            if newValue != nil {
                self.dic["batch_order"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batch_order")
            }
        }
    }
    
    var detail_line : String? {
        get {
            return self.dic["detail_line"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["detail_line"] = newValue!
            } else {
                self.dic.removeValue(forKey: "detail_line")
            }
        }
    }
    
}

