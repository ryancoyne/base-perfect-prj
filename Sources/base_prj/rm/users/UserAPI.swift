//
//  UserAPI.swift
//
//  Created by Ryan Coyne on 10/30/17.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession
//import SwiftRandom
import PerfectCrypto
import SwiftGD
import PerfectCURL
import cURL

//MARK: - User API
/// This UserAPI structure supports all the normal endpoints for a user based login application.
struct UserAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [["method":"post",   "uri":"/api/v1/login", "handler": login],
                    ["method":"get",    "uri":"/api/v1/logout", "handler":logout],
                    ["method":"post",   "uri":"/api/v1/login/oauth", "handler":oauth.login],
                    ["method":"post",   "uri":"/api/v1/register", "handler":register],
                    ["method":"post",   "uri":"/api/v1/forgotpassword", "handler":forgotPassword],
                    ["method":"post",   "uri":"/api/v1/user/update", "handler":updateProfile],
                    ["method":"post",   "uri":"/api/v1/user/upload", "handler":uploadPicture],
                    ["method":"post",   "uri":"/api/v1/changepassword", "handler":changePassword],
                    ["method":"post",   "uri":"/api/v1/resendEmail", "handler":resendEmail]
//                    ["method":"post",   "uri":"/api/v1/check", "handler":checkEmailOrUsername]
            ]
        }
        //MARK: - Resend Email
        public static func resendEmail(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                // Okay, we are resending an email, check the email:
                do {
                    let json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    guard let resendType = request.resendType else { return try! response.setBody(json: ["errorCode":"InvalidType", "message":"Please check the resendType header."]).completed(status: .custom(code: 417, message: "Type Required")) }
                    guard let email = json["email"].stringValue else { return try! response.setBody(json: ["errorCode":"InvalidCredentials", "message":"You need to give us an email to resend"]).completed(status: .custom(code: 413, message: "Email Required")) }
                    
                    let accoun = Account()
                    try? accoun.find(["email":email])
                    
                    guard !accoun.id.isEmpty else { return }
                    
                    switch resendType {
                    case .forgotPassword:
                    // Resend the forgot password email:
                        guard !accoun.passreset.isEmpty else { return try! response.setBody(json: ["errorCode":"Unavailable", "message":"You currently have no pending forgot password email."]).completed(status: .custom(code: 415, message: "Unavailable")) }
                        try? response.setBody(json: ["message":"We sent the forgot password email again!"]).completed(status: .ok)
                        accoun.resendForgotPasswordEmail()
                        return
                    case .registration:
                    // Resend the registration email:
                        guard !accoun.passvalidation.isEmpty else { return try! response.setBody(json: ["errorCode":"Unavailable", "message":"You currently have no pending registration email."]).completed(status: .custom(code: 415, message: "Unavailable")) }
                        try? response.setBody(json: ["message":"We sent the registration email again!"]).completed(status: .ok)
                        accoun.resendRegistrationEmail()
                        return
                    }
        
                } catch RMAPIError.unparceableJSON(let string) {
                    return response.invalidRequest(string)
                } catch {
                    return response.caughtError(error)
                }
            }
        }
        
        //MARK: - Logout
        public static func logout(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                if request.session?.userid.isEmpty == false {
                    
                    AuditRecordActions.userLogout(schema: nil,
                                                  session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                  user: request.session?.userid,
                                                  row_data: nil,
                                                  changed_fields: nil,
                                                  description: nil,
                                                  changedby: request.session?.userid)
                    
                    PostgresSessions().destroy(request, response)
                    request.session = PerfectSession()
                    response.request.session = PerfectSession()
                    
                    // We successfully logged out:
                    _ = try? response.setBody(json: ["message":"Logout was successful"])
                                                 .setHeader(.contentType, value: "application/json")
                                                 .completed(status: .ok)
                    return
                    
                } else if let _ = request.session?.token {
                    
                    PostgresSessions().destroy(request, response)
                    request.session = PerfectSession()
                    response.request.session = PerfectSession()
                    
                    _ = try? response.setBody(json: ["errorCode":"NoAuth", "message":"You need to be logged in to logout."])
                                                 .setHeader(.contentType, value: "application/json")
                                                 .completed(status: .forbidden)
                    return
                    
                } else {
                    
                    _ = try? response.setBody(json: ["errorCode":"NoUserOrToken", "message":"You need to be logged in to logout."])
                                                 .setHeader(.contentType, value: "application/json")
                                                 .completed(status: .forbidden)
                    return
                    
                }
            }
        }
        //MARK: - Login: Username/Password OR Email/Password
        public static func login(_ data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                // If they are already logged in, just send back their information:
                if let s = request.session, !s.userid.isEmpty, s.data["csrf"].stringValue == request.header(.custom(name: "X-CSRF-Token")) {
                    
                    AuditRecordActions.userLogin(schema: nil,
                                                  session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                  user: request.session?.userid,
                                                  row_data: nil,
                                                  changed_fields: nil,
                                                  description: "The user was already logged in and tried to login again.",
                                                  changedby: request.session?.userid)
                    
                    response.alreadyAuthenticated(request)
                    return
                }
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }
                
                do {
                    
                    let json = try request.postBodyJSON()!
                    if let password = json["password"].stringValue, let username = json["username"].stringValue?.lowercased() {
                        
                        if let acc = try? Account.login(username, password) {
                            
                            AuditRecordActions.userLogin(schema: nil,
                                                         session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                         user: request.session?.userid,
                                                         row_data: nil,
                                                         changed_fields: nil,
                                                         description: "The user logged in.",
                                                         changedby: acc.id)

                            request.session?.userid = acc.id
                            try? response.setBody(json: acc.asDictionary)
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .ok)
                            return
                            
                        } else {
                            // Failed on login

                            AuditRecordActions.userLogin(schema: nil,
                                                         session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                         user: request.session?.userid,
                                                         row_data: nil,
                                                         changed_fields: nil,
                                                         description: "The user \(username) tried to log in.  FAILURE",
                                                         changedby: nil)

                            response.invalidCredentials
                            return
                            
                        }
                    } else if let email = json["email"].stringValue, let password = json["password"].stringValue {
                        // Okay they are attempting an email/password login:
                        
                        if let acc = try? Account.loginWithEmail(email, password) {

                            AuditRecordActions.userLogin(schema: nil,
                                                         session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                         user: request.session?.userid,
                                                         row_data: nil,
                                                         changed_fields: nil,
                                                         description: "The user logged in.",
                                                         changedby: acc.id)

                            request.session?.userid = acc.id
                            
                            try? response.setBody(json: acc.asDictionary)
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .ok)
                            return
                            
                        } else {
                            // Failed on login
                            
                            AuditRecordActions.userLogin(schema: nil,
                                                         session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                         user: request.session?.userid,
                                                         row_data: nil,
                                                         changed_fields: nil,
                                                         description: "The user \(email) tried to log in.  FAILURE",
                                changedby: nil)

                            response.invalidCredentials
                            return
                        }
                    } else {
                        try? response.setBody(json: ["errorCode":"RequiredJSON","message":"Please send in 'email' || 'username' along with 'password'.'"])
                            .setHeader(.contentType, value: "application/json; charset=UTF-8")
                            .completed(status: .forbidden)
                        return
                        
                    }
                } catch RMAPIError.unparceableJSON(let jsonString) {
                    return response.invalidRequest(jsonString)
                } catch {
                    response.caughtError(error)
                    return
                }
            }
        }
        //MARK: - Register:
        public static func register(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                do {
                    
                    let json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    // Okay we have json!
                    guard let email = json["email"].stringValue else { return try! response.setBody(json: ["errorCode":"RequiredJSON","message":"You need to send at least an email to register."]).completed(status: .badRequest) }
                    let username = json["username"].stringValue ?? ""
                    
                    let err = Account.registerWithEmail(request.session?.token ?? "NO SESSION TOKEN",username.lowercased(), email, .provisional, baseURL: EnvironmentVariables.sharedInstance.Public_URL_Full_Domain ?? "")
                    
                    if err != .noError {
                        
                        AuditRecordActions.userRegistration(schema: nil,
                                                            session_id: request.session?.token ?? "NO SESSION TOKEN" ,
                                                            user: nil,
                                                            row_data: ["email":email, "username": username],
                                                            changed_fields: nil,
                                                            description: "Registration failed. Email address already in use.",
                                                            changedby: nil)
                        
                        try? response.setBody(json: ["errorCode":"RegistrationIssue", "message":"The email attempting to be registered already exists."])
                            .completed(status: .custom(code: 409, message: "Email Exists"))
                        return
                        
                    } else {
                        
                        // success!
                        // pull the user
                        let thenewuser = Account()
                        try? thenewuser.find(["email": email])
                        
//                        let userret:[String:Any] = UserAPI.UserSuccessfullyCreated(thenewuser)
                        
                        var retDict:[String:Any] = [:]
                        retDict["message"] = "Check your email for a verification email.  It contains instructions to complete your signup!"
                        
//                        // add in the return values for the user connections
//                        for (key,value) in userret {
//                            retDict[key] = value
//                        }
                        
                        AuditRecordActions.userRegistration(schema: nil,
                                                            session_id: request.session?.token ?? "NO SESSION TOKEN" ,
                                                            user: thenewuser.id,
                                                            row_data: ["email":email, "username": username],
                                                            changed_fields: nil,
                                                            description: "Registration successful. New user needs to verify the registration.",
                                                            changedby: nil)

                        _ = try response.setBody(json: retDict)
                        response.completed(status: .ok)
                        return
                        
                    }
                    
                } catch RMAPIError.unparceableJSON(let jsonStr) {
                    return response.invalidRequest(jsonStr)
                } catch {
                    return response.caughtError(error)
                }
                
            }
        }
        //MARK: - Change Password
        public static func changePassword(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                let i = request.session!.userid
                let acc = Account()
                do {
                    try acc.get(i)
                        
                    // start chpwd
                    if let postBody = request.postBodyString, !postBody.isEmpty {
                        do {
                            let postBodyJSON = try postBody.jsonDecode() as? [String: String] ?? [String: String]()
                            if let password = postBodyJSON["password"], !password.isEmpty {
                                acc.makePassword(password)
                                try acc.save()
                                
                                AuditRecordActions.userChange(schema: nil,
                                                              session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                              user: acc.id,
                                                              row_data: nil,
                                                              changed_fields: ["password":"change"],
                                                              description: "User changed their password successfully",
                                                              changedby: acc.id)
                                
                                _ = try response.setBody(json: ["result":"success", "message":"Congratulations!  You are amazing!  You changed your password!"])
                                response.completed(status: .ok)
                                return
                                
                            } else {

                                AuditRecordActions.userChange(schema: nil,
                                                              session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                              user: acc.id,
                                                              row_data: nil,
                                                              changed_fields: ["password":"change"],
                                                              description: "User tried their password - an incorrect password was supplied.",
                                                              changedby: acc.id)

                                LocalAuthHandlers.error(request, response, error: "Please supply a vaid password",
                                                        code: .badRequest)
                                return
                                
                            }
                        } catch {
                            LocalAuthHandlers.error(request, response, error: "Invalid JSON", code: .badRequest)
                            return
                            
                        }
                    } else {
                        LocalAuthHandlers.error(request, response, error: "Change Password Error: Insufficient Data", code: .badRequest)
                        return
                        
                    }
                    // end chpwd
                } catch {
                    LocalAuthHandlers.error(request, response, error: "AccountError", code: .badRequest)
                    return
                    
                }
            }
        }
        
        //MARK: Checing for the existence of username or password
        static func checkEmailOrUsername(data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                let json = try? request.postBodyString?.jsonDecode() as? [String:Any]
                
                if json.isNil {
                    try? response.setBody(json: ["error":"No post body params"])
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .badRequest)
                    return
                    
                } else {
                    
                    var responseDic:[String:Any] = [:]
                    if let email = json??["email"].stringValue {
                        responseDic["emailAvailable"] = Account.exists.with.email(email)
                    }
                    
                    if let username = json??["username"].stringValue?.lowercased() {
                        responseDic["usernameAvailable"] = Account.exists.with.username(username)
                    }
                    
                    AuditRecordActions.userChange(schema: nil,
                                                  session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                  user: request.session?.userid ?? "NO USER",
                                                  row_data: ["username": json??["username"].stringValue?.lowercased() ?? "NO USERNAME",
                                                             "email": json??["email"].stringValue ?? "NO EMAIL"],
                                                  changed_fields: nil,
                                                  description: "User checked to see if email and password were available",
                                                  changedby: nil)
                    
                    
                    try? response.setBody(json: responseDic)
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)
                    return
                    
                }
                
            }
        }


        //MARK: - Oauth Structure:
        struct oauth {
            
            static let facebook : FacebookOAuth = FacebookOAuth()
            static let google : GoogleOAuth = GoogleOAuth()
            static let twitter : TwitterOAuth = TwitterOAuth()
            
            public static func createOrLoginUser(_ json : [String:Any] /*, _ request : HTTPRequest*/, _ type: String, _ request: HTTPRequest? = nil) throws -> Account {
                
                var req_session = ""
                if let req = request?.session {
                    req_session = req.token
                }

                let user = Account()
                var json = json
                let findDic:[String:Any] = ["source": type, "remoteid": json["id"].stringValue!]
                try user.find(findDic)
                if user.id.isEmpty {
                    // If we have an email, lets check that too ->
                    if let email = json["email"].stringValue { try user.find(["email":email]) }
                    guard user.id.isEmpty else { /* Here we should check if the user source is equal to the type */
                        // If the type is not equal to the user source (local, facebook, twitter, google)
                        if type != user.source {
                            // Their email is the same, so we dont need to update that here.
                            if json["email"].isNotNil {
                                json.removeValue(forKey: "email")
                            }
                            user.remoteid = json["id"].stringValue!
                            
                            if let _ = json["created"] {
                                json["modified"] = RMServiceClass.getNow()
                                json["modifiedby"] = user.id
                            } else {
                                json["created"] = RMServiceClass.getNow()
                                json["createdby"] = user.id
                            }
                            
                            // Now remove it out since it is in the remoteid:
                            json.removeValue(forKey: "id")
                            user.source = type
                            user.detail = json
                            
                            AuditRecordActions.userAdd(schema: nil,
                                                       session_id: req_session,
                                                       user: user.id,
                                                       row_data: ["remote_id": user.remoteid, "type":type, "email":json["email"] ?? "none"],
                                                       changed_fields: nil,
                                                       description: "Used an oauth request to create or update a user.",
                                                       changedby: user.id)
                            
                            // no need for the GIS save function - the location info is saved in the detail (and another table)
                            try user.save()
                            return user
                            
                        } else {
                            
                            AuditRecordActions.userLogin(schema: nil,
                                                         session_id: request?.session?.token ?? "NO SESSION TOKEN",
                                                         user: user.id,
                                                         row_data: nil,
                                                         changed_fields: nil,
                                                         description: "The user already exists as a \(user.source) (id: \(user.remoteid)) user.",
                                                         changedby: user.id)

                            return user
                        }
                    }
                    
                    // Okay we checked for existing accounts, so lets create a new one ->
                    user.makeID()
                    user.usertype = .standard
                    user.source = type
                    
                    if json["id"].isNotNil {
                        user.remoteid = json["id"].stringValue!
                        json.removeValue(forKey: "id")
                    }
                    if let em = json["email"].stringValue, !em.isEmpty {
                        user.email = em
                        json.removeValue(forKey: "email")
                    }
                    
                    user.detail = json
                    user.detail["created"] = RMServiceClass.getNow()
                    user.detail["createdby"] = user.id
                    
                    AuditRecordActions.userAdd(schema: nil,
                                               session_id: req_session,
                                               user: user.id,
                                               row_data: ["remote_id": user.remoteid, "type":type, "email":json["email"] ?? "none"],
                                               changed_fields: nil,
                                               description: "Used an oauth request to create or update a user.",
                                               changedby: user.id)

                    
                    // no need for the GIS save function - the location info is saved in the detail (and another table)
                    try user.create()
                    
                    user.detail["isNew"] = true
                    
                } else {
                    
                    AuditRecordActions.userLogin(schema: nil,
                                                 session_id: request?.session?.token ?? "NO SESSION TOKEN",
                                                 user: user.id,
                                                 row_data: nil,
                                                 changed_fields: nil,
                                                 description: "The user already exists as a \(user.source) user.",
                                                 changedby: user.id)

                    return user
                }
                return user
            }
            
            public static func login(data: [String:Any]) throws -> RequestHandler {
                return {
                    request, response in
                    if let s = request.session, !s.userid.isEmpty, s.data["csrf"].stringValue == request.header(.custom(name: "X-CSRF-Token")) {
                        response.alreadyAuthenticated(request)
                        return
                    }
                    
                    // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                    guard request.securityCheck() else { response.badSecurityToken; return }
                    
                    do {
                        
                        let json = try request.postBodyJSON()!
                        guard !json.isEmpty else { response.emptyJSONBody; return }
                    
                        guard json.keys.count == 1 else { response.invalidJSONFormat; return }
                        let key = json.keys.first!
                        
                        switch key {
                        case "facebook":
                            
                            if let theTest = try? facebook.verifyCredentials(json) {
                                if theTest.passed {
                                    // Now we need to either log the user in or create the user, and log them in.
                                    let account = try! self.createOrLoginUser(theTest.data, key, request)
                                    request.session?.userid = account.id
                                    
                                    AuditRecordActions.userLogin(schema: nil,
                                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                            user: account.id,
                                                            row_data: nil,
                                                            changed_fields: nil,
                                                            description: "User login: \(account.source).",
                                                            changedby: account.id)
                                    try? response.setBody(json: account.asDictionary)
                                        .setHeader(.contentType, value: "application/json")
                                        .completed(status: .ok)
                                    return
                                    
                                } else {
                                    // Return an error indicating we failed attempting to use oauth.
                                    response.invalidToken
                                    return
                                }
                            }
                        case "google":
                            if let theTest = try? google.verifyCredentials(json) {
                                if theTest.passed {
                                    
                                    let account = try! self.createOrLoginUser(theTest.data, key, request)
                                    request.session?.userid = account.id
                                    
                                    AuditRecordActions.userLogin(schema: nil,
                                                                 session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                                 user: account.id,
                                                                 row_data: nil,
                                                                 changed_fields: nil,
                                                                 description: "User login: \(account.source).",
                                        changedby: account.id)
                                    
                                    try? response.setBody(json: account.asDictionary)
                                        .setHeader(.contentType, value: "application/json")
                                        .completed(status: .ok)
                                    return
                                    
                                } else {
                                    response.invalidToken
                                    return
                                }
                            }
                        default:
                            response.invalidJSONFormat
                            return
                        }
                        
                    } catch RMAPIError.unparceableJSON(let unparceableJSON) {
                        response.invalidRequest(unparceableJSON)
                        return
                    } catch {
                        try? response.setBody(json: ["error" : "Unknown Error"])
                            .completed(status: .internalServerError)
                        return
                        
                    }
                
                }
            }
        }
        
        //MARK: - Update Profile:
        static func updateProfile(data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }
                
                // Check if the user is loged in:
                guard !Account.userBounce(request, response) else { return }
                
                var oldvalue:[String:Any] = [:]
                
                let user = request.account!
                
                do {
                    
                    let json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    if json["username"].stringValue.isNotNil {
                        oldvalue["username"] = user.username
                        user.username = json["username"].stringValue!.lowercased()
                    }
                    
                    if json["lastname"].stringValue.isNotNil {
                        oldvalue["lastname"] = user.detail["lastname"]
                        user.detail["lastname"] = json["lastname"].stringValue!
                    }
                    
                    if json["firstname"].stringValue.isNotNil {
                        oldvalue["firstname"] = user.detail["firstname"]
                        user.detail["firstname"] = json["firstname"].stringValue!
                    }
                    
                    if let emailNot = json["emailNotifications"].boolValue {
                        oldvalue["emailNotifications"] = user.detail["emailNotifications"]
                        user.detail["emailNotifications"] = emailNot
                    }
                    
                    if let appNotif = json["appNotifications"].boolValue {
                        oldvalue["appNotifications"] = user.detail["appNotifications"]
                        user.detail["appNotifications"] = appNotif
                    }
                    
                    user.detail["modified"] = RMServiceClass.getNow()
                    user.detail["modifiedby"] = user.id
                    
                    AuditRecordActions.userChange(schema: nil,
                                                  session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                  user: user.id,
                                                  row_data: nil,
                                                  changed_fields: oldvalue,
                                                  description: "User changed their profile.",
                                                  changedby: user.id)

                    // no need for the GIS save as the location is not saved nin a geo field (it is in detail)
                    do {
                        try user.save()
                    
                        try? response.setBody(json: ["result":"success"])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .ok)
                        return
                        
                    } catch {
                        return response.caughtError(error)
                    }
                    
                } catch RMAPIError.unparceableJSON(let attemptedJSON) {
                    return response.invalidRequest(attemptedJSON)
                } catch {
                    return response.caughtError(error)
                }
            }
        }
        //MARK: - File Support Functions:
        static func getFilenameProfile()->String {
            
            // name the new file
            var newfilename = UUID().uuidString
            // since we are using the UUID function there is a ~~very~~ slim chance of duplicates
            // if it is a duplicate, select another UUID.
            if doesFileExistProfilePics(filename: newfilename) {
                newfilename = UUID().uuidString
            }
            
            return newfilename
        }
                
        static func doesFileExistProfilePics(filename: String) -> Bool {
            
            var filefound = false
            
            // does it exist?
            var context = ["files":[[String:String]]()]
            let d = Dir(RMServiceClass.sharedInstance.filesDirectoryProfilePics)
            
            // if the directory does not exist, create it....
            RMServiceClass.doesDirectoryExist(d)

            // and look for the filename
            do{
                try d.forEachEntry(closure: {
                    f in
                    
                    if f.lowercased() == filename.lowercased() {
                        filefound = true
                        return
                    }
                    
                    context["files"]?.append(["name":f])
                })
            } catch {
                print("Checking directory for file error: \(error.localizedDescription)")
            }
            
            // we didn't see the file, or maybe we did?
            return filefound
            
        }
        
