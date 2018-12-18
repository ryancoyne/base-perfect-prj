//
//  Ext.Account.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation
import PerfectLocalAuthentication
import SwiftMoment
import PerfectHTTP

//MARK: - Account Extensions
extension Account {
    
    // Register User
    public static func registerWithEmail(_ session: String,_ u: String, _ e: String, _ ut: AccountType = .provisional, baseURL: String) -> OAuth2ServerError {
        let acc = Account(AccessToken.generate(), u, "", e, ut)
        do {
            try acc.isUnique()
            //            print("passed unique test")
            try acc.create()
            
        } catch {
            print(error)
            return .registerError
        }
        
        var h = "<p><center><a href='http://buckettechnologies.com'><img src='\(baseURL)/assets/images/Logo-Refresh-RGB_vertical.png' alt='Bucket Technologies' height='100' width='100'></a></p>"
        h += "<p><center><h2>Welcome to Bucket!</h2></center></p>"
        h += "<p><center>We’re glad you decided to join us in ridding the world of coins. With Bucket, you can effortlessly save all your change digitally for something useful - such as that next item on your Bucket list (har har).</center></p>"
        h += "<p><center>To finish setting up your new account, please <a href=\"\(baseURL)/verifyAccount/\(acc.passvalidation)\">click here.</a>  If the link does not work, copy and paste the following link into your browser: <br>\(baseURL)/verifyAccount/\(acc.passvalidation)</center></p>"
        h += "<p><center>We’re excited to have you on board and please reach out if you have any questions.</center><br />"
        h += "<center><mailto: hello@buckettechnologies.com></center></p><br />"
        h += "<p><center>Happy Bucketing!</center></p><br />"
        h += "<p><center>The Bucket Team</center></p>"
        
        var t = "Welcome to Bucket!\n\n"
        t += "We’re glad you decided to join us in ridding the world of coins. With Bucket, you can effortlessly save all your change digitally for something useful - such as that next item on your Bucket list (har har).\n\n"
        t += "To finish setting up your new account, please follow this link: \(baseURL)/verifyAccount/\(acc.passvalidation)\n\n"
        t += "We’re excited to have you on board and please reach out if you have any questions.\n"
        t += "hello@buckettechnologies.com\n\n"
        t += "Happy Bucketing!\n\n"
        t += "The Bucket Team"
        
        Utility.sendMail(name: u, address: e, subject: "Welcome to your account", html: h, text: t)
        
        return .noError
    }
    
    func resendForgotPasswordEmail() {
        let h = "<p>To reset your password for your account, please <a href=\"\(AuthenticationVariables.baseURL)/verifyAccount/forgotpassword/\(passreset)\">click here</a></p>"
        Utility.sendMail(name: username, address: email, subject: "Password reset!", html: h, text: "")
    }
    
    func resendRegistrationEmail() {
        
        let baseURL = EnvironmentVariables.sharedInstance.Public_URL_Full_Domain ?? ""
        var h = "<p><center><a href='http://buckettechnologies.com'><img src='\(baseURL)/assets/images/Logo-Refresh-RGB_vertical.png' alt='Bucket Technologies' height='100' width='100'></a></p>"
        h += "<p><center><h2>Welcome to Bucket!</h2></center></p>"
        h += "<p><center>We’re glad you decided to join us in ridding the world of coins. With Bucket, you can effortlessly save all your change digitally for something useful - such as that next item on your Bucket list (har har).</center></p>"
        h += "<p><center>To finish setting up your new account, please <a href=\"\(baseURL)/verifyAccount/\(passvalidation)\">click here.</a>  If the link does not work, copy and paste the following link into your browser: <br>\(baseURL)/verifyAccount/\(passvalidation)</center></p>"
        h += "<p><center>We’re excited to have you on board and please reach out if you have any questions.</center><br />"
        h += "<center><mailto: hello@buckettechnologies.com></center></p><br />"
        h += "<p><center>Happy Bucketing!</center></p><br />"
        h += "<p><center>The Bucket Team</center></p>"
        
        var t = "Welcome to Bucket!\n\n"
        t += "We’re glad you decided to join us in ridding the world of coins. With Bucket, you can effortlessly save all your change digitally for something useful - such as that next item on your Bucket list (har har).\n\n"
        t += "To finish setting up your new account, please follow this link: \(baseURL)/verifyAccount/\(passvalidation)\n\n"
        t += "We’re excited to have you on board and please reach out if you have any questions.\n"
        t += "hello@buckettechnologies.com\n\n"
        t += "Happy Bucketing!\n\n"
        t += "The Bucket Team"
        
        Utility.sendMail(name: username, address: email, subject: "Welcome to your account", html: h, text: t)
        
    }
    
