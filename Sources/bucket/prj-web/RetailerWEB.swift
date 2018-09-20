//
//  RetailerWEB.swift
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

//MARK: - Retailer Web endpoints
/// This Retailer structure supports all the normal endpoints for a user based login application.
struct RetailerWEB {
    
    //MARK: - Web Routes:
    struct web {
        // POST request for login
        static var routes : [[String:Any]] {
            return [
                ["method":"post", "uri":"/retailer", "handler":retailerterminalindex],
                ["method":"post", "uri":"/retailer/{countryId}", "handler":retailerindex],
                ["method":"post", "uri":"/retailer/{countryId}/{retailerId}", "handler":retailerdetail],
                ["method":"post", "uri":"/retailer/{countryId}/{retailerId}/location", "handler":retailerlocations],
                ["method":"post", "uri":"/retailer/{countryId}/{retailerId}/terminals", "handler":retailerterminals],
                ["method":"post", "uri":"/retailer/{countryId}/{retailerId}/{locationId}/terminals", "handler":retailerterminals],
            ]
        }
        
        public static func retailerterminalindex(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }
                
                // check to see if the user is permitted to these retailer pages
                let user = request.account
                if user.isNil { return }

                // lets pull out the retailers list (if they have any)
                guard let retailer_dict:[String:Any] = user?.detail["retailers"] as? [String : Any] else { return }
                
                var terminals:[String:[Terminal]] = [:]
                
                for (key,value) in retailer_dict {
                    
                    let schema = key.lowercased()
                    
                    var retailers = ""
                    
                    // get the retailers together
                    for i in (value as! [Int]) {
                        retailers.append("\(i),")
                    }
                    
                    // remove the last comma
                    retailers.removeLast()
                    
                    // now we have the list of retailers for this schema (country)
                    
                    // lets get the country ID and look at the retailer groups they are permitted to address
                    let sql = "SELECT * FROM \(schema).terminal WHERE retailer_id IN (\(retailers))"
                    let terminal = Terminal()
                    var terms:[Terminal] = []
                    
                    let term_list = try? terminal.sqlRows(sql, params: [])
                    for t in term_list! {
                        let trm = Terminal()
                        trm.to(t)
                        terms.append(trm)
                    }
                    
                    // done processing this country - loop around to the next
                    terminals[key] = terms
                    
                }
                
                var sortedKeys:[String] = []
                
                // now we have the list of terminals.  Lets see what countries we are working with
                if terminals.count > 1 {
                    
                    // sort the dictionary by counter
                    sortedKeys = terminals.keys.sorted(by: < )
                    
                }
                
                // now it is time to process..... all countries
                
                
                response.render(template: "views/retailer/index")
                response.completed()
                
            }
        }

        public static func retailerindex(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }

                // grab the country id
                let country_id = request.countryId
                var schema = ""
                if country_id.isNotNil {
                    schema = Country.getSchema(country_id!)
                } else {
                    // there is an error with the country ID
                    response.unsupportedCountry
                    return
                }
                
                // grab the retailer information for the retailer
                let retailer_id = request.retailerId
                
                // make sure the user has authority to access the retailer information
                if country_id.isNil { response.invalidCountryCode; return }
                if retailer_id.isNil { response.invalidRetailerCode; return }
                
                // check to see if the user is permitted to these retailer pages
                let user = request.account
                if user.isNil { return }
                if !user!.bounceRetailerAdmin(schema, retailer_id!) {
                    
                }

                
                response.render(template: "views/retailer/index")
                response.completed()
                
            }
        }
        
        public static func retailerdetail(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }

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
        
        public static func retailerlocations(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in

                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { response.badSecurityToken; return }

                var template = "views/msg" // where it goes to after
                var context: [String : Any] = ["title": "Bucket Technologies", "subtitle":"Goodbye coins, Hello Change"]

                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                var problem:String
                if !request.SecurityCheck() {
                    problem = response.badSecurityTokenWeb
                    context["msg_title"] = "Login Error."
                    context["msg_body"] = problem
                    template = "views/msg"
                    response.render(template: template, context: context)
                    response.completed()
                    return
                }

                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
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
        
        public static func retailerterminals(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { response.badSecurityToken; return }
                
                var template = "views/msg" // where it goes to after
                var context: [String : Any] = ["title": "Bucket Technologies", "subtitle":"Goodbye coins, Hello Change"]
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                var problem:String
                if !request.SecurityCheck() {
                    problem = response.badSecurityTokenWeb
                    context["msg_title"] = "Login Error."
                    context["msg_body"] = problem
                    template = "views/msg"
                    response.render(template: template, context: context)
                    response.completed()
                    return
                }
                
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
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