//        static func doesFileExist(filename: String) -> Bool {
//            
//            var filefound = false
//            
//            // does it exist?
//            var context = ["files":[[String:String]]()]
//            let d = Dir(CCXServiceClass.sharedInstance.filesDirectory)
//            
//            // if the directory does not exist, create it....
//            CCXServiceClass.doesDirectoryExist(d)
//
//            do {
//                try d.forEachEntry(closure: {
//                    f in
//                    
//                    if f.lowercased() == filename.lowercased() {
//                        filefound = true
//                        return
//                    }
//                    
//                    context["files"]?.append(["name":f])
//                })
//            } catch {
//                print("Searching the directory error: \(error)")
//            }
//            
//            // we didn't see the file, or maybe we did?
//            return filefound
//            
//        }
                
        //MARK: - Update Profile:
        static func uploadPicture(data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in

                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

            // security
            guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
            
            var imagetype = "large"
            var newfilename = ""
            var newfilenameadjustedimage = ""
            
            let pp = request.postParams
            for (key, value) in pp {
                switch key {
                case "type":
                    imagetype = value
                default:
                    break
                }
            }
            
            // process the uploads and the parameters
            if let uploads = request.postFileUploads, uploads.count > 0 {
                
                // put the file together
                for upload in uploads {
                    
                    let thisFile = File(upload.tmpFileName)
                    if thisFile.exists {
                        
                        newfilename = RMServiceClass.getFilename()
                        newfilenameadjustedimage = newfilename
                        newfilenameadjustedimage.append("-small")
                        
                        do {
                            // create the new name with extension
                            newfilename.append(".\(upload.fileName.filePathExtension)")
                            newfilenameadjustedimage.append(".\(upload.fileName.filePathExtension)")
                            
                            // make sure it is not already there (only do this once... )
                            if doesFileExistProfilePics(filename: newfilename) {
                                newfilename = UUID().uuidString
                                newfilename.append(".\(upload.fileName.filePathExtension)")
                                
                                newfilenameadjustedimage = newfilename
                                newfilenameadjustedimage.append("-small")
                                newfilenameadjustedimage.append(".\(upload.fileName.filePathExtension)")
                                
                            }
                            
                            // create the new file name
                            upload.fileName = newfilename
                            let thepath = "\(RMServiceClass.sharedInstance.filesDirectoryProfilePics)/\(upload.fileName)"
                            print(thepath)

//                            let target = Dir(RMServiceClass.sharedInstance.filesDirectoryProfilePics)

//                            RMServiceClass.movePicture(picturename: thisFile, todirectory: target)
                            let _ = try thisFile.moveTo(
                                path: thepath, overWrite: true
                            )
//                            debugPrint("File upload move: \(e)")
                            
                            var smallimagelocation = ""
                            
                            // lets create the small image first
                            let location = URL(fileURLWithPath:"\(RMServiceClass.sharedInstance.filesDirectoryProfilePics)/\(upload.fileName)")
//                            print("Image location: \(location.absoluteString)")
                            let tmpsmallimage = Image(url: location)
//                            debugPrint(tmpsmallimage)
                            // resize the image
//                            print("Resizing the profile image")
                            if let smallimage = tmpsmallimage?.resizedTo(width:75) {
//                                print("Image resized")
                                let locationsmall = URL(fileURLWithPath:"\(RMServiceClass.sharedInstance.filesDirectoryProfilePics)/\(newfilenameadjustedimage)")
//                                print("Writing the small image to: \(locationsmall.absoluteString)")
                                if smallimage.write(to: locationsmall) {
                                    // lets add it to the users data
                                    smallimagelocation = EnvironmentVariables.sharedInstance.AWSfileURLProfilePics!
                                    smallimagelocation.append(newfilenameadjustedimage)
                                }
                            }
                        } catch {
                            print(error)
                            try? response.setBody(json: ["error":error.localizedDescription])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .badRequest)
                            return
                        }
                    }
                }
            } else {
                
                try? response.setBody(json: ["error":"The file was not uploaded"])
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .badRequest)
                return
                
            }
            
            // save to the object (the filename)
            var picturesource = EnvironmentVariables.sharedInstance.AWSfileURLProfilePics!
            picturesource.append(newfilename)
            
            var changed_fields:[String:Any] = [:]
                
            // lets update the user
            let c = Account()
            
            let tryy = try? c.get(session.userid)
            if tryy.isNil {
                try? response.setBody(json: ["error":"Could not get user for update on \(imagetype)_picture"])
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .badRequest)
                return
                
            }
            c.detail["\(imagetype)_picture"] = picturesource
            changed_fields["\(imagetype)_picture"] = picturesource
            c.detail["modified"] = RMServiceClass.getNow()
            
            if newfilenameadjustedimage.count > 0 {
                // we have the small image!
                changed_fields["small_picture"] = "\(EnvironmentVariables.sharedInstance.AWSfileURLProfilePics!)\(newfilenameadjustedimage)"
                c.detail["small_picture"] = "\(EnvironmentVariables.sharedInstance.AWSfileURLProfilePics!)\(newfilenameadjustedimage)"
            }

                var retd:[String:Any] = [:]

            // update the user
            do {
                
                AuditRecordActions.userChange(schema: nil,
                                              session_id: session.token,
                                              user: session.userid,
                                              row_data: nil,
                                              changed_fields: changed_fields,
                                              description: "User changed their profile picture.",
                                              changedby: session.userid)
                
                try c.saveWithCustomType(schemaIn: "public",session.userid)
                
                retd["id"] = c.id
                retd["\(imagetype)_picture"] = c.detail["\(imagetype)_picture"]
                retd["small_picture"] = c.detail["small_picture"]

            } catch {

                AuditRecordActions.userChange(schema: nil,
                                              session_id: session.token,
                                              user: session.userid,
                                              row_data: nil,
                                              changed_fields: changed_fields,
                                              description: "User attempted to change their profile. FAILED.",
                                              changedby: session.userid)

                try? response.setBody(json: ["error":"The picture was not uploaded"])
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .badRequest)
                return
                
            }
                
            try? response.setBody(json: retd)
                .setHeader(.contentType, value: "application/json")
                .completed(status: .ok)
                return

            }
        }
        //MARK: - Forgot Password:
        static func forgotPassword(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                do {
                    
                    let json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    if let email = json["email"].stringValue {
                        
                        let account = Account()
                        let theTry:()? = try? account.find(["email":email.lowercased()])
                        if theTry.isNotNil && !account.id.isEmpty {
                            account.passreset = AccessToken.generate()
                        }
                        
                        if account.id.isEmpty {
                            
                            AuditRecordActions.userChange(schema: nil,
                                                          session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                          user: request.session?.userid ?? "NO USER",
                                                          row_data: ["email":email.lowercased()],
                                                          changed_fields: nil,
                                                          description: "Unknown User attempted to reset their password.",
                                                          changedby: request.session?.userid)

                            try? response.setBody(json: ["errorCode":"EmailDNE","message":"You are not registered on Bucket."])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .forbidden)
                            return
                            
                        }
                    
                        if (try? account.save()).isNotNil {
                            
                            AuditRecordActions.userChange(schema: nil,
                                                          session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                          user: request.session?.userid ?? "NO USER",
                                                          row_data: ["email":email.lowercased()],
                                                          changed_fields: nil,
                                                          description: "User requested forgot password.  Email sent.",
                                                          changedby: request.session?.userid)

                            // Lets send out the email to reset the password:
                            let h = "<p>To reset your password for your account, please <a href=\"\(AuthenticationVariables.baseURL)/verifyAccount/forgotpassword/\(account.passreset)\">click here</a></p>"
                            
                            try? response.setBody(json: ["message":"Please check your email to update your forgotten password."])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .ok)
                            Utility.sendMail(name: account.username, address: email, subject: "Password reset!", html: h, text: "")
                            return
                            
                        } else {
                            // Failed to save the passvalidation.
                            try? response.setBody(json: ["error":"Unknown error"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .internalServerError)
                            return
                            
                        }
                        
                    } else {
                        
                        try? response.setBody(json: ["errorCode":"RequiredJSON","message":"You must send in the key 'email'  to reset your password."])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .badRequest)
                        return
                        
                    }
                    
                } catch RMAPIError.unparceableJSON(let invalidJSONString) {
                    return response.invalidRequest(invalidJSONString)
                    
                } catch {
                    // Not sure what error could be thrown here, but the only one we throw right now is if the JSON is unparceable.
                    // Return some caught error:
                    response.caughtError(error)
                    return
                }
            }
        }
        
    }
    
    //MARK: Update current location to the user
    /**
     This function will parse the location from the dictionary, add it to the user detail and add a record in the use location table.
     - parameter user: The user account that should be changed.
     - parameter locationJSON: A dictionary in the following format:
     ["currentlocation":["latitude":33.1234567, "longitude":-77.7654321]]
     - return Account: The user with the added detail section for current location.
     */
    static func addCurrentLocationToUser(_ user: Account, locationJSON: [String:Any]) -> Account {
        
        // did they pass in the location?
        if var loc:[String:Any] = locationJSON["currentlocation"] as? [String : Any], let latitude = loc["latitude"].doubleValue, let longitude = loc["longitude"].doubleValue  {
            do {
                // ok -- we are updating the location
                if loc["distance"].doubleValue.isNotNil {
                    loc.removeValue(forKey: "distance")
                }
                user.detail["currentlocation"] = loc
                try user.saveWithCustomType(schemaIn: "public",user.id)
                
                // now lets add a current location record
                let ul = UserLocation()
                ul.geopoint = RMGeographyPoint(latitude: latitude, longitude: longitude)
                ul.geopointtime = RMServiceClass.getNow()
                //MARK:-
                //MARK: CHECK USER ID FOR NEW USERS
                //MARK:-
                ul.user_id = user.id
                try ul.saveWithCustomType(schemaIn: "public",user.id)    // note: this is the account table - audit fields are in the detail
                
                // lets see if the user needs something with location
                if let attn = user.detail["locationAttention"].boolValue, attn {

                    // ok -- lets send the welcome capsule
                    var params:[String: Any] = [:]
                    params["userid"] = user.id
                    params["geopoint"] = ["latitude":latitude, "longitude":longitude]
                    
                    //MARK:-
                    //MARK: Fire off the process for the project that performs an ation when the
                    //  location is updated for the current user.
                    //MARK:-
                    
                    // update the useer to return
                    try user.get(user.id)
                }
            } catch {
                // don't really do anything as this should not stop the show :)
            }
        }
        
        return user
        
    }
    
