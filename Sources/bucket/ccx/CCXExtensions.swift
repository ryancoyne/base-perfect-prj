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

struct CCXGeographyPoint {
    var latitude    : Double = 0.0
    var longitude   : Double = 0.0
}

extension Optional {
    var isNil : Bool {
        return self == nil
    }
    var isNotNil : Bool {
        return self != nil
    }
    var boolValue : Bool? {
        return self as? Bool
    }
    // Going to use this for the Optional<Any> date fields from our dictionary :)
    var stringValue : String? {
        if self.isNil { return nil }
        switch self {
        case is Int?, is Int:
            return String(self as! Int)
        default:
            return self as? String
        }
    }
    var dicValue : [String:Any]! {
        get {
            return self as? [String:Any] ?? [:]
        }
        set {
            
        }
    }
    var arrayDicValue : [[String:Any]]! {
        return self as? [[String:Any]] ?? [[:]]
    }
    var intValue : Int? {
        if self == nil {
            return nil
        }
        switch self {
        case is Double, is Double?:
            return Int(self as! Double)
        case is Float, is Float?:
            return Int(self as! Float)
        case is Int, is Int?:
            return self as? Int
        default:
            return nil
        }
    }
    var doubleValue : Double? {
        if self == nil {
            return nil
        }
        switch self {
        case is Int, is Int?:
            return Double(exactly: self as! Int)
        case is Float, is Float?:
            return Double(exactly: self as! Float)
        case is Double, is Double?:
            return self as? Double
        case is String, is String?:
            return Double(self as! String)
        default:
            return nil
        }
    }
    var floatValue : Float? {
        return self as? Float
    }
}
extension Optional where Wrapped == String {
    var isEmptyOrNil: Bool {
        if self == "nil" {
            return true
        } else {
            return (self ?? "").isEmpty
        }
    }
}
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

extension Float {
    var toMeters : Float {
        return self * 1609.34
    }
}
extension Double {
    var toMeters : Double {
        return self * 1609.34
    }
}

extension HTTPResponse {
    func notLoggedIn(_ message : String?=nil) {
        var returnD = ["errorCode" : "Unauthorized"]
        if message != nil {
            returnD["message"] = message
        }
        try! self.setBody(json: returnD)
                     .completed(status: .unauthorized)
    }
    func caughtError(_ error : Error) {
        try! self.setBody(json: ["error": error.localizedDescription])
            .completed(status: .unauthorized)
    }
    var alreadyLoggedIn : Void {
        try! self.setBody(json: ["error" : "You are already logged in."])
                     .completed(status: .ok)
    }
}

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
extension PostgresStORM {
    
