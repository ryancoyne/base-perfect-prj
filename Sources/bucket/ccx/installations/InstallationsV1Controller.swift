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
                
                if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    if let json = json {
                        
                        let inst = Installation()
                        
                        if json.isEmpty {
                            try? response.setBody(json: ["error":"Empty json"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .custom(code: 420, message: "Chill dude...... The required parameters were not passed."))
                        }
                        
                        var uid: String = ""
//                        if let session = request.session, !session.userid.isEmpty {
                        if let session = request.session {
                            inst.user_id = session.userid
                            uid = inst.user_id!
                        }
                        
                        if json["id"].intValue.isNotNil {
                            inst.id = json["id"].intValue!
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
                                retrow = try! inst.saveWithCustomType()
                            } else {
                                retrow = try! inst.saveWithCustomType(uid)
                            }
                            
                            if retrow.count > 0, let installationid = retrow.first?.data["id"].intValue {
                                
                                // grab the new record (or existing record)
                                try inst.get(installationid)
                                
                                // only deal with the notification record if there is a device token (it means that there is a yes to get notifications)
                                if inst.devicetoken.isNotNil {
                                    
                                    var therewerechanges = false
                                    
                                    let notif = Notification()
                                    
                                    do {
                                        try notif.find([("devicetoken", inst.devicetoken!)])
                                        
                                        // now lets set the stuff....
                                        if notif.id.isNil {
                                            notif.devicetoken = inst.devicetoken
                                            therewerechanges = true
                                        }
                                        if inst.devicetype.isNotNil && inst.devicetype != notif.devicetype {
                                            notif.devicetype = inst.devicetype
                                            therewerechanges = true
                                        }
                                        if inst.user_id.isNotNil && inst.user_id != notif.user_id {
                                            notif.user_id = inst.user_id
                                            therewerechanges = true
                                        }
                                        if inst.timezone.isNotNil && inst.timezone != notif.timezone {
                                            notif.timezone = inst.timezone
                                            therewerechanges = true
                                        }
                                        
                                        // now lets try to save this notification
                                        if therewerechanges {
                                            try notif.saveWithCustomType(uid)
                                        }
                                    } catch {
                                        // do NOTHING - there was a problem with the notification record.
                                    }
                                    
                                }
                                
                            }
                            
                            // setup the return
                            try? response.setBody(json: ["id":inst.id])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .ok)

                        } catch {
                            // there was a problem with the saves
                            try? response.setBody(json: ["error":"Problems saving the installation and notification"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .custom(code: 420, message: "Chill dude...... The required parameters were not passed."))
                            
                        }
                    }
                } else {
                    // this is the end of the json decode
                    try? response.setBody(json: ["error":"Problems saving the installation and notification"])
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .custom(code: 420, message: "Chill dude...... The required parameters were not passed."))
                    
                }
            }
        }
    }
}