    var lastSeen : Int? {
        get {
            return self.detail["last_seen"].intValue
        }
        set {
            if newValue.isNotNil {
                self.detail["last_seen"] = newValue
            } else {
                self.detail.removeValue(forKey: "last_seen")
            }
        }
    }
    
    var countries : [String]? {
        get {
            if let ret = self.detail["countries"] {
                return ret as? [String]
            }
            return nil
        }
        set {
            if newValue.isNotNil {
                self.detail["countries"] = newValue
            } else {
                self.detail.removeValue(forKey: "countries")
            }
        }
    }
    
    func addCountry(_ newCountry: String)  {
        
        if let _ = self.countries {
            var ctry = self.countries!
            ctry.append(newCountry.lowercased())
            self.countries = ctry
        } else {
            var ctry:[String] = []
            ctry.append(newCountry.lowercased())
            self.countries = ctry
        }
        
    }
    
    func countryExists(_ country: String)->Bool {
        if let ctry = self.detail["countries"] as? [String] {
            if ctry.contains(country.lowercased()) { return true }
        }
        return false
    }
    
    static func userBounce(_ request : HTTPRequest, _ response : HTTPResponse) -> Bool {
        
        // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
        guard request.securityCheck() else { response.badSecurityToken; return true }
        
        // Here we want to check the csrf & the authorization.
        guard let csrf = request.session?.data["csrf"].stringValue, let sendCsrf = request.header(.custom(name: "X-CSRF-Token")) else {
            
            let session = request.session?.token ?? "NO SESSION TOKEN: \(RMServiceClass.getNow())"
            AuditRecordActions.securityFailure(schema: "public",
                                               session_id: session,
                                               user: request.session?.userid,
                                               row_data: nil,
                                               description: "The CSRF token failed to pass the check.")
            
            response.notLoggedIn()
            return true
        }
        guard request.session?.userid.isEmpty == false && csrf == sendCsrf else {
            
            let session = request.session?.token ?? "NO SESSION TOKEN: \(RMServiceClass.getNow())"
            AuditRecordActions.securityFailure(schema: "public",
                                               session_id: session,
                                               user: request.session?.userid,
                                               row_data: nil,
                                               description: "The user is empty and CSRF is not correct.")
            
            response.notLoggedIn()
            return true
            
        }
        // Okay they are logged in.  Lets see when the last time, if they have, used any of the API's:
        let user = Account()
        try? user.get(request.session!.userid)
        
        if let lastSeen = user.lastSeen {
            
            let now = moment()
            let then = Moment(epoch: lastSeen)
            
            let dur = now.intervalSince(then)
            
            if dur.days > 0.5 {
                user.lastSeen = RMServiceClass.getNow()
                try? user.save()
            }
            
        } else {
            user.lastSeen = RMServiceClass.getNow()
            try? user.save()
        }
        
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
    
    static func adminBouce(_ request : HTTPRequest, _ response : HTTPResponse) -> (fails:Bool, user:Account?) {
        
        // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
        guard request.securityCheck() else { response.badSecurityToken; return (true,nil) }
        
        // Here we want to check the csrf & the authorization.
        guard let csrf = request.session?.data["csrf"].stringValue, let sendCsrf = request.header(.custom(name: "X-CSRF-Token")) else {
            
            let session = request.session?.token ?? "NO SESSION TOKEN: \(RMServiceClass.getNow())"
            AuditRecordActions.securityFailure(schema: "public",
                                               session_id: session,
                                               user: request.session?.userid,
                                               row_data: nil,
                                               description: "The CSRF token failed to pass the check.")
            
            response.notLoggedIn()
            return (true, nil)
        }
        guard request.session?.userid.isEmpty == false && csrf == sendCsrf else {
            
            let session = request.session?.token ?? "NO SESSION TOKEN: \(RMServiceClass.getNow())"
            AuditRecordActions.securityFailure(schema: "public",
                                               session_id: session,
                                               user: request.session?.userid,
                                               row_data: nil,
                                               description: "The user is empty and CSRF is not correct.")
            
            response.notLoggedIn()
            return (true, nil)
            
        }
        // Okay they are logged in.  Lets see when the last time, if they have, used any of the API's:
        let user = Account()
        try? user.get(request.session!.userid)
        
        if !user.isAdmin() {
            
            let session = request.session?.token ?? "NO SESSION TOKEN: \(RMServiceClass.getNow())"
            AuditRecordActions.securityFailure(schema: "public",
                                               session_id: session,
                                               user: request.session?.userid,
                                               row_data: nil,
                                               description: "The user is not an admin and was trying to access an admin area.")
            
            return (true, user)
        }
        
        return (false, user)
    }
    
}