    /**
     Saves a record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    @discardableResult
    func saveWithCustomType(_ user: String? = nil, copyOver : Bool = false) throws -> [StORMRow] {
        
        // act accordingly if this is an add or an update
        do {
            if copyOver {
                return try insertWithCustomTypes()
            } else if keyIsEmpty() {
                return try addWithCustomTypes(user)
            } else {
                return try updateWithCustomType(user)
            }
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            throw StORMError.error("\(error)")
        }
    }
    
    /**
     Deletes a record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    @discardableResult
    func softDeleteWithCustomType(_ user: String? = nil) throws -> [StORMRow] {

        // get the key (id)
        let (idcolumn, _) = firstAsKey()

        var idnumber: String = ""
        
        let thedata = self.asData()

        for i in thedata.enumerated() {
        
            if i.element.0 == idcolumn {
                let type = type(of: i.element.1)
                switch type {
                case is Int.Type, is Int?.Type:
                    idnumber = String(describing: i.element.1 as! Int)
                case is String.Type, is String?.Type:
                    idnumber = "'\(String(describing: i.element.1 as! String))'"
                default:
                    break
                }
            }
        }

        var deleteuser = ""
        if user == nil {
            deleteuser = CCXDefaultUserValues.user_admin
        } else {
            deleteuser = user!
        }
        
        // build the sql
        var str = "UPDATE \(self.table()) "
        str.append("SET \"deleted\"  = \(String(describing: CCXServiceClass.sharedInstance.getNow())), \"deletedby\"  = '\(deleteuser)', ")
        str.append("    \"modified\" = \(String(describing: CCXServiceClass.sharedInstance.getNow())), \"modifiedby\" = '\(deleteuser)' ")
        str.append("WHERE \"\(idcolumn.lowercased())\" = \(idnumber)")
 
        do {
            return try self.execRows(str, params: [])
        } catch {
            LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
    }

    /**
     Deletes a record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    @discardableResult
    func softUnDeleteWithCustomType(_ user: String? = nil) throws -> [StORMRow] {
        
        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        var idnumber: String = ""
        
        let thedata = self.asData()
        
        for i in thedata.enumerated() {
            
            if i.element.0 == idcolumn {
                let type = type(of: i.element.1)
                switch type {
                case is Int.Type, is Int?.Type:
                    idnumber = String(describing: i.element.1 as! Int)
                case is String.Type, is String?.Type:
                    idnumber = "'\(String(describing: i.element.1 as! String))'"
                default:
                    break
                }
            }
        }
        
        var deleteuser = ""
        if user == nil {
            deleteuser = CCXDefaultUserValues.user_server
        } else {
            deleteuser = user!
        }
        
        // build the sql
        var str = "UPDATE \(self.table()) "
        str.append("SET \"deleted\"  = 0, \"deletedby\" = NULL, ")
        str.append("    \"modified\" = \(String(describing: CCXServiceClass.sharedInstance.getNow())), \"modifiedby\" = '\(deleteuser)' ")
        str.append("WHERE \"\(idcolumn.lowercased())\" = \(idnumber)")
        
        do {
            return try self.execRows(str, params: [])
        } catch {
            LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }

    }

    private func insertWithCustomTypes() throws -> [StORMRow] {
        
        // get the variables with their values in the dictionary
        let thedata = asData()
        
        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        // remove the id key
        var keys = [String]()
        var vals = [String]()
        for i in thedata {
            
            if (String(describing: i.1) != "nil") {
                let c = type(of: i.1)
                switch c {
                case is String.Type, is String?.Type:
                    let app = "'\((i.1 as! String).sanitized)'"
                    keys.append(i.0)
                    vals.append(app)
                case is CCXGeographyPoint.Type:
                    if let point = i.1 as? CCXGeographyPoint, point.latitude != 0, point.longitude != 0 {
                        let gisstring = "ST_SetSRID(ST_MakePoint(\(point.longitude),\(point.latitude)),4326)"
                        keys.append(i.0)
                        vals.append(gisstring)
                    } else { continue }
                case is Int.Type, is Double.Type, is Float.Type, is Bool.Type:
                    let value = String(describing: i.1)
                    keys.append(i.0)
                    vals.append(value)
                    break
                // OPTIONAL VALUES:
                case is Int?.Type:
                    // Make sure the according type is casted to our string describing wont include the optional part:
                    let value = String(describing: i.1 as! Int)
                    keys.append(i.0)
                    vals.append(value)
                    break
                case is Float?.Type:
                    let value = String(describing: i.1 as! Float)
                    keys.append(i.0)
                    vals.append(value)
                    break
                case is Bool?.Type:
                    let value = String(describing: i.1 as! Bool)
                    keys.append(i.0)
                    vals.append(value)
                case is Double?.Type:
                    let value = String(describing: i.1 as! Double)
                    keys.append(i.0)
                    vals.append(value)
                    break
                    // We will default here.  We will need to wrap other types here in the case switch.
                    //                case is String?.Type:
                    //                    // Its a string, lets cast it
                    //                    let stringValue = "'\(i.1 as! String)'"
                    //                    keys.append(i.0)
                //                    vals.append(stringValue)
                case is CCXGeographyPoint?.Type:
                    let geographypoint = i.1 as! CCXGeographyPoint
                    let gisstring = "ST_SetSRID(ST_MakePoint(\(geographypoint.longitude),\(geographypoint.latitude)),4326)"
                    keys.append(i.0)
                    vals.append(gisstring)
                default:
                    print("[CCXStORMExtensions] [updateWithGIS] [\(CCXServiceClass.sharedInstance.getNow().dateString)]  WARNING: Need to add the following type to update/add/saveWithCustomType: \(c)")
                    continue
                }
            }
        }
        
        var substString = [String]()
        for i in 1..<vals.count {
            substString.append("$\(i)")
        }
        
        let colsjoined = "\"" + keys.joined(separator: "\",\"") + "\""
        
        let str = "INSERT INTO \(self.table()) (\(colsjoined.lowercased())) VALUES(\(vals.joined(separator: ","))) RETURNING \"\(idcolumn.lowercased())\""
        
        print(str)
        
        do {
            //            let response = try sql(str, params: [])
            //            let response = try exec(str, params: vals)
            //            return parseRows(response)[0].data[idcolumn.lowercased()]!
            return try self.execRows(str, params: [])
            
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
    }
    
    /**
     Adds a new record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    private func addWithCustomTypes(_ user: String? = nil) throws -> [StORMRow] {
        
        // get the variables with their values in the dictionary
        let thedata = asData()

        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        // remove the id key
        var keys = [String]()
        var vals = [String]()
        for i in thedata {
            
            // first lets see if the field is 'created' or 'createdby'
            if (i.0 == "created") {
                let now = CCXServiceClass.sharedInstance.getNow()
                keys.append(i.0)
                vals.append(String(describing: now))
                switch self {
                case is CodeTransaction:
                    (self as! CodeTransaction).created = now
                case is CodeTransactionHistory:
                    (self as! CodeTransactionHistory).created = now
                default:
                    print("[CCXExtensions INFO] updateWithCustomType  TYPE \(self) NOT IMPLEMENTED to update model.")
                }
            } else if (i.0 == "createdby") {
                let theUser = user ?? CCXDefaultUserValues.user_server
                keys.append(i.0)
                vals.append("'\(theUser)'")
                switch self {
                case is CodeTransaction:
                    (self as! CodeTransaction).createdby = theUser
                case is CodeTransactionHistory:
                    (self as! CodeTransactionHistory).createdby = theUser
                default:
                    print("[CCXExtensions INFO] updateWithCustomType  TYPE \(self) NOT IMPLEMENTED to update model.")
                }
            } else if (i.0 != idcolumn) && (String(describing: i.1) != "nil") {
                
                let c = type(of: i.1)
                switch c {
                case is String.Type, is String?.Type:
                    let app = "'\((i.1 as! String).sanitized)'"
                    keys.append(i.0)
                    vals.append(app)
                case is CCXGeographyPoint.Type:
                    if let point = i.1 as? CCXGeographyPoint, point.latitude != 0, point.longitude != 0 {
                        let gisstring = "ST_SetSRID(ST_MakePoint(\(point.longitude),\(point.latitude)),4326)"
                        keys.append(i.0)
                        vals.append(gisstring)
                    } else { continue }
                case is Int.Type, is Double.Type, is Float.Type, is Bool.Type:
                    let value = String(describing: i.1)
                    keys.append(i.0)
                    vals.append(value)
                    break
                // OPTIONAL VALUES:
                case is Int?.Type:
                    // Make sure the according type is casted to our string describing wont include the optional part:
                    let value = String(describing: i.1 as! Int)
                    keys.append(i.0)
                    vals.append(value)
                    break
                case is Float?.Type:
                    let value = String(describing: i.1 as! Float)
                    keys.append(i.0)
                    vals.append(value)
                    break
                case is Bool?.Type:
                    let value = String(describing: i.1 as! Bool)
                    keys.append(i.0)
                    vals.append(value)
                case is Double?.Type:
                    let value = String(describing: i.1 as! Double)
                    keys.append(i.0)
                    vals.append(value)
                    break
                    // We will default here.  We will need to wrap other types here in the case switch.
                    //                case is String?.Type:
                    //                    // Its a string, lets cast it
                    //                    let stringValue = "'\(i.1 as! String)'"
                    //                    keys.append(i.0)
                //                    vals.append(stringValue)
                case is CCXGeographyPoint?.Type:
                    let geographypoint = i.1 as! CCXGeographyPoint
                    let gisstring = "ST_SetSRID(ST_MakePoint(\(geographypoint.longitude),\(geographypoint.latitude)),4326)"
                    keys.append(i.0)
                    vals.append(gisstring)
                default:
                    print("[CCXStORMExtensions] [updateWithGIS] [\(CCXServiceClass.sharedInstance.getNow().dateString)]  WARNING: Need to add the following type to update/add/saveWithCustomType: \(c)")
                    continue
                }
            }
        }
        
        var substString = [String]()
        for i in 1..<vals.count {
            substString.append("$\(i)")
        }
        
        let colsjoined = "\"" + keys.joined(separator: "\",\"") + "\""
        
        let str = "INSERT INTO \(self.table()) (\(colsjoined.lowercased())) VALUES(\(vals.joined(separator: ","))) RETURNING \"\(idcolumn.lowercased())\""
        
        print(str)
        
        do {
            //            let response = try sql(str, params: [])
            //            let response = try exec(str, params: vals)
            //            return parseRows(response)[0].data[idcolumn.lowercased()]!
            return try self.execRows(str, params: [])
            
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
    }

    /**
     Updates a record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    private func updateWithCustomType(_ user: String? = nil) throws -> [StORMRow] {
        
        // get the variables with their values in the dictionary
        let thedata = self.asData()
        
        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        var idnumber: String = ""
        
        var set:String = ""
        
        for i in thedata.enumerated() {
            
            // We dont need to continue if they value is nil:
            let value = String(describing: i.element.1)
            
            // Make sure we set the idnumber correctly:
            if i.element.0 == idcolumn {
                switch i.element.1 {
                case is Int:
                    idnumber = String(describing: i.element.1 as! Int)
                case is String:
                    idnumber = "'\(String(describing: i.element.1 as! String))'"
                default:
                    break
                }
            }
            
            if (i.element.0 == "modified") {
                let now = CCXServiceClass.sharedInstance.getNow()
                let value = String(describing: now)
                set.append(" \(i.element.0) = \(value),")
                switch self {
                case is CodeTransaction:
                    (self as! CodeTransaction).modified = now
                case is CodeTransactionHistory:
                    (self as! CodeTransactionHistory).modified = now
                default:
                    print("[CCXExtensions INFO] updateWithCustomType  TYPE \(self) NOT IMPLEMENTED to update model.")
                }
            } else if (i.element.0 == "modifiedby") {
                let theUser = user ?? CCXDefaultUserValues.user_server
                set.append(" \(i.element.0) = '\(theUser)',")
                switch self {
                case is CodeTransaction:
                    (self as! CodeTransaction).modifiedby = theUser
                case is CodeTransactionHistory:
                    (self as! CodeTransactionHistory).modifiedby = theUser
                default:
                    print("[CCXExtensions INFO] updateWithCustomType  TYPE \(self) NOT IMPLEMENTED to update model.")
                }
            } else if (i.element.0 != idcolumn) && value != "nil" {
                
                // we are doing this to remove the quotes around the GIS functions (it will not work)
                let c = type(of: i.element.1)
                // Right now we are assuming no optionals, so we will add in each key & then append the next value next.  We will skip that if its optional & nil.
                switch c {
                // Deal with the string type -- we need to wrap it in quotes:
                case is String.Type, is String?.Type:
                    // The sanitized extension variable replaces any quotes with a double quote (via SQL docs):
                    let stringValue = (i.element.1 as! String).sanitized
                    set.append(" \(i.element.0) = '\(stringValue)',")
                // add the GIS stuff
                case is CCXGeographyPoint.Type:
                    if let point = i.element.1 as? CCXGeographyPoint, point.latitude != 0, point.longitude != 0 {
                        let gisstring = "ST_SetSRID(ST_MakePoint(\(point.longitude),\(point.latitude)),4326)"
                        set.append(" \(i.element.0) = \(gisstring),")
                    }
                // I think we can deal with the following types in the following way:
                case is Int.Type, is Double.Type, is Float.Type:
                    let value = String(describing: i.element.1)
                    set.append(" \(i.element.0) = \(value),")
                    break
                // OPTIONAL VALUES:
                case is Int?.Type:
                    // Make sure the according type is casted to our string describing wont include the optional part:
                    let value = String(describing: i.element.1 as! Int)
                    set.append(" \(i.element.0) = \(value),")
                    break
                case is Float?.Type:
                    let value = String(describing: i.element.1 as! Float)
                    set.append(" \(i.element.0) = \(value),")
                    break
                case is Bool?.Type, is Bool.Type:
                    let boolValue = String(describing: i.element.1 as! Bool)
                    set.append(" \(i.element.0) = \(boolValue),")
                case is Double?.Type:
                    let value = String(describing: i.element.1 as! Double)
                    set.append(" \(i.element.0) = \(value),")
                    break
                    // We will default here.  We will need to wrap other types here in the case switch.
                    //                case is String?.Type:
                    //                    // Its a string, lets cast it
                    //                    let stringValue = "'\((i.element.1 as! String).sanitized)'"
                //                    set.append(" \(i.element.0) = \(stringValue),")
                case is CCXGeographyPoint?.Type:
                    let geographypoint = i.element.1 as! CCXGeographyPoint
                    let gisstring = "ST_SetSRID(ST_MakePoint(\(geographypoint.longitude),\(geographypoint.latitude)),4326)"
                    set.append(" \(i.element.0) = \(gisstring),")
                default:
                    continue
                }
            }
        }
        
        // Remove out the last comma after looping:
        if set.count > 0 {
            set.removeLast()
        }
        
        // build the sql
        let str = "UPDATE \(self.table()) SET \(set) WHERE \"\(idcolumn.lowercased())\" = \(idnumber)"
        
        do {
            //            let response = try sql(str, params: [])
            //            return parseRows(response)[0].data[idcolumn.lowercased()]!
            return try self.execRows(str, params: [])
        } catch {
            LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
        
    }
    
    /**
     Updates a single record with GIS coordinates in a geography type field.
     - parameter record_id: The id of the record you would like to update
     - parameter locationField: This is the geography type field in the database used as the search criteria
     - parameter longitude: The longitude of the reference point for the search
     - parameter latitude: The latitude of the reference point for the search
     - Returns: An array of StORMRow objects with the resulting dataset
     */
    private func updateLocationGIS(record_id: Int, locationField: String, longitude: Double, latitude: Double) throws -> [StORMRow] {
        
        let parms: [String] = [String(record_id), String(longitude), String(latitude)]
        var sqlstatement = "UPDATE \(self.table()) "
        sqlstatement.append("SET \(locationField) = ")
        sqlstatement.append("ST_SetSRID(ST_MakePoint($2, $3), 4326) ")
        sqlstatement.append("WHERE id = $1")
        
        return try self.execRows(sqlstatement, params: parms)
        
    }
    
