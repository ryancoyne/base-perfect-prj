//
//  ConsumerWEB.swift
//  bucket
//
//  Created by Mike Silvers on 8/30/18.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession

//MARK: - Consumer Web endpoints
/// This Retailer structure supports all the normal endpoints for a user based login application.
struct ConsumerWEB {
    
    //MARK: - Web Routes:
    struct web {
        // POST request for login
        static var routes : [[String:Any]] {
            return [
                ["method":"post", "uri":"/login", "handler":login],
                ["method":"get", "uri":"/forgotpassword", "handler":forgotPassword],
                ["method":"post", "uri":"/forgotpasswordEntered", "handler":forgotPasswordEntered],
            ]
        }
        
        public static func forgotPassword(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                response.render(template: "views/forgotpassword")
                response.completed()
                
            }
        }
        
        public static func forgotPasswordEntered(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // get the email:
                guard let email = request.param(name: "email") else { return }
                // Okay see if we can find the account:
                let find = Account()
                try? find.find(["email":email])
                
                if !find.id.isEmpty {
                    // okay.  we need to create their pass reset thingy and send an email:
                    
                    find.passreset = AccessToken.generate()
                    
                    if (try? find.save()).isNotNil {
                        let h = "<p>To reset your password for your account, please <a href=\"\(AuthenticationVariables.baseURL)/verifyAccount/forgotpassword/\(find.passreset)\">click here</a></p>"
                        
                        response.render(template: "views/forgotpassword", context: ["msg_body":"We sent a confirmation email to \(email).","msg_title":"Success!"])
                        response.completed()
                        
                        Utility.sendMail(name: find.username, address: email, subject: "Password reset!", html: h, text: "")
                    } else {
                        
                        response.render(template: "views/forgotpassword", context: ["msg_body":"Please try again.","msg_title":"Unknown Error."])
                        response.completed()
                        
                    }
                    
                } else {
                    // Show an error:
                    response.render(template: "views/forgotpassword", context: ["msg_body":"We had an issue looking up this email.","msg_title":"Forgot Password Error"])
                    response.completed()
                }
                
            }
        }
        
        public static func login(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                var template = "views/msg" // where it goes to after
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
                var context: [String : Any] = ["title": "Bucket Technologies", "subtitle":"Goodbye coins, Hello Change"]
                context["csrfToken"] = request.session?.data["csrf"] as? String ?? ""
                
                if let email = request.param(name: "email").stringValue, !email.isEmpty,
                    let password = request.param(name: "password").stringValue, !password.isEmpty {
                    do {
                        let account = try Account.loginWithEmail(email, password)
                        request.session?.userid = account.id
                        context["msg_title"] = "Login Successful."
                        context["msg_body"] = ""
                        response.redirect(path: "/")
                    } catch {
                        context["msg_title"] = "Login Error."
                        context["msg_body"] = "Email or password incorrect"
                        template = "views/login"
                    }
                } else {
                    context["msg_title"] = "Login Error."
                    context["msg_body"] = "Email or password not supplied"
                    template = "views/login"
                }
                response.render(template: template, context: context)
                response.completed()
            }
        }
    }
}
