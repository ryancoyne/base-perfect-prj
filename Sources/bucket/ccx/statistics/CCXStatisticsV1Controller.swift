//
//  CCXStatisticsV1Controller.swift
//  findapride
//
//  Created by Ryan Coyne on 7/28/17.
//
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectLocalAuthentication

struct CCXStatisticsV1Controller {

    //MARK:-
    //MARK: JOSN functions
    struct json {
        static var routes : [[String:Any]] {
            return [["method":"post","uri":"/api/v1/ccx/stats", "handler": getAdminStatistics]
            ]
        }
    
    static func getAdminStatistics(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in

            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.SecurityCheck() else { response.badSecurityToken; return }

            // security
            guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
        
                do {
                    let incoming = request.postBodyString
                    var data:[String:Any] = [:]
                    
                    if let coredata = try incoming?.jsonDecode() as? [String:Any] {
                        data = coredata
                    }
                
                    var json:[String:Any] = [:]
                
                    if let levelrequest: String = data["stats"] as? String, levelrequest == "admin" {
                        json = try CCXStatisticsAPI.getAdminStatistics(data)
                    } else {
                        // nothing else is setup yet -- this is where we setup for company stats and such
                        json = ["error":"Not implemented at this time"]
                        try response.setBody(json: json)
                        response.setHeader(.contentType, value: "application/json")
                        response.completed(status: .badRequest)
                    }
                
                    try response.setBody(json: json)
                    response.setHeader(.contentType, value: "application/json")
                    response.completed(status: .ok)
                
                } catch {
                    response.caughtError(error)
                    return
                }
            }
        }
    }
    
    //MARK:-
    //MARK: Web functions
    struct web {
        static var routes : [[String:Any]] {
            return [["method":"get","uri":"/ccx/stats", "handler": getAdminStatisticsWeb]
            ]
        }

        public static func getAdminStatisticsWeb(_ data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in

                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { response.badSecurityToken; return }

                // security
                let contextAccountID = request.session?.userid ?? ""
                let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
                if !contextAuthenticated { response.redirect(path: "/login") }
                
                // Verify Admin
                Account.adminBounce(request, response)

                // get the dictionary of stats:
                var thestats:[String:Any] = [:]
                do {
                    try thestats = CCXStatisticsAPI.getAdminStatistics(["breadcrumbs":false])
                } catch {
                    // if there was an error, let them know that there was an error
                    thestats =  ["error":error.localizedDescription]
                }
                
                // break out the context stuff
                var context: [String : Any] = [
                    "accountID": contextAccountID,
                    "authenticated": contextAuthenticated,
                ]
                
                // back it down to the core data of the return
                let thereturn = thestats["result"] as! [String:Any]
                
                // process the sections that came back
                if let err = thereturn["error"] {
                    context["error_true?"] = true
                    context["error"] = err
                }
                
                if let accounts = thereturn["accounts"] {
                    context["accounts_true?"] = true
                    context["accounts"] = accounts
                }

                if let breadcrumbs = thereturn["breadcrumbs"] {
                    context["breadcrumbs_true?"] = true
                    context["breadcrumbs"] = breadcrumbs
                }

                if contextAuthenticated {
                    for i in Handlers.extras(request) {
                        context[i.0] = i.1
                    }
                }
                // add app config vars
                for i in Handlers.appExtras(request) {
                    context[i.0] = i.1
                }
                //show the stats we just generated
                response.renderMustache(template: request.documentRoot + "/views/ccx.admin.stats.mustache", context: context)
            }
        }
      }
    
}