    /**
     Allows custom SQL statements to integrate with the GIS statements.
     - parameter sql: The SQL statement to run with replacement variables
     - Use {{GISFIELDS}} to insert the postgis location field selection as latitide and longitude double fields.
     - Use the {{GISWHERE}} to insert the section of the WHERE clause to limit according to the selection criteria
     - parameter locationField: This is the geography type field in the database used as the search criteria
     - parameter longitude: The longitude of the reference point for the search
     - parameter latitude: The latitude of the reference point for the search
     - parameter distance: The comparison distance in miles
     - Returns: An array of StORMRow objects with the resulting dataset
     */
    func getLocationGISsql(sql: String, locationField: String, longitude: Double, latitude: Double, distance: Double) throws -> [StORMRow] {
        
        var sqlstatement = sql
        //        var gisfields = " "
        //        var giswhere  = " "
        
        // add the location based fields to return lat and lon
        // (note the space in the definition of the field - this assures
        //  the space between characters for the replacement)
        //        gisfields.append("ST_X(\(locationField)::geometry) as longitude, ")
        //        gisfields.append("ST_Y(\(locationField)::geometry) as latitude, ")
        
        // add the localization to the statement
        // (note the space in the definition of the field - this assures
        //  the space between characters for the replacement)
        //        giswhere.append("ST_DWithin(\(locationField), ST_SetSRID(ST_Point(\(longitude), \(latitude)), 4326), \(distance)) ")
        
        let gisfields = CCXServiceClass.sharedInstance.getGISFields(locationField: locationField)
        let giswhere  = CCXServiceClass.sharedInstance.getGISWhere(locationField: locationField, longitude: longitude, latitude: latitude, distance: distance)
        
        sqlstatement = sqlstatement.replacingOccurrences(of: "{{GISFIELDS}}", with: gisfields)
        sqlstatement = sqlstatement.replacingOccurrences(of: "{{GISWHERE}}", with: giswhere)
        
        print("Built Location SQL: \(sqlstatement)")
        
        return try self.execRows(sqlstatement, params: [])
        
    }
    
    
    /**
     Selects records based on their relative position from a specific point.
     - parameter longitude: The longitude of the reference point for the search
     - parameter latitude: The latitude of the reference point for the search
     - parameter locationField: This is the geography type field in the database used as the search criteria
     - parameter distance: The comparison distance in miles
     - parameter fields: An array of the names of the fields you would like returned in addition to the longitude and latitude fields
     - Returns: An array of StORMRow objects with the resulting dataset
     */
    func getLocationGIS(longitude: Double, latitude: Double, locationField: String, fields: [String], distance: Double) throws -> [StORMRow] {
        
        var sqlstatement = "SELECT "
        
        // show the fields that are returned (NO *)
        for field in fields {
            sqlstatement.append("\(field), ")
        }
        
        // add the location based fields to return lat and lon
        sqlstatement.append("ST_X(\(locationField)::geometry) as longitude, ")
        sqlstatement.append("ST_Y(\(locationField)::geometry) as latitude ")
        
        // completing the SQL
        sqlstatement.append("FROM \(self.table()) ")
        
        // add the localization to the statement
        sqlstatement.append("WHERE ST_DWithin(\(locationField), ST_SetSRID(ST_Point($1, $2), 4326), $3)")
        
        print("Location SQL: \(sqlstatement)")
        
        let parms: [String] = [String(longitude), String(latitude), String(distance)]
        
        return try self.execRows(sqlstatement, params: parms)
        
    }
    
