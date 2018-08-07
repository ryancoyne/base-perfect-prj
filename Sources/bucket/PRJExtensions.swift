extension Dictionary where Key == String, Value == Any {
    var capsuleskin : CapsuleskinDictionary! {
        get {
            var bc = CapsuleskinDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Capsuleskin Dictionary Variable Values
struct CapsuleskinDictionary {
    fileprivate var dic : [String:Any]!
    /// This variable key is "description". Set nil to remove from the dictionary.
    var capsuleskin_description : String? {
        get {
            return self.dic["capsuleskin_description"] as? String
        }
        set {
            if newValue != nil {
                self.dic["capsuleskin_description"] = newValue!
            } else {
                self.dic.removeValue(forKey: "capsuleskin_description")
            }
        }
    }
    /// This variable key is "capsuleidentifier". Set nil to remove from the dictionary.
    var capsuleskin_identifier : Int? {
        get {
            return self.dic["capsuleskin_identifier"] as? Int
        }
        set {
            if newValue != nil {
                self.dic["capsuleskin_identifier"] = newValue!
            } else {
                self.dic.removeValue(forKey: "capsuleskin_identifier")
            }
        }
    }
}