//    @discardableResult
//    static func UserSuccessfullyCreated(_ user:Account)->[String:Any] {
//
//        var returnDict:[String:Any] = [:]
//
//        // Call outside associations, if needed
////        let results = StagesConnecter.sharedInstance.associateUsers(user)
//        let results:[String:Any] = [:]
//        for (key,value) in results {
//            returnDict[key] = value
//        }
//
//        return returnDict
//    }
}


//MARK: Supporting Functions:
func extras(_ request: HTTPRequest) -> [String : Any] {
    
    return [
        "token": request.session?.token ?? "",
        "csrfToken": request.session?.data["csrf"] as? String ?? ""
    ]
    
}

func appExtras(_ request: HTTPRequest) -> [String : Any] {
    var priv = ""
    var isAdmin = false
    
    let id = request.session?.userid ?? ""
    if !id.isEmpty {
        let user = Account()
        try? user.get(id)
        priv = "\(user.usertype)"
        if user.usertype == .admin {
            isAdmin = true
        }
    }
    return [
        "title": RMServiceClass.sharedInstance.displayTitle,
        "subtitle": RMServiceClass.sharedInstance.displaySubTitle,
        "logo": RMServiceClass.sharedInstance.displayLogo,
        "srcset": RMServiceClass.sharedInstance.displayLogoSrcSet,
        "priv": priv,
        "admin": isAdmin
    ]
    
}
//MARK: - Oauth Support:
typealias JSONOAuthReturn = (passed: Bool, data: [String:Any], foreignuserid : String)
struct FacebookOAuth  {
    var appId : String = "433918117057494"
    var appSecret : String = "ce9ddce2028002cb658ae27942214e24"
    func verifyCredentials(_ data : [String:Any]) throws -> JSONOAuthReturn {
        
        // We need to hit the debug token api, not the graph api about the user:
        if let access_token = data.facebook["access_token"].stringValue, let userid = data.facebook["id"].stringValue {
            let verifyURL = "https://graph.facebook.com/debug_token?input_token=\(access_token)&access_token=\(appId+"|"+appSecret)"
            // Okay we need to make sure this token is for our app:
            let result = Utility2.makeRequest(.get, verifyURL)
            
            // Lets see if the result is successful:
            if let data = result["data"].dicValue {
                // We have data to check!
                if let appId = data["app_id"].stringValue, let userId = data["user_id"].stringValue {
                    // Check the app id to what we have:
                    if appId == self.appId && userid == userId {
                        // We need to go and get the data now from fb:
                        let fbdata = getFBData(access_token, fields: ["id", "first_name", "last_name","email", "picture.width(500).height(500).as(large_picture)", "picture.width(75).height(75).as(small_picture)"])
                        return (true, fbdata, userid)
                        
                    } else {
                        // Return an error indicating the incorrect app?
                        return (false, [:], userid)
                    }
                } else {
                    return (false, result, userid)
                }
            } else {
                // There must have been an error:
                return (false, result, userid)
            }
        } else {
            // Send an indication error?
            return (false, [:], "")
        }
    }
    