    // Internal function which executes statements, with parameter binding
    // Returns a processed row set
    @discardableResult
    func execRows(_ statement: String, params: [String]) throws -> [StORMRow] {
        let thisConnection = PostgresConnect(
            host:        PostgresConnector.host,
            username:    PostgresConnector.username,
            password:    PostgresConnector.password,
            database:    PostgresConnector.database,
            port:        PostgresConnector.port
        )
        
        thisConnection.open()
        thisConnection.statement = statement
        
        printDebug(statement, params)
        let result = thisConnection.server.exec(statement: statement, params: params)
        
        // set exec message
        errorMsg = thisConnection.server.errorMessage().trimmingCharacters(in: .whitespacesAndNewlines)
        if StORMdebug { LogFile.info("Error msg: \(errorMsg)", logFile: "./StORMlog.txt") }
        if isError() {
            thisConnection.server.close()
            throw StORMError.error(errorMsg)
        }
        
        let resultRows = parseRows(result)
        //        result.clear()
        thisConnection.server.close()
        return resultRows
    }
    
    private func printDebug(_ statement: String, _ params: [String]) {
        if StORMdebug { LogFile.debug("StORM Debug: \(statement) : \(params.joined(separator: ", "))", logFile: "./StORMlog.txt") }
    }
    
