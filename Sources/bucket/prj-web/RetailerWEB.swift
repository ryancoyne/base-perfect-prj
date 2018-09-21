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
import PerfectMustache

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
        
        //MARK: --
        //MARK: Retailer Terminal list page
        struct retailerterminalindexHelper: MustachePageHandler {
            
            var values: MustacheEvaluationContext.MapType = [:]
            
            func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
            
                contxt.extendValues(with: values)

                do {
                    try contxt.requestCompleted(withCollector: collector)
                } catch {
                    let response = contxt.webResponse
                    response.appendBody(string: "\(error)")
                    .completed(status: .internalServerError)
                }

            }
            
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
                guard let retailer_dict:[String:Any] = user?.detail["retailers"] as? [String : Any] else {
                    response.render(template: "views/retailer/index")
                    response.completed()
                    return
                }

                var values: MustacheEvaluationContext.MapType = [:]
                
                var retailers:[String:[[String:Any]]] = [:]
                
                // lets get the retailer information and the unassigned terminals
                for (key,value) in retailer_dict {
                    
                    var ret_array:[[String:Any]] = []
                    
                    let schema = key.lowercased()
                    
                    // get the retailers together
                    for i in (value as! [Int]) {
                        let r = RetailerAll()
                        r.get(schema, i)
                        r.country_code = schema
                        r.country_id = Country.idWith(schema)
                        ret_array.append(r.asDictionary())
                    }
                    
                    if ret_array.count > 0 {
                        ret_array.append(["country_code":key])
                        if let c_id = Country.idWith(key) {
                            ret_array.append(["country_id":c_id])
                        }
                        retailers[schema] = ret_array
                    }
                    
                }
                
                // lets add the array of the countries for this retaiuler so we know which ones to address on the page
                var countries:[String] = []
                for (key, _) in retailer_dict {
                    countries.append(key)
                }
                
                if !countries.isEmpty {
                    // provides the list of countries the user has assigned to thier user profile
                    values["countries"] = countries
                }
                
                // only send back the retailers if there are any retailers
                if retailers.count > 0 { values["retailers"] = retailers }

                print(values)
                
                mustacheRequest(request: request,
                                response: response,
                                handler: retailerterminalindexHelper(values: values),
                                templatePath: "\(request.documentRoot)/views/retailer/index.mustache")
            }
        }

        //MARK: --
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
