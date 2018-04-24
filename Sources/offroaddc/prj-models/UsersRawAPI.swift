//
//  CCXStatisticsAPI.swift
//  findapride
//
//  Created by Mike Silvers on 10/13/17.
//
//

import Foundation
import PerfectHTTP
import PerfectLocalAuthentication

struct RawUsersAPI {
    
    // {
    //      "source":"<stages, mindbody>"
    // }
    
    
    
    //MARK:-
    //MARK: JOSN functions
    struct json {
        static var routes : [[String:Any]] {
            return [["method":"post","uri":"/api/v1/remoteusers/sync", "handler": remoteUsersSync]
            ]
        }
        
        static func remoteUsersSync(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // security
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
                
                do {
                    let incoming = request.postBodyString
                    var data:[String:Any] = [:]
                    
                    if let coredata = try incoming?.jsonDecode() as? [String:Any] {
                        data = coredata
                    }
                    
                    var json:[String:Any] = [:]
                    
                    if let sync_source_request: String = data["source"] as? String {
                        if sync_source_request == "stages" {
                            StagesConnecter.sharedInstance.retrieveUsers()
                            
                        } else if sync_source_request == "mindbody" {
                            json = ["error":"\(sync_source_request.capitalize()) is not implemented at this time"]
                            try response.setBody(json: json)
                            response.setHeader(.contentType, value: "application/json")
                            response.completed(status: .badRequest)
                        } else {
                            json = ["error":"\(sync_source_request.capitalize()) is not implemented at this time"]
                            try response.setBody(json: json)
                            response.setHeader(.contentType, value: "application/json")
                            response.completed(status: .badRequest)
                        }
                    } else {
                        // nothing else is setup yet -- this is where we setup for company stats and such
                        json = ["error":"The sync source was not submitted"]
                        try response.setBody(json: json)
                        response.setHeader(.contentType, value: "application/json")
                        response.completed(status: .badRequest)
                    }
                    
                    try response.setBody(json: json)
                    response.setHeader(.contentType, value: "application/json")
                    response.completed(status: .ok)
                    
                } catch {
                    response.completed(status: HTTPResponseStatus.custom(code: 500, message: error.localizedDescription))
                }
            }
        }
    }
}
