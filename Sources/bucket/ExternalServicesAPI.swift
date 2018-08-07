//
//  ExternalServicesAPI.swift
//
//  Created by Mike Silvers on 04/26/18.
//

import PostgresStORM
import PerfectSession
import PerfectHTTP
import PerfectLib

//MARK: - External Services API
/// This ExternalServicesAPI structure supports all the normal endpoints for updates and interaction with the external services.
struct ExternalServicesAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [["method":"post",   "uri":"/api/v1/remoteusers/sync", "handler":postServices],
            ]
        }
        //MARK:-
        //MARK: - Post Services Functions:
        public static func postServices(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in. - we will also allow requests fom localhost
                
                let host = request.remoteAddress.host
                
                if let thesession = request.session, !thesession.userid.isEmpty {
                    // this is good - logged in user
                } else if host == "localhost" || host == "127.0.0.1" || host == "::1" {
                    // this is good - from loalhost
                } else {
                    // nope - lets not do this now
                    return response.notLoggedIn()
                }

                // lets get the list of the friends...
                // {
                //      "service": {
                //          "service1":true,
                //          "service2":true
                //      }
                // }
                //
                // Testing using CURL:
                //
                //  curl -d '{ "service" : { "service1" : true, "service2" : true } }'  -H "Content-Type: application/json" -X POST http://localhost:9000/api/V1/externalservices
                //
                
                if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    
                    var returnDict:[String:Any] = [:]
                    
                    if let em = json?["service"] as? [String:Any] {
                        
                        if let em1 = em["service1"].boolValue {
                            
                            if em1 {
                                // do first server....
                                let ret1 = ExternalServicesConnecter.sharedInstance.server1SyncUsers()
                                
                                for (key, value) in ret1 {
                                    returnDict[key] = value
                                }
                                
                            } else {
                                    
                            }
                        }
                        
                        
                    } else {
                        // ERROR: there was no request
                        try? response.setBody(json: ["error":"Your request was not correct."])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .custom(code: 420, message: "Chill dude...... The required parameters were not passed."))
                    }

                    try? response.setBody(json: returnDict)
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)

                } else {
                    // ERROR: there was no request
                    try? response.setBody(json: ["error":"Your request was not correct.  You should probably pass the correct parameters."])
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .custom(code: 421, message: "The required parameters were not passed."))
                }
            }
        }
    }
}