    func getFBData(_ accessToken : String, fields : [String]) -> [String:Any] {
        let dataURL = "https://graph.facebook.com/v2.8/me?fields=\(fields.joined(separator: "%2C"))&access_token=\(accessToken)"
        
        var fbdata = Utility2.makeRequest(.get, dataURL)
        // Lets reformat the JSON:
        if let smallpic = fbdata["small_picture"].dicValue["data"].dicValue["url"].stringValue {
            fbdata["small_picture"] = smallpic
        }
        if let largepic = fbdata["large_picture"].dicValue["data"].dicValue["url"].stringValue {
            fbdata["large_picture"] = largepic
        }
        if fbdata["first_name"].isNotNil {
            fbdata["firstname"] = fbdata["first_name"]
            fbdata.removeValue(forKey: "first_name")
        }
        if fbdata["last_name"].isNotNil {
            fbdata["lastname"] = fbdata["last_name"]
            fbdata.removeValue(forKey: "last_name")
        }
        if fbdata["email"].isNotNil {
            fbdata["email_verified"] = true
        }
        
        return fbdata
    }
}

struct GoogleOAuth {
    
    var serverClientId : String = "399381442494-atvoitfj7av90r5ef9dh0qm6n1h5b20l.apps.googleusercontent.com"
    var serverClientSecret : String = "f90I95GQkwIOaLBTvdwY2IYO"
    
