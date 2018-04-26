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
            return [["method":"post",   "uri":"/api/v1/externalservices", "handler":postServices],
            ]
        }
        //MARK:-
        //MARK: - Post Services Functions:
        public static func postServices(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in. - we will also allow requests fom localhost
                
                var session:PerfectSession? = nil
                var oktorun = false
                let host = request.remoteAddress.host
                
                if let thesession = request.session, !thesession.userid.isEmpty {
                    session = thesession
                    oktorun = true
                } else if host == "localhost" {
                    oktorun = true
                } else {
                    return response.notLoggedIn()
                }

                // lets get the list of the friends...
                // {
                //      "service": {
                //          "service1":true,
                //          "service2":true
                //      }
                // }
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

        public static func addFriend(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                // Check if the user is logged in.
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
                
                // Okay lets add the friends.
                if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    if let id = json?["id"].stringValue {
                        try? response.setBody(json: Friends.addFriend(id, session))
                                                .setHeader(.contentType, value: "application/json")
                                                .completed(status: .ok)
                    } else {
                        // Return bad request - no post body:
                        try? response.setBody(json: ["error":"Please give an id or an array of ids in post body."])
                                                .setHeader(.contentType, value: "application/json")
                                                .completed(status: .badRequest)
                    }
                }
            }
        }
        public static func deleteFriend(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                // Check if the user is logged in.
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
                
                // Okay lets delete the friends:
                if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    
                    var retDict:[String:Any] = [:]
                    
                    if let id = json?["id"].stringValue {
                        if let _ = json?["rejected"].boolValue {
                            // they are rejecting this friend
                            let success = Friends.deleteFriend(id, session, true)
                            if success {
                                retDict = ["result":"success"]
                            } else {
                                retDict = ["result":"failure"]
                            }
                        } else {
                            // deleting the friend outright
                            let success = Friends.deleteFriend(id, session, false)
                            if success {
                                retDict = ["result":"success"]
                            } else {
                                retDict = ["result":"failure"]
                            }
                        }
                    } else {
                        try? response.setBody(json: ["error":"Please give an id or an array of ids in post body."])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .badRequest)
                    }
                    
                    // return the ok response (didn't get caught by the bad request)
                    try? response.setBody(json: retDict)
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)
                }
            }
        }
    }
}
