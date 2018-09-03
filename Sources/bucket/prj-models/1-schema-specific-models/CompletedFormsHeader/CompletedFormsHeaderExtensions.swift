//
//  CompletedFormsHeaderExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/29/18.
//

extension Dictionary where Key == String, Value == Any {
    var completedFormsHeaderDic : CompletedFormsHeaderDictionary {
        get {
            var bc = CompletedFormsHeaderDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
}

//MARK: Badge-Key Dictionary Variable Values
struct CompletedFormsHeaderDictionary {
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

    var userId : String? {
        get {
            return self.dic["user_id"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["user_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "user_id")
            }
        }
    }
    
    var batchTime : Int? {
        get {
            return self.dic["batch_time"].intValue
        }
        set {
            if newValue != nil {
                self.dic["batch_time"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batch_time")
            }
        }
    }
    var batchBy : String? {
        get {
            return self.dic["batchby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["batchby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batchby")
            }
        }
    }
    var lastBatchTime : Int? {
        get {
            return self.dic["last_batch_time"].intValue
        }
        set {
            if newValue != nil {
                self.dic["last_batch_time"] = newValue!
            } else {
                self.dic.removeValue(forKey: "last_batch_time")
            }
        }
    }
    var lastBatchBy : String? {
        get {
            return self.dic["last_batchby"].stringValue
        }
        set {
            if newValue != nil {
                self.dic["last_batchby"] = newValue!
            } else {
                self.dic.removeValue(forKey: "last_batchby")
            }
        }
    }
    var batchHeaderId : Int? {
        get {
            return self.dic["batch_header_id"].intValue
        }
        set {
            if newValue != nil {
                self.dic["batch_header_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batch_header_id")
            }
        }
    }
//
//    var batch_identifier : String? {
//        get {
//            return self.dic["batch_identifier"].stringValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["batch_identifier"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "batch_identifier")
//            }
//        }
//    }
//
//    var current_status : String? {
//        get {
//            return self.dic["current_status"].stringValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["current_status"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "current_status")
//            }
//        }
//    }
//
//    var status : Int? {
//        get {
//            return self.dic["status"].intValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["status"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "status")
//            }
//        }
//    }
//
//    var statusby : String? {
//        get {
//            return self.dic["statusby"].stringValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["statusby"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "statusby")
//            }
//        }
//    }
//
//    var record_start_date : Int? {
//        get {
//            return self.dic["record_start_date"].intValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["record_start_date"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "record_start_date")
//            }
//        }
//    }
//
//    var record_end_date : Int? {
//        get {
//            return self.dic["record_end_date"].intValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["record_end_date"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "record_end_date")
//            }
//        }
//    }
    
}
