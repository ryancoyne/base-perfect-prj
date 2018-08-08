//
//  POSExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

extension Dictionary where Key == String, Value == Any {
    var posDic : POSDictionary {
        get {
            var bc = POSDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct POSDictionary {
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
    var model : String? {
        get {
            return self.dic["model"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["model"] = newValue!
            } else {
                self.dic.removeValue(forKey: "model")
            }
        }
    }
    var imageURL : String? {
        get {
            return self.dic["imageURL"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["imageURL"] = newValue!
            } else {
                self.dic.removeValue(forKey: "imageURL")
            }
        }
    }
}

