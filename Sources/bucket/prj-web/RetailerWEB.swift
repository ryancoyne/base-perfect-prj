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
//                ["method":"get", "uri":"/retailer", "handler":retailerterminalindex],
                ["method":"get", "uri":"/retailer/{countryId}", "handler":retailerindex],
                ["method":"get", "uri":"/retailer/{countryId}/{retailerId}", "handler":retailerdetail],
//                ["method":"get", "uri":"/retailer/terminal/{countryId}/{retailerId}/{terminalId}", "handler":retailerterminal],
//                ["method":"get", "uri":"/retailer/{countryId}/{retailerId}/location", "handler":retailerlocations],
//                ["method":"get", "uri":"/retailer/{countryId}/{retailerId}/terminals", "handler":retailerterminals],
//                ["method":"get", "uri":"/retailer/{countryId}/{retailerId}/{locationId}/terminals", "handler":retailerterminals],
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
                    response.render(template: "views/retailer.index")
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
                                templatePath: "\(request.documentRoot)/views/retailer.index.mustache")
            }
        }

        //MARK: --
        public static func retailerindex(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                #if !os(macOS)
                    guard request.SecurityCheck() else { return response.badSecurityToken }
                #endif

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
//                let retailer_id = request.retailerId
                
                // make sure the user has authority to access the retailer information
                if country_id.isNil { response.invalidCountryCode; return }
//                if retailer_id.isNil { response.invalidRetailerCode; return }
                
                // check to see if the user is permitted to these retailer pages
//                let user = request.account
//                if user.isNil { return }
//                if !user!.bounceRetailerAdmin(schema, retailer_id!) {
                    
//                }
                
                var data_return:[String:Any] = [:]
                
                data_return["title_label"] = "Retailer Information"

                data_return["page_retailer"] = true
                data_return["country_id"] = country_id
                let ctry = Country()
                let _ = try? ctry.get(country_id!)
                if ctry.name.isNotNil {
                    data_return["title"] = ctry.name!
                    data_return["subtitle"] = ctry.code_alpha_2?.lowercased()
                }
                
                // lets grab the retailers for the country
                var sql = "SELECT * FROM \(schema).retailer;"
                let r = Retailer()
                let r_r = try? r.sqlRows(sql, params: [])
                if r_r.isNotNil {
                    var ret:[[String:Any]] = []
                    for r_d in r_r! {
                        let reta = Retailer()
                        reta.to(r_d)
                        var ret_raw = reta.asDictionary()
                        
                        sql = "SELECT COUNT(*) FROM \(schema).address WHERE retailer_id = \(reta.id!)"
                        let add_c = try? r.sqlRows(sql, params: [])
                        if add_c.isNotNil, add_c!.count > 0 {
                            ret_raw["address_count"] = add_c!.first!.data["count"].intValue
                        } else {
                            ret_raw["address_count"] = 0
                        }
                        
                        sql = "SELECT COUNT(*) FROM \(schema).terminal WHERE retailer_id = \(reta.id!)"
                        let trm_c = try? r.sqlRows(sql, params: [])
                        if trm_c.isNotNil, trm_c!.count > 0 {
                            ret_raw["terminal_count"] = trm_c!.first!.data["count"].intValue
                        } else {
                            ret_raw["terminal_count"] = 0
                        }

                        ret.append(ret_raw)

                    }
                    data_return["retailers"] = ret
                }

                response.render(template: "views/retailer.index", context: data_return)
                response.completed()
                
            }
        }
        
        public static func retailerdetail(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                #if !os(macOS)
                guard request.SecurityCheck() else { return response.badSecurityToken }
                #endif
                
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
                
                #if !os(macOS)
                // check to see if the user is permitted to these retailer pages
                let user = request.account
                if user.isNil { return }
                if !user!.bounceRetailerAdmin(schema, retailer_id!) {
                
                }
                #endif

                var data_return:[String:Any] = [:]
                
                data_return["page_retailer_detail"] = true
                data_return["country_id"] = country_id
                data_return["title_label"] = "Retailer Information"

                var ret:[[String:Any]] = []

                // lets grab the retailer info
                var sql = "SELECT * FROM \(schema).retailer WHERE id = \(retailer_id!);"
                let r = Retailer()
                let r_r = try? r.sqlRows(sql, params: [])
                if r_r.isNotNil {
                    for r_d in r_r! {
                        let reta = Retailer()
                        reta.to(r_d)
                        ret.append(reta.asDictionary())
                        data_return["title"] = reta.name!
                        data_return["subtitle"] = nil
                    }
                    data_return["retailer"] = ret
                }
                
                // get the addresses
                sql = "SELECT * FROM \(schema).address AS ad WHERE ad.retailer_id = \(retailer_id!) "
                sql.append("ORDER BY id ASC;")
                let a = Address()
                let a_r = try? a.sqlRows(sql, params: [])
                if a_r.isNotNil {
                    var ret:[[String:Any]] = []
                    for a_d in a_r! {
                        let addr = Address()
                        addr.to(a_d)
                        var address = addr.asDictionary()
                        
                        // get the terminals
                        let sql_t = "SELECT * FROM \(schema).terminal WHERE address_id = \(addr.id!) AND retailer_id = \(addr.retailer_id!) "
                        var terminals:[[String:Any]] = []
                        let trm = Terminal()
                        let trm_r = try? trm.sqlRows(sql_t, params: [])
                        if trm_r.isNotNil, trm_r!.count > 0 {
                            for trm_d in trm_r! {
                                let t = Terminal()
                                t.to(trm_d)
                                terminals.append(t.asDictionary())
                            }
                            
                            if terminals.count > 0 {
                                address["terminals"] = terminals
                            }
                        }

                        ret.append(address)

                    }
                    data_return["addresses"] = ret
                }

                response.render(template: "views/retailer.detail", context: data_return)
                response.completed()
                
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

        //MARK: --
        public static func retailerterminal(data: [String:Any]) throws -> RequestHandler {
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
