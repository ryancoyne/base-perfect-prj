//
//  InstallationsAPI.swift
//  findapride
//
//  Created by Mike Silvers on 10/13/17.
//
//

import Foundation
import PerfectHTTP
import PerfectLocalAuthentication

struct InstallationsAPI {
    
    static func saveInstallation(_ request : HTTPRequest, _ dic : [String:Any]) throws -> [String:Any] {
        
        // we already tested to see if they are logged in
        let session = request.session!
        
        var returndict:[String:Any] = [:]
        
        var fields:[String:Any] = [:]
        
        if let data = dic["user_id"] as? String {
            fields["user_id"] = data
        } else {
            fields["user_id"] = session.userid
        }
        
        if let data: String = dic["devicetoken"] as? String {
            fields["devicetoken"] = data
        }
        
        if let data: String = dic["devicetype"] as? String {
            fields["devicetype"] = data
        }
        
        if let data: String = dic["name"] as? String {
            fields["name"] = data
        }
        
        if let data: String = dic["systemname"] as? String {
            fields["systemname"] = data
        }
        
        if let data: String = dic["systemversion"] as? String {
            fields["systemversion"] = data
        }
        
        if let data: String = dic["model"] as? String {
            fields["model"] = data
        }
        
        if let data: String = dic["localizedmodel"] as? String {
            fields["localizedmodel"] = data
        }
        
        if let data: String = dic["identifierforvendor"] as? String {
            fields["identifierforvendor"] = data
        }
        
        if let data: Int = dic["acceptedterms"].intValue {
            fields["acceptedterms"] = data
        }
        
        if let data: Int = dic["declinedterms"].intValue {
            fields["declinedterms"] = data
        }
        
        var updateme = false
        
        if fields["devicetoken"].isNotNil {
            // lets lookup to see if it exists already
            let current1 = try? Installation().sqlRows("SELECT id FROM installations WHERE id = $1 AND user_id = $2", params: [fields["devicetoken"] as! String, fields["user_id"] as! String])
            
            var thesqlis = ""
            var thesqlparms = ""
            var theupdatesql = ""
            
            if current1.isNotNil, let current = current1 {
                if current.count > 0 {
                    fields["modified"] = RMServiceClass.getNow()
                    fields["modifiedby"] = session.userid
                    updateme = true
                } else {
                    fields["created"] = RMServiceClass.getNow()
                    fields["createdby"] = session.userid
                }
            
                for (field, value) in fields {
                
                    var thef = field
                
                    if field == "devicetoken" {
                        thef = "id"
                    }
                    thesqlis.append(thef)
                    thesqlis.append(",")
                
                    if thef == "created" || thef == "modified" || thef == "declinedterms" || thef == "acceptedterms" {
                        thesqlparms.append(String(value as! Int))
                        thesqlparms.append(",")
                    
                        theupdatesql.append("\(thef)=\(value as! Int),")
                    } else {
                        thesqlparms.append("'")
                        thesqlparms.append(value as! String)
                        thesqlparms.append("',")
                    
                        if thef != "id" {
                            theupdatesql.append("\(thef)='\(value as! String)',")
                        }
                    }
                }
            
                // remove the last comma
                thesqlis.removeLast()
                thesqlparms.removeLast()
                theupdatesql.removeLast()
            
                // setup the SQL
                var runmesql = ""
            
                if updateme {
                    runmesql = "UPDATE installations SET \(theupdatesql) WHERE 'id' = '\(fields["devicetoken"] as! String)' "
                } else {
                    runmesql = "INSERT INTO installations (\(thesqlis)) VALUES(\(thesqlparms))"
                }
            
                do {
                    try Installation().sqlRows(runmesql, params: [])
            
                    returndict["id"] = fields["devicetoken"]
                } catch {
                    print("Error in InstallationAPI.saveInstallation(): \(error)")
                }
            } else {
                returndict = RMServiceClass.sharedInstance.ResultFailure
            }
        } else {
            returndict = RMServiceClass.sharedInstance.ResultFailure
        }
        
        // set it up with the return data set.
        let returnD = ["result":returndict]
        
        return returnD
        
    }
}