    func verifyCredentials(_ data : [String:Any]) throws -> JSONOAuthReturn {
        
        // We need to
        
        if let access_token = data.google["access_token"].stringValue, let userid = data.google["id"].stringValue {
            
            var googleData = getGoogleData(access_token, ["family_name","given_name","id","picture"])
            
            var returnedGoogleData : [String:Any] = [:]
            // Lets normalize the dictionary for the createOrLogin user function.
            if !googleData.isEmpty {
                if googleData["sub"].isNotNil {
                    returnedGoogleData["id"] = googleData["sub"]
                }
                if googleData["email"].isNotNil {
                    returnedGoogleData["email"] = googleData["email"]
                }
                if googleData["email_verified"].isNotNil {
                    returnedGoogleData["email_verified"] = googleData["email_verified"].boolValue
                }
                if googleData["family_name"] != nil {
                    returnedGoogleData["lastname"] = googleData["family_name"]
                }
                if googleData["given_name"] != nil {
                    returnedGoogleData["firstname"] = googleData["given_name"]
                }
                if let pictureURL = googleData["picture"].stringValue {
                    // Append the other sizes:
                    returnedGoogleData["small_picture"] = pictureURL.appending("?sz=75")
                    returnedGoogleData["large_picture"] = pictureURL.appending("?sz=500")
                }
            }
            
            if let authCode = data.google["serverAuthCode"].stringValue, let refreshToken = getRefreshToken(authToken: authCode) {
                returnedGoogleData["refresh_token"] = refreshToken
            }
            
            return (userid == returnedGoogleData["id"].stringValue && serverClientId == googleData["aud"].stringValue, returnedGoogleData, userid)
            
        }
        
        return (false,[:], "")
    }
    func getGoogleData(_ accessToken : String, _ fields: [String]) -> [String:Any] {
        
        let url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=\(accessToken)"
        return Utility2.makeRequest(.get, url)
        
    }
    func getRefreshToken(authToken : String) -> String? {
        // We need to see about using cURL for this:
        
        let data = Utility2.makeRequest(.post, "https://www.googleapis.com/oauth2/v4/token?client_id=\(serverClientId)&client_secret=\(serverClientSecret)&grant_type=authorization_code&code=\(authToken)", encoding: "form")
        
        if let refreshToken = data["refresh_token"].stringValue {
            return refreshToken
        } else {
            return nil
        }
        
    }
    
