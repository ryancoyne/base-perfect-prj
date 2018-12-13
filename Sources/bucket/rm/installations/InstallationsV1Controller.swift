//
//  InstallationsV1Controller.swift
//  findapride
//
//  Created by Ryan Coyne on 7/28/17.
//
//

import Foundation
import StORM
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

struct InstallationsV1Controller {
        
    struct json {
        static var routes : [[String:Any]] {
            return [["method":"post",   "uri":"/api/v1/installation", "handler": saveInstallation]
            ]
            
        }
        
        //MARK: - saveInstallation
        public static func saveInstallation(_ data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in
            
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                do {
                    let json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    // Okay we have json:
                    let inst = Installation()
                    var uid: String = ""
                    
                    if let session = request.session {
                        inst.user_id = session.userid
                        uid = inst.user_id!
                    }
                    
                    if json["id"].intValue.isNotNil {
                        inst.id = json["id"].intValue!
                        // We need to check if this id exists.
                        guard Installation.exists(inst.id!) else { return response.installIdDNE(inst.id!) }
                    }
                    
                    if json["devicetoken"].stringValue.isNotNil {
                        inst.devicetoken = json["devicetoken"].stringValue!
                    }
                    
                    if json["devicetype"].stringValue.isNotNil {
                        inst.devicetype = json["devicetype"].stringValue!
                    }
                    
                    if json["name"].stringValue.isNotNil {
                        inst.name = json["name"].stringValue!
                    }
                    
                    if json["systemname"].stringValue.isNotNil {
                        inst.systemname = json["systemname"].stringValue!
                    }
                    
                    if json["systemversion"].stringValue.isNotNil {
                        inst.systemversion = json["systemversion"].stringValue!
                    }
                    
                    if json["model"].stringValue.isNotNil {
                        inst.model = json["model"].stringValue!
                    }
                    
                    if json["localizedmodel"].stringValue.isNotNil {
                        inst.localizedmodel = json["localizedmodel"].stringValue!
                    }
                    
                    if json["identifierforvendor"].stringValue.isNotNil {
                        inst.identifierforvendor = json["identifierforvendor"].stringValue!
                    }
                    
                    if json["timezone"].stringValue.isNotNil {
                        inst.timezone = json["timezone"].stringValue!
                    }
                    
                    if json["acceptedterms"].intValue.isNotNil {
                        inst.acceptedterms = json["acceptedterms"].intValue!
                    }
                    
                    if json["declinedterms"].intValue.isNotNil {
                        inst.declinedterms = json["declinedterms"].intValue!
                    }
                    
                    // save this way to make sure nil variables are correctly saved
                    do {
                        
                        var retrow:[StORMRow] = []
                        
                        if uid.isEmpty {
                            retrow = try inst.saveWithCustomType()
                        } else {
                            retrow = try inst.saveWithCustomType(schemaIn: "public",uid)
                        }
                        
                        if retrow.count > 0, let installationid = retrow.first?.data["id"].intValue {
                            // This is a new object!
                            
                            // grab the new record (or existing record)
                            try inst.get(installationid)
                            
                            inst.dealWithNotificationTable(uid)
                            
                        } else {
                            // This was an update!
                            // grab the new record (or existing record)
                            try inst.get(inst.id!)
                            inst.dealWithNotificationTable(uid)

                        }
                        
                        // setup the return
                        try? response.setBody(json: ["id":inst.id])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .ok)
                        return
                        
                    } catch {
                        // there was a problem with the saves
                        try? response.setBody(json: ["error":"Problems saving the installation and notification"])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .custom(code: 420, message: "Chill dude...... The required parameters were not passed."))
                        return
                    }
                    
                } catch BucketAPIError.unparceableJSON(let attemptedJSON) {
                    return response.invalidRequest(attemptedJSON)
                } catch {
                    try? response.setBody(json: ["error":error.localizedDescription])
                        .setHeader(.contentType, value: "application/json; charset=UTF-8")
                        .completed(status: .internalServerError)
                    return
                }
                
            }
        }
    }
}

fileprivate extension HTTPResponse {
    func  installIdDNE(_ installationId: Int) -> Void {
        return try! self.setBody(json: ["errorCode":"InstallationId", "message":"The installation id '\(installationId)' does not exist."])
                                 .completed(status: .ok)
    }
}
