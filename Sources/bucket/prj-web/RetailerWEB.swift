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
                ["method":"get", "uri":"/retailer/index/{countryId}", "handler":retailer_index],
                ["method":"get", "uri":"/retailer/add/{countryId}", "handler":retailer_add],
                ["method":"get", "uri":"/retailer/detail/{countryId}/{retailerId}", "handler":retailer_detail],
//                ["method":"get", "uri":"/retailer/{countryId}/{retailerId}/terminal/add", "handler":retailer_add_terminal],
//                ["method":"get", "uri":"/retailer/{countryId}/{retailerId}/terminal/{terminalId}", "handler":retailer_terminal],
//                ["method":"get", "uri":"/retailer/{countryId}/{retailerId}/address/{addressId}", "handler":retailer_address],
//                ["method":"get", "uri":"/retailer/{countryId}/{retailerId}/terminals", "handler":retailer_add_address],
            ]
        }
        
        //MARK: --
        //MARK: Retailer list page

        //MARK: --
        public static func retailer_index(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in

print("retailer_index START: Cookie Name: \(SessionConfig.name)")
print("retailer_index START: Cookie Value: \(request.getCookie(name: SessionConfig.name) ?? "No Cookie Value")")

                var msg_return:[[String:Any]] = []
                var data_return:[String:Any] = [:]
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }

                // grab the country id
                let country_id = request.countryId
                var schema = ""
                if country_id.isNotNil {
                    schema = Country.getSchema(country_id!)
                }
                
                var nothere = false
                if schema.isEmpty || country_id.isNil {
                    // there is an error with the country ID
                    msg_return.append(["msg_body":"We currently are not in this country.  Please try again later."])
                    nothere = true
                }
                
                // check to see if the user is permitted to these retailer pages
                let user = request.account
                if (user.isNil && !nothere) || user.isNil {
                    msg_return.append(["msg_body":"Please login to access this section."])
                    data_return["require_login"] = true
                } else if !nothere {
                    if !(user!.isRetailerStandard() || user!.isBucketStandard()) {
                        msg_return.append(["msg_body":"Please login correctly to access this section."])
                        data_return["require_login"] = true
                    }
                }
                
                data_return["title_label"] = "Retailer Information"

                data_return["page_retailer"] = true
                
                if country_id.isNotNil {
                    
                    data_return["country_id"] = country_id
                    let ctry = Country()
                    let _ = try? ctry.get(country_id!)
                    if ctry.name.isNotNil {
                        data_return["title"] = ctry.name!
                        data_return["subtitle"] = ctry.code_alpha_2?.lowercased()
                    }
                } else {
                    data_return["title"] = "Unsupported Country"
                    data_return["subtitle"] = "**"
                }
                
                // only look up the retailers if there is a schema to use
                if !schema.isEmpty && user.isNotNil {

                    var sql = ""
                    
                    // lets grab the retailers for the country
                    if (user!.isRetailerStandard() || user!.isRetailerAdmin()), let r_id = user?.detail["retailer_id"].stringValue {
                        sql = "SELECT * FROM \(schema).retailer WHERE id = \(r_id) ORDER BY name DESC;"
                    } else if (user!.isBucketAdmin() || user!.isBucketStandard()) {
                        sql = "SELECT * FROM \(schema).retailer ORDER BY name DESC;"
                    }
                    
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

                }

                if msg_return.count > 0 {
                    data_return["error_messages"] = msg_return
                }

print("retailer_index END: Cookie Name: \(SessionConfig.name)")
print("retailer_index END: Cookie Value: \(request.getCookie(name: SessionConfig.name) ?? "No Cookie Value")")

                response.addSourcePage("/retailer/index/\(country_id ?? 0)")
                
                data_return["sourcePage"] = "/retailer/index/\(country_id ?? 0)"
                response.render(template: "views/retailer.index", context: data_return)
                response.completed()
                
            }
        }
        
        public static func retailer_detail(data: [String:Any]) throws -> RequestHandler {
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

        public static func retailer_add(data: [String:Any]) throws -> RequestHandler {
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
                
                // make sure the user has authority to access the retailer information
                if country_id.isNil { response.invalidCountryCode; return }
                
                #if !os(macOS)
                // check to see if the user is permitted to these retailer pages
//                let user = request.account
//                if user.isNil { return }
//                if !user!.bounceRetailerAdmin(schema, retailer_id!) {
                    
//                }
                #endif
                
                var data_return:[String:Any] = [:]
                
                data_return["page_retailer_add"] = true
                data_return["country_id"] = country_id
                data_return["title_label"] = "Add A Retailer"
                
                var ret:[[String:Any]] = []
                
                // lets grab the retailer info
                
                response.render(template: "views/retailer.add", context: data_return)
                response.completed()
                
            }
        }

    }
}