    func refreshToken() {
        // Make the request to refresh a token:
        
    }
}
    
struct TwitterOAuth {
    func verifyCredentials(_ data : [String:Any]) throws -> JSONOAuthReturn {
        if let access_token = data.twitter["access_token"].stringValue, let userid = data.twitter["id"].stringValue {
            
            let twitterData = self.getTwitterData(access_token)
            
            print(twitterData)
            
            // We need to go and fetch the user data. For now we will send it in from the frontend.
            return (false,[:],userid)
            
        }
        return (false,[:], "")
    }
    func getTwitterData(_ accessToken : String) -> [String:Any] {
        
        //       let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
        
        let url = "https://api.twitter.com/oauth2/token"
        
        let postBody = try? ["token_type" : "bearer", "access_token" : "\(accessToken)"].jsonEncodedString()
        if postBody.isEmptyOrNil {
            return [:]
        }
        //        var request = NSMutableURLRequest(url: URL(string: url)!)
        //        request.setValue("Authorization", forHTTPHeaderField: "Basic \(accessToken)")
        //        request.setValue("Content-Type", forHTTPHeaderField: "application/x-www-form-urlencoded;charset=UTF-8")
        //        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("Authorization", forHTTPHeaderField: "Basic \(accessToken)")
        request.addValue("Content-Type", forHTTPHeaderField: "application/x-www-form-urlencoded;charset=UTF-8")
        request.httpMethod = "POST"
        
        request.httpBody = postBody!.data(using: .utf8)
        
        //exchange(authorizationCode: AuthorizationCode(code: accessToken, redirectURL: ""))
        
        
        return [:]
        
        //      return Utility.makeRequest(.post, url, body: postBody!, encoding: "UTF-8", bearerToken: "")
    }
}
extension Account {
    var asDictionary : [String:Any] {
        
        var dic = self.results.rows.first?.data ?? [:]
        
        switch self.source {
        case "local":
            if self.detail["isNew"].isNotNil {
                self.detail.removeValue(forKey: "isNew")
                dic["detail"].dicValue.removeValue(forKey: "isNew")
                dic["isNew"] = true
                do {
                    try self.save()
                } catch {
                    
                }
            }
        default:
            if self.detail["isNew"].isNotNil, self.detail["isNew"].boolValue == true {
                dic["isNew"] = true
                self.detail.removeValue(forKey: "isNew")
                dic["detail"].dicValue.removeValue(forKey: "isNew")
                try! self.save()
            }
        }
        
        // Remove out the keys that we dont need:
        if dic.count == 1 || dic.isEmpty {
            let addinIsnew = dic.count == 1
            try? self.find(["id":self.id])
            dic = self.results.rows.first?.data ?? [:]
            if addinIsnew {
                dic["isNew"] = true
            }
        }
        // Remove out the password & pass validation:
        dic.removeValue(forKey: "password")
        dic.removeValue(forKey: "passvalidation")
        dic.removeValue(forKey: "passreset")

        // Remove the username if it is not set.
        if dic.user.username?.isEmpty == true {
            dic.removeValue(forKey: "username")
        }
        
        return dic
    }
    class func loginWithEmail(_ email : String, _ password : String) throws -> Account {
        if let digestBytes = password.digest(.sha256),
            let hexBytes = digestBytes.encode(.hex),
            let hexBytesStr = String(validatingUTF8: hexBytes) {
            
            let acc = Account()
            let criteria = ["email":email,"password":hexBytesStr]
            do {
                try acc.find(criteria)
                if acc.usertype == .provisional {
                    throw OAuth2ServerError.loginError
                }
                return acc
            } catch {
                print(error)
                throw OAuth2ServerError.loginError
            }
        } else {
            throw OAuth2ServerError.loginError
        }
    }
    
