//
//  CCXExtensions.swift
//
//  Created by Ryan Coyne on 10/30/17.
//

import Foundation
import PerfectHTTP
import cURL
import PerfectCURL
import PostgresStORM
import PerfectLogger
import StORM
import PerfectLocalAuthentication

#if os(Linux)
    // this is needed in Linux for DispatchSemaphore
    import Dispatch
#endif

extension Dictionary where Key == String, Value == Any {
    var facebook : [String:Any]! {
        get {
            return self["facebook"] as? [String:Any] ?? [:]
        }
        set {
            if newValue != nil {
                self["facebook"] = newValue!
            } else {
                self.removeValue(forKey: "facebook")
            }
        }
    }
    var twitter : [String:Any]! {
        get {
            return self["twitter"] as? [String:Any] ?? [:]
        }
        set {
            if newValue != nil {
                self["twitter"] = newValue!
            } else {
                self.removeValue(forKey: "twitter")
            }
        }
    }
    var google : [String:Any]! {
        get {
            return self["google"] as? [String:Any] ?? [:]
        }
        set {
            if newValue != nil {
                self["google"] = newValue!
            } else {
                self.removeValue(forKey: "google")
            }
        }
    }
    /// This brings in all the breadcrumb dictionary keys.
    var breadcrumb : BreadcrumbDictionary {
        get {
            var bc = BreadcrumbDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
    var user : UserDictionary {
        get {
            var bc = UserDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
    var friend : FriendDictionary {
        get {
            var bc = FriendDictionary()
            bc.dic = self
            return bc
        }
        set {
            self = newValue.dic
        }
    }
//    var badge : BadgeDictionary {
//        get {
//            var bc = BadgeDictionary()
//            bc.dic = self
//            return bc
//        }
//        set {
//            self = newValue.dic
//        }
//    }
//    var badgeuser : BadgeUserDictionary {
//        get {
//            var bc = BadgeUserDictionary()
//            bc.dic = self
//            return bc
//        }
//        set {
//            self = newValue.dic
//        }
//    }
    //MARK: Shared-Key Dictionary Variable Values
    var id : Int? {
        get {
            return self["id"] as? Int
        }
        set {
            if newValue != nil {
                self["id"] = newValue!
            } else {
                self.removeValue(forKey: "id")
            }
        }
    }
    var created : Any? {
        set {
            if newValue != nil, newValue.intValue != 0 {
                self["created"] = newValue
            } else {
                self.removeValue(forKey: "created")
            }
        }
        get {
            return self["created"].intValue ?? self["created"] as? String
        }
    }
    var modified : Any? {
        set {
            if newValue != nil, newValue.intValue != 0 {
                self["modified"] = newValue
            } else {
                self.removeValue(forKey: "modified")
            }
        }
        get {
            return self["modified"].intValue ?? self["modified"] as? String
        }
    }
    var deleted : Any? {
        set {
            if newValue != nil, newValue.intValue != 0 {
                self["deleted"] = newValue
            } else {
                self.removeValue(forKey: "deleted")
            }
        }
        get {
            return self["deleted"].intValue ?? self["deleted"] as? String
        }
    }
    var createdBy : String? {
        set {
            if newValue != nil, !newValue.stringValue!.isEmpty {
                self["createdby"] = newValue
            } else {
                self.removeValue(forKey: "createdby")
            }
        }
        get {
            return self["createdby"] as? String
        }
    }
    var modifiedBy : String? {
        set {
            if newValue != nil, !newValue.stringValue!.isEmpty {
                self["modifiedby"] = newValue
            } else {
                self.removeValue(forKey: "modifiedby")
            }
        }
        get {
            return self["modifiedby"] as? String
        }
    }
    var deletedBy : String? {
        set {
            if newValue != nil, !newValue.stringValue!.isEmpty {
                self["deletedby"] = newValue
            } else {
                self.removeValue(forKey: "deletedby")
            }
        }
        get {
            return self["deletedby"] as? String
        }
    }
    var longdescription : String? {
        set {
            if let val = newValue, !newValue.stringValue!.isEmpty {
                self["longdescription"] = val
                
            } else {
                self.removeValue(forKey: "longdescription")
            }
        }
        get {
            return self["longdescription"] as? String
        }
        
    }
    var shortdescription : String? {
        get {
            return self["description"] as? String
            
        }
        set {
            if let val = newValue, !newValue.stringValue!.isEmpty {
                self["description"] = val
            } else {
                self.removeValue(forKey: "description")
            }
        }
    }
    var longitude : Double? {
        get {
            return self["longitude"].doubleValue
            
        }
        set {
            if newValue != nil {
                self["longitude"] = newValue!
            } else {
                self.removeValue(forKey: "longitude")
    
            }
            
        }
        
    }
    var latitude : Double? {
        get {
            return self["latitude"].doubleValue
        }
        set {
            if newValue != nil {
                self["latitude"] = newValue!
            } else {
                self.removeValue(forKey: "latitude")
            }
        }
    }
    var geopointtime : Any? {
        set {
            if newValue != nil, newValue.intValue != 0 {
                self["geopointtime"] = newValue
            } else {
                self.removeValue(forKey: "geopointtime")
            }
        }
        get {
            return self["geopointtime"].intValue ?? self["geopointtime"] as? String
        }
    }
    var geopoint : [String:Any]! {
        get {
            return self["geopoint"] as? [String:Any] ?? [:]
        }
        set {
            if newValue != nil {
                self["geopoint"] = newValue!
            } else {
                self.removeValue(forKey: "geopoint")
            }
        }
    }

}

//MARK: Breadcrumb-Key Dictionary Variable Values
struct BreadcrumbDictionary {
    fileprivate var dic : [String:Any]!
    /// This variable key is "event_id". Set nil to remove from the dictionary.
    //    var id : Int? {
    //        get {
    //            return self.dic["breadcrumb_id"] as? Int
    //        }
    //        set {
    //            if newValue != nil {
    //                self.dic["breadcrumb_id"] = newValue!
    //            } else {
    //                self.dic.removeValue(forKey: "breadcrumb_id")
    //            }
    //        }
    //
    //    }
    
    
    var applicationstatus : String? {
        get {
            return self.dic["applicationstatus"] as? String
        }
        set {
            if newValue != nil {
                self.dic["applicationstatus"] = newValue!
            } else {
                self.dic.removeValue(forKey: "applicationstatus")
            }
        }
    }
    
    /// This variable key is "title". Set nil to remove from the dictionary.
    var ssid : String? {
        get {
            return self.dic["ssid"] as? String
        }
        set {
            if newValue != nil {
                self.dic["ssid"] = newValue!
            } else {
                self.dic.removeValue(forKey: "ssid")
            }
        }
    }
    var speed : Double? {
        get {
            return self.dic["speed"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["speed"] = newValue!
            } else {
                self.dic.removeValue(forKey: "speed")
            }
        }
    }
    var bssid : String? {
        get {
            return self.dic["bssid"] as? String
        }
        set {
            if newValue != nil {
                self.dic["bssid"] = newValue!
            } else {
                self.dic.removeValue(forKey: "bssid")
            }
        }
    }
    var longitude : Double? {
        get {
            return self.dic["longitude"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["longitude"] = newValue!
            } else {
                self.dic.removeValue(forKey: "longitude")
            }
        }
    }
    var latitude : Double? {
        get {
            return self.dic["latitude"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["latitude"] = newValue!
            } else {
                self.dic.removeValue(forKey: "latitude")
            }
        }
    }
    var horizontalAccuracy : Double? {
        get {
            return self.dic["horizontalaccuracy"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["horizontalaccuracy"] = newValue!
            } else {
                self.dic.removeValue(forKey: "horizontalaccuracy")
            }
        }
    }
    var verticalAccuracy : Double? {
        get {
            return self.dic["verticalaccuracy"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["verticalaccuracy"] = newValue!
            } else {
                self.dic.removeValue(forKey: "verticalaccuracy")
            }
        }
    }
    var distanceFromLast : Double? {
        get {
            return self.dic["distancefromlast"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["distancefromlast"] = newValue!
            } else {
                self.dic.removeValue(forKey: "distancefromlast")
            }
        }
    }
    
    var batterylevel : Double? {
        get {
            return self.dic["batteryLevel"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["batteryLevel"] = newValue!
            } else {
                self.dic.removeValue(forKey: "batteryLevel")
            }
        }
    }
    
    var altitude : Double? {
        get {
            return self.dic["altitude"].doubleValue
        }
        set {
            if newValue != nil {
                self.dic["altitude"] = newValue!
            } else {
                self.dic.removeValue(forKey: "altitude")
            }
        }
    }
    /// This variable can be either an int or a string.
    var geopointtime : Any? {
        get {
            return self.dic["geopointtime"].intValue ?? self.dic["geopointtime"] as? String
        }
        set {
            if newValue != nil, newValue.intValue != 0 {
                self.dic["geopointtime"] = newValue!
            } else {
                self.dic.removeValue(forKey: "geopointtime")
            }
        }
    }
}

//MARK: Friend-Key Dictionary Variable Values
struct FriendDictionary {
    fileprivate var dic : [String:Any]!
    /// This variable key is "user_id". Set nil to remove from the dictionary.
    var user_id : String? {
        get {
            return self.dic["user_id"] as? String
        }
        set {
            if newValue != nil {
                self.dic["user_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "user_id")
            }
        }
    }
    /// This variable key is "friend_id". Set nil to remove from the dictionary.
    var friend_id : String? {
        get {
            return self.dic["friend_id"] as? String
        }
        set {
            if newValue != nil {
                self.dic["friend_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "friend_id")
            }
        }
    }
    /// This variable key is "invited". Set nil to remove from the dictionary.
    var invited : Any? {
        set {
            if newValue != nil, newValue.intValue != 0 {
                self.dic["invited"] = newValue
            } else {
                self.dic.removeValue(forKey: "invited")
            }
        }
        get {
            return self.dic["invited"].intValue ?? self.dic["invited"] as? String
        }
    }
    /// This variable key is "accepted". Set nil to remove from the dictionary.
    var accepted : Any? {
        set {
            if newValue != nil, newValue.intValue != 0 {
                self.dic["accepted"] = newValue
            } else {
                self.dic.removeValue(forKey: "accepted")
            }
        }
        get {
            return self.dic["accepted"].intValue ?? self.dic["accepted"] as? String
        }
    }
    /// This variable key is "rejected". Set nil to remove from the dictionary.
    var rejected : Any? {
        set {
            if newValue != nil, newValue.intValue != 0 {
                self.dic["rejected"] = newValue
            } else {
                self.dic.removeValue(forKey: "rejected")
            }
        }
        get {
            return self.dic["rejected"].intValue ?? self.dic["rejected"] as? String
        }
    }
}
//MARK: Badge-Key Dictionary Variable Values
//struct BadgeDictionary {
//    fileprivate var dic : [String:Any]!
//    /// This variable key is "id". Set nil to remove from the dictionary.
//    var id : Int? {
//        get {
//            return self.dic["id"].intValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["id"] = newValue.intValue
//            } else {
//                self.dic.removeValue(forKey: "id")
//            }
//        }
//    }
//    /// This variable key is "name". Set nil to remove from the dictionary.
//    var name : String? {
//        get {
//            return self.dic["name"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["name"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "name")
//            }
//        }
//    }
//    /// This variable key is "picture_url". Set nil to remove from the dictionary.
//    var url : String? {
//        get {
//            return self.dic["picture_url"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["picture_url"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "picture_url")
//            }
//        }
//    }
//}
//MARK: BadgeUser-Key Dictionary Variable Values
//struct BadgeUserDictionary {
//    fileprivate var dic : [String:Any]!
//    /// This variable key is "id". Set nil to remove from the dictionary.
//    var id : Int? {
//        get {
//            return self.dic["id"].intValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["id"] = newValue.intValue
//            } else {
//                self.dic.removeValue(forKey: "id")
//            }
//        }
//    }
//    /// This variable key is "user_id". Set nil to remove from the dictionary.
//    var user_id : String? {
//        get {
//            return self.dic["user_id"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["user_id"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "user_id")
//            }
//        }
//    }
//    /// This variable key is "badge_received". Set nil to remove from the dictionary.
//    var badge_received : String? {
//        get {
//            return self.dic["badge_received"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["badge_received"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "badge_received")
//            }
//        }
//    }
//}

//MARK: EventType-Key Dictionary Variable Values
//struct EventTypeDictionary {
//    fileprivate var dic : [String:Any]!
//    /// This variable key is "eventtype_id". Set nil to remove from the dictionary.
//    var id : Int? {
//        get {
//            return self.dic["eventtype_id"] as? Int
//        }
//        set {
//            if newValue != nil {
//                self.dic["eventtype_id"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "eventtype_id")
//            }
//        }
//    }
//    /// This variable key is "type". Set nil to remove from the dictionary.
//    var type : String? {
//        get {
//            return self.dic["type"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["type"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "type")
//            }
//        }
//    }
//    /// This variable key is "iconpic". Set nil to remove from the dictionary.
//    var iconpic : String? {
//        get {
//            return self.dic["iconpic"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["iconpic"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "iconpic")
//            }
//        }
//    }
//}
struct UserDictionary {
    fileprivate var dic : [String:Any]!
    var id : String? {
        get {
            return self.dic["user_id"] as? String
        }
        set {
            if newValue != nil {
                self.dic["user_id"] = newValue!
            } else {
                self.dic.removeValue(forKey: "user_id")
            }
        }
    }
    var remoteid : String? {
        get {
            return self.dic["remoteid"] as? String
        }
        set {
            if newValue != nil {
                self.dic["remoteid"] = newValue!
            } else {
                self.dic.removeValue(forKey: "remoteid")
            }
        }
    }
    var email : String? {
        get {
            return self.dic["email"] as? String
        }
        set {
            if newValue != nil {
                self.dic["email"] = newValue!
            } else {
                self.dic.removeValue(forKey: "email")
            }
        }
    }
    var username : String? {
        get {
            return self.dic["username"] as? String
        }
        set {
            if newValue != nil {
                self.dic["username"] = newValue!.lowercased()
            } else {
                self.dic.removeValue(forKey: "username")
            }
        }
    }
    var passvalidation : String? {
        get {
            return self.dic["passvalidation"] as? String
        }
        set {
            if newValue != nil {
                self.dic["passvalidation"] = newValue!
            } else {
                self.dic.removeValue(forKey: "passvalidation")
            }
        }
    }
    var password : String? {
        get {
            return self.dic["password"] as? String
        }
        set {
            if newValue != nil {
                self.dic["password"] = newValue!
            } else {
                self.dic.removeValue(forKey: "password")
            }
        }
    }
    var source : String? {
        get {
            return self.dic["source"] as? String
        }
        set {
            if newValue != nil {
                self.dic["source"] = newValue!
            } else {
                self.dic.removeValue(forKey: "source")
            }
        }
    }
    var usertype : String? {
        get {
            return self.dic["usertype"] as? String
        }
        set {
            if newValue != nil {
                self.dic["usertype"] = newValue!
            } else {
                self.dic.removeValue(forKey: "usertype")
            }
        }
    }
    var firstname : String? {
        get {
            return self.dic["firstname"].stringValue
        }
        set {
            if newValue.isNotNil {
                self.dic["firstname"] = newValue!
            } else {
                self.dic.removeValue(forKey: "firstname")
            }
        }
    }
    var lastname : String? {
        get {
            return self.dic["lastname"].stringValue
        }
        set {
            if newValue.isNotNil {
                self.dic["lastname"] = newValue!
            } else {
                self.dic.removeValue(forKey: "lastname")
            }
        }
    }
    var phone : String? {
        get {
            return self.dic["phoneNumber"].stringValue
        }
        set {
            if newValue.isNotNil {
                self.dic["phoneNumber"] = newValue!
            } else {
                self.dic.removeValue(forKey: "phoneNumber")
            }
        }
    }
    var emailVerified : Bool? {
        get {
            return self.dic["email_verified"].boolValue ?? false
        }
        set {
            if newValue.isNotNil {
                self.dic["email_verified"] = newValue!
            } else {
                self.dic.removeValue(forKey: "email_verified")
            }
        }
    }
    var phoneVerified : Bool? {
        get {
            return self.dic["phone_verified"].boolValue ?? false
        }
        set {
            if newValue.isNotNil {
                self.dic["phone_verified"] = newValue!
            } else {
                self.dic.removeValue(forKey: "phone_verified")
            }
        }
    }
}


//struct NotificationsDictionary {
//    fileprivate var dic : [String:Any]!
//    /// This variable key is "abbreviation". Set nil to remove from the dictionary.
//    var devicetoken : String? {
//        get {
//            return self.dic["devicetoken"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["devicetoken"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "devicetoken")
//            }
//        }
//    }
//    var timezone : String? {
//        get {
//            return self.dic["timezone"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["timezone"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "timezone")
//            }
//        }
//    }
//    var id : Int? {
//        get {
//            return self.dic["id"].intValue
//        }
//        set {
//            if newValue != nil {
//                self.dic["id"] = newValue.intValue
//            } else {
//                self.dic.removeValue(forKey: "id")
//            }
//        }
//    }
//    var devicetype : String? {
//        get {
//            return self.dic["devicetype"] as? String
//        }
//        set {
//            if newValue != nil {
//                self.dic["devicetype"] = newValue!
//            } else {
//                self.dic.removeValue(forKey: "devicetype")
//            }
//        }
//    }
//}



struct Utility2 {}
extension Utility2 {
    
    /// The function that triggers the specific interaction with a remote server
    /// Parameters:
    /// - method: The HTTP Method enum, i.e. .get, .post
    /// - route: The route required
    /// - body: The JSON formatted sring to sent to the server
    /// Response:
    /// "data" - [String:Any]
    static func makeRequest(
        _ method: HTTPMethod,
        _ url: String,
        body: String = "",
        encoding: String = "JSON",
        bearerToken: String = ""
        ) -> ([String:Any]) {
        
        let curlObject = CURL(url: url)
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Accept: application/json")
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Cache-Control: no-cache")
        curlObject.setOption(CURLOPT_USERAGENT, s: "PerfectAPI2.0")
        
        if !bearerToken.isEmpty {
            curlObject.setOption(CURLOPT_HTTPHEADER, s: "Authorization: Bearer \(bearerToken)")
        }
        
        switch method {
        case .post :
            let byteArray = [UInt8](body.utf8)
            curlObject.setOption(CURLOPT_POST, int: 1)
            curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
            curlObject.setOption(CURLOPT_COPYPOSTFIELDS, v: UnsafeMutablePointer(mutating: byteArray))
            
            if encoding == "form" {
                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/x-www-form-urlencoded")
            } else {
                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/json")
            }
            
        default: //.get :
            curlObject.setOption(CURLOPT_HTTPGET, int: 1)
        }
        
        
        var header = [UInt8]()
        var bodyIn = [UInt8]()
        
        var code = 0
        var data = [String: Any]()
        var raw = [String: Any]()
        
        var perf = curlObject.perform()
        defer { curlObject.close() }
        
        while perf.0 {
            if let h = perf.2 {
                header.append(contentsOf: h)
            }
            if let b = perf.3 {
                bodyIn.append(contentsOf: b)
            }
            perf = curlObject.perform()
        }
        if let h = perf.2 {
            header.append(contentsOf: h)
        }
        if let b = perf.3 {
            bodyIn.append(contentsOf: b)
        }
        let _ = perf.1
        
        // assamble the body from a binary byte array to a string
        let content = String(bytes:bodyIn, encoding:String.Encoding.utf8)
        
        // parse the body data into a json convertible
        do {
//            if (content?.count)! > 0 {
            if (content?.count)! > 0 {
                if (content?.starts(with: "["))! {
//                if (content?.startsWith("["))! {
                    let arr = try content?.jsonDecode() as! [Any]
                    data["response"] = arr
                } else {
                    data = try content?.jsonDecode() as! [String : Any]
                }
            }
            return data
        } catch {
            return [:]
        }
    }
}
