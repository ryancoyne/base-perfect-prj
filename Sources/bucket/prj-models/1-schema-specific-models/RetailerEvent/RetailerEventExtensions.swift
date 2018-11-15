//
//  RetailerEventExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 11/15/18.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    var retailerEventDic : RetailerEventDictionary {
        get {
            var bc = RetailerEventDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct RetailerEventDictionary {
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
    
    var eventName : String? {
        get {
            return self.dic["event_name"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["event_name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "event_name")
            }
        }
    }
    
    var eventMessage : String? {
        get {
            return self.dic["event_message"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["event_name"] = newValue!
            } else {
                self.dic.removeValue(forKey: "event_name")
            }
        }
    }
    
    var startDate : Int? {
        get {
            return self.dic["start_date"].intValue
        }
        set {
            if newValue != nil {
                self.dic["start_date"] = newValue!
            } else {
                self.dic.removeValue(forKey: "start_date")
            }
        }
    }
    
    var endDate : Int? {
        get {
            return self.dic["start_date"].intValue
        }
        set {
            if newValue != nil {
                self.dic["start_date"] = newValue!
            } else {
                self.dic.removeValue(forKey: "start_date")
            }
        }
    }
    
    var retailerId : Int? {
        get {
            return self.dic["retailer_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["retailer_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "retailer_id")
            }
        }
    }

}