    public static func adminBounce(_ request: HTTPRequest, _ response: HTTPResponse) {
        let user = Account()
        do {
            try user.get(request.session?.userid ?? "")
            if user.usertype != .admin {
                response.redirect(path: "/")
                response.completed()
                return
            }
        } catch {
            print(error)
        }
    }
}

enum ResendType : String {
    case forgotPassword="forgotpassword", registration="registration"
}
fileprivate extension HTTPRequest {
    var resendType : ResendType? {
        guard let type = self.header(.custom(name: "resendType")) else { return nil }
        return ResendType(rawValue: type)
    }
}

extension HTTPResponse {
    var invalidToken : Void {
        return try! self.setBody(json: ["errorCode":"InvalidToken","message":"Invalid Token"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .forbidden)
    }
    var invalidCredentials : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCredentials","message":"Please check your username and password."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .forbidden)
    }
    func alreadyAuthenticated(_ request : HTTPRequest) {
        let account = Account()
        try? account.get(request.session!.userid)
        return try! self.setBody(json: account.asDictionary).setHeader(.contentType, value: "application/json; charset=UTF-8").completed(status: .ok)
    }
    var alreadyAuthenticated : Void {
        
        return try! self.setBody(json: ["errorCode":"AlreadyAuthenticated","message":"You are already logged in."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .ok)
    }
}