    func isError() -> Bool {
        if errorMsg.contains(string: "ERROR") {
            print(errorMsg)
            return true
        }
        return false
    }
}

//MARK: - String Extensions:
extension String {
    var sanitized : String {
        return self.replacingOccurrences(of: "'", with: "''")
    }
    
    var ourPasswordHash : String? {
        guard let hexBytes = self.digest(.sha256), let validate = hexBytes.encode(.hex), let theHashedPassword = String(validatingUTF8: validate)  else { return nil }
        return theHashedPassword
    }
    
    func chompLeft(_ prefix: String) -> String {
        if let prefixRange = range(of: prefix) {
            if prefixRange.upperBound >= endIndex {
                return String(self[startIndex..<prefixRange.lowerBound])
            } else {
                return String(self[prefixRange.upperBound..<endIndex])
            }
        }
        return self
    }
    
    func chompRight(_ suffix: String) -> String {
        if let suffixRange = range(of: suffix, options: .backwards) {
            if suffixRange.upperBound >= endIndex {
                return String(self[startIndex..<suffixRange.lowerBound])
            } else {
                return String(self[suffixRange.upperBound..<endIndex])
            }
        }
        return self
    }
    
    func toBool() -> Bool? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if Int(trimmed) != 0 {
            return true
        }
        switch trimmed {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return false
        }
    }

    
    
    
    
    
    
}
//MARK: Integer Extensions:
extension Int {
    var dateString : String {
        return CCXServiceClass.sharedInstance.dateStampFormatter.string(from: Date(timeIntervalSince1970: Double(exactly: self)!))
    }
}
//MARK: - Account Extensions
extension Account {
    
    static func userBouce(_ request : HTTPRequest, _ response : HTTPResponse) -> Bool {
        guard request.session?.userid.isEmpty == false else { response.notLoggedIn(); return true }
        return false
    }
    
    struct exists {
        struct with {
            static func username(_ value : String) -> Bool {
                let userCheck = Account()
                try? userCheck.find(["username":value.lowercased()])
                return userCheck.id.isEmpty
            }
            static func email(_ value : String) -> Bool {
                let userCheck = Account()
                try? userCheck.find(["email":value])
                return userCheck.id.isEmpty
            }
        }
    }
}

