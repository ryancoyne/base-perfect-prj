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
import PerfectCrypto
import SwiftGD
import PerfectCURL
import cURL

//MARK: - User API
/// This UserAPI structure supports all the normal endpoints for a user based login application.
struct UserWEB {
    //MARK: - Web Handlers:
    /// This json structure supports all the web endpoints that support the application, including forgot password, completion of registration.
    struct web {
        static var routes : [[String:Any]] {
            return [["method":"get", "uri":"/verifyAccount/forgotpassword/{passreset}", "handler": forgotpassVerify],
                    ["method":"post", "uri":"/forgotpasswordCompletion", "handler": forgotpasswordCompletion],
                    ["method":"get", "uri":"/verifyAccount/{passvalidation}", "handler": registerVerify],
                    ["method":"post", "uri":"/registrationCompletion", "handler": registerCompletion],
                    ["method":"get", "uri":"/logout", "handler":LocalAuthWebHandlers.logout],
                    ["method":"post", "uri":"/login", "handler":LocalAuthWebHandlers.login],
                    ["method":"get", "uri":"/users", "handler":Handlers.userList],
                    ["method":"get", "uri":"/users/create", "handler":Handlers.userMod],
                    ["method":"get", "uri":"/users/create/edit", "handler":Handlers.userMod],
                    ["method":"post", "uri":"/users/create", "handler":Handlers.userModAction],
                    ["method":"post", "uri":"/users/{id}/edit", "handler":Handlers.userModAction],
                    ["method":"delete", "uri":"/users/{id}/delete", "handler":Handlers.userDelete]]
        }
        //MARK: - Register Verify Page:
        public static func registerVerify(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                let t = request.session?.data["csrf"] as? String ?? ""
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/"); response.completed(); return }
                var context: [String : Any] = appExtras(request)
                
                if let v = request.urlVariables["passvalidation"], !(v as String).isEmpty {
                    
                    let acc = Account(validation: v)
                    
                    if acc.id.isEmpty {
                        
                        AuditRecordActions.userRegistration(schema: nil,
                                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                            user: request.session?.userid,
                                                            row_data: nil,
                                                            changed_fields: nil,
                                                            description: "Registration NOT complete.  Account verification failed.",
                                                            changedby: nil)
                        
                        context["msg_title"] = "Account Validation Error."
                        context["msg_body"] = ""
                        response.render(template: "views/msg", context: context)
                        response.completed()
                        return
                    } else {
                        
                        AuditRecordActions.userRegistration(schema: nil,
                                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                            user: request.session?.userid,
                                                            row_data: nil,
                                                            changed_fields: nil,
                                                            description: "Registration complete.  Account verified.",
                                                            changedby: nil)
                        
                        context["passvalidation"] = v
                        context["csrfToken"] = t
                        response.render(template: "views/registerComplete", context: context)
                        response.completed()
                        return
                    }
                } else {
                    
                    AuditRecordActions.userRegistration(schema: nil,
                                                        session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                        user: request.session?.userid,
                                                        row_data: nil,
                                                        changed_fields: nil,
                                                        description: "Registration NOT complete.  Account verification failed.  Code not found.",
                                                        changedby: nil)

                    context["msg_title"] = "Account Validation Error."
                    context["msg_body"] = "Code not found."
                    response.render(template: "views/msg", context: context)
                    response.completed()
                    return
                }
            }
        }
        //MARK: - Register Completion Page:
        public static func registerCompletion(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                let t = request.session?.data["csrf"] as? String ?? ""
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/"); response.completed(); return }
                var context: [String : Any] = appExtras(request)
                
                if let v = request.param(name: "passvalidation"), !(v as String).isEmpty {
                    
                    let acc = Account(validation: v)
                    
                    if acc.id.isEmpty {
                        context["msg_title"] = "Account Validation Error."
                        context["msg_body"] = ""
                        response.render(template: "views/msg", context: context)
                        response.completed()
                        return
                    } else {
                        
                        if let p1 = request.param(name: "p1"), !(p1 as String).isEmpty,
                            let p2 = request.param(name: "p2"), !(p2 as String).isEmpty,
                            p1 == p2 {
                            acc.makePassword(p1)
                            if acc.usertype == .provisional {
                                acc.usertype = .standard
                            }
                            //                            acc.usertype = .standard
                            acc.detail["isNew"] = true
                            
                            if let _ = acc.detail["created"] {
                                acc.detail["modified"] = RMServiceClass.getNow()
                            } else {
                                acc.detail["created"] = RMServiceClass.getNow()
                            }
                            
                            do {
                                try acc.save()
                                
                                // check with stages 
                                UserAPI.UserSuccessfullyCreated(acc)
                                
                                request.session?.userid = acc.id
                                context["msg_title"] = "Account Validated and Completed."
                                context["msg_body"] = "<p><a class=\"button\" href=\"/\">Click to continue</a></p>"
                                response.render(template: "views/msg", context: context)
                                response.completed()
                                return
                                
                            } catch {
                                print(error)
                            }
                        } else {
                            context["msg_body"] = "<p>Account Validation Error: The passwords must not be empty, and must match.</p>"
                            context["passvalidation"] = v
                            context["csrfToken"] = t
                            response.render(template: "views/registerComplete", context: context)
                            response.completed()
                            return
                        }
                        
                    }
                } else {
                    context["msg_title"] = "Account Validation Error."
                    context["msg_body"] = "Code not found."
                    response.render(template: "views/msg", context: context)
                    response.completed()
                    return
                }
            }
        }
        //MARK: - Forgot Password Validation Page:
        public static func forgotpassVerify(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                let t = request.session?.data["csrf"] as? String ?? ""
                
                var context: [String : Any] = appExtras(request)
                
                if let v = request.urlVariables["passreset"], !(v as String).isEmpty {
                    
                    let acc = Account(reset: v)
                    
                    if acc.id.isEmpty {
                        context["msg_title"] = "Account Validation Error."
                        context["msg_body"] = ""
                        response.render(template: "views/msg", context: context)
                        response.completed()
                        return
                    } else {
                        context["passreset"] = v
                        context["csrfToken"] = t
                        response.render(template: "views/forgotpasswordComplete", context: context)
                        response.completed()
                        return
                    }
                } else {
                    context["msg_title"] = "Account Validation Error."
                    context["msg_body"] = "Code not found."
                    response.render(template: "views/msg", context: context)
                    response.completed()
                    return
                }
            }
        }
        //MARK: - Forgot Password Completion Page:
        public static func forgotpasswordCompletion(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                let t = request.session?.data["csrf"] as? String ?? ""
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/"); response.completed(); return }
            
                var context: [String : Any] = appExtras(request)
                
                if let v = request.param(name: "passreset"), !(v as String).isEmpty {
                    
                    let acc = Account(reset: v)
                    
                    if acc.id.isEmpty {
                        context["msg_title"] = "Account Validation Error."
                        context["msg_body"] = ""
                        response.render(template: "views/msg", context: context)
                        response.completed()
                        return
                    } else {
                        
                        if let p1 = request.param(name: "p1"), !(p1 as String).isEmpty,
                            let p2 = request.param(name: "p2"), !(p2 as String).isEmpty,
                            p1 == p2 {
                            acc.makePassword(p1)
                            if acc.usertype == .provisional {
                                acc.usertype = .standard
                            }
                            //                        acc.usertype = .standard
                            acc.detail["modified"] = RMServiceClass.getNow()
                            acc.passreset.removeAll()
                            do {
                                try acc.save()
                                request.session?.userid = acc.id
                                context["msg_title"] = "You successfully changed your password!"
                                //                           context["msg_body"] = "<p><a class=\"button\" href=\"/\">Click to continue</a></p>"
                                response.render(template: "views/msg", context: context)
                                response.completed()
                                return
                                
                            } catch {
                                print(error)
                            }
                        } else {
                            context["msg_body"] = "<p>Account Validation Error: The passwords must not be empty, and must match.</p>"
                            context["passvalidation"] = v
                            context["csrfToken"] = t
                            response.render(template: "views/forgotpasswordComplete", context: context)
                            response.completed()
                            return
                        }
                        
                    }
                } else {
                    context["msg_title"] = "Account Validation Error."
                    context["msg_body"] = "Code not found."
                    response.render(template: "views/msg", context: context)
                    response.completed()
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
                ul.geopoint = CCXGeographyPoint(latitude: latitude, longitude: longitude)
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
    
    @discardableResult
    static func UserSuccessfullyCreated(_ user:Account)->[String:Any] {
        
        var returnDict:[String:Any] = [:]
        
        // Call outside associations, if needed
//        let results = StagesConnecter.sharedInstance.associateUsers(user)
        let results:[String:Any] = [:]
        for (key,value) in results {
            returnDict[key] = value
        }
        
        return returnDict
    }
}

//MARK: --
//MARK: LocalAuthWebHandlets extension
extension LocalAuthWebHandlers {
    
    //MARK: Login process
    public static func login(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            if let i = request.session?.userid, !i.isEmpty { response.redirect(path: request.getSourcePath()) }
            var context: [String : Any] = ["title": "Perfect Authentication Server"]
            context["csrfToken"] = request.session?.data["csrf"] as? String ?? ""
            
            var emailattempt = false
            
            if let u = request.param(name: "username"), !(u as String).isEmpty,
                let p = request.param(name: "password"), !(p as String).isEmpty {
                do {
                    let acc = try Account.login(u, p)
                    request.session?.userid = acc.id
                    context["msg_title"] = "Login Successful."
                    context["msg_body"] = ""
                    response.redirect(path: request.getSourcePath(), sessionid: (request.session?.token)!)
                    response.completed()
                    return
                } catch {
                    emailattempt = true
                }
                
                // try the email since the username did not work
                if emailattempt {
                    do {
                        let acc = try Account.loginWithEmail(u, p)
                        request.session?.userid = acc.id
                        context["msg_title"] = "Login Successful."
                        context["msg_body"] = ""
                        response.redirect(path: request.getSourcePath(), sessionid: (request.session?.token)!)
                        response.completed()
                        return
                    } catch OAuth2ServerError.loginError {
                        // try it here - because we are looking at the second try for the username/password (since we arte trying email first)
                        context["msg_body"] = "Lets try to login correctly this time."
//                        let _ = try? response.setBody(json: context.jsonEncodedString())
                        response.redirect(path: request.getSourcePath(), sessionid: (request.session?.token)!)
                        response.completed()
                        return

                    } catch {
                        emailattempt = false
                    }
                }
                
            } else {
                // do nothing - the page will be presented again with the login rather than data
                
                context["msg_body"] = "Lets try to login correctly this time."
                let _ = try? response.setBody(json: context.jsonEncodedString())
                response.redirect(path: request.getSourcePath(), sessionid: (request.session?.token)!)
                response.completed()
                return
            }

            response.redirect(path: request.getSourcePath(), sessionid: (request.session?.token)!)
            response.completed()
            return

            }
    }
    
    
}

