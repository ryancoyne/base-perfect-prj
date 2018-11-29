//
//  AdminAPI.swift
//  bucket
//
//  Created by Mike Silvers on 8/29/18.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession
import SwiftMoment

//MARK: - Admin API
/// This Admin structure supports all the normal endpoints for a user based login application.
struct AdminAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
//                ["method":"post",    "uri":"/api/v1/admin/userStats", "handler":userStats],
                ["method":"post",    "uri":"/api/v1/admin/suttonBatchAll", "handler":processSuttonBatchAll],
                
                // Cashout Group Management (Admin Only)
                // Create & Update:
                ["method":"post",    "uri":"/api/v1/cashout/groups", "handler":createOrUpdateCashoutGroup],
                // Delete:
                ["method":"delete",    "uri":"/api/v1/cashout/groups", "handler":deleteGroup],
            ]
        }
        
        //MARK: - Cashout Group Create or Update
        public static func createOrUpdateCashoutGroup(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                let bounce = Account.adminBouce(request, response)
                guard !bounce.fails else { return response.accountPermissionsBounce }
                
                
                
            }
        }
        
        public static func deleteGroup(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                let bounce = Account.adminBouce(request, response)
                guard !bounce.fails else { return response.accountPermissionsBounce }
                
                // Make sure we have the correct schema:
                let schema = Country.getSchema(request)
                guard schema != "public" else { return response.invalidCountryCode }
                
                do {
                    
                    let json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    // Okay.. lets see if we are updating or creating:
                    if json.id.isNil {
                        // We are creating a new group:
                        
                    } else {
                        // Okay, we are UPDATING:
                        let theGroup = CashoutGroup()
                        if let theGroupResult = try? theGroup.sqlRows("SELECT * FROM \(schema).cashout_group WHERE id = \(json.id!)", params: []).first, theGroupResult.isNotNil {
                            theGroup.to(theGroupResult!)
                            if theGroup.deleted.isNotNil { return response.alreadyDeleted }
                            
                            theGroup.deleted = CCXServiceClass.getNow()
                            theGroup.deletedby = bounce.user?.id
                            
                        } else {
                            return response.groupDNE
                        }
                        if let description = json["description"].stringValue {
                            
                        }
                    }
                    
                } catch BucketAPIError.unparceableJSON(let theStr) {
                    return response.invalidRequest(theStr)
                } catch {
                    return response.caughtError(error)
                }
                
            }
        }
        
        //MARK: - User Stats Function
        public static func userStats(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                let bounce = Account.adminBouce(request, response)
                guard !bounce.fails else { return response.accountPermissionsBounce }
                
                let user = Account()
                let _ = try? user.get((request.session!.userid as String))
                
                // now we can differentiate between user types (user.usertype)
                
                // Okay.. they are good to go.  Lets get the user stats
                
                // number of retailers
                
                // number of codes issued per retailer (red color indicates "stale" retailers)
                
                // number of accounts
                
                // number of "stale" accounts
                
                // number of unclaimed codes per country
                
                // number of claimed codes in the last 24 hours
                
                
                // and render the template (once we have the template complete)
                response.render(template: "views/forgotpassword")
                response.completed()

            }
        }
        
        //MARK: - User Stats Function
        public static func processSuttonBatchAll(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
//                guard Account.adminBouce(request, response) else { response.accountPermissionsBounce; return  }
                
                // breate the batch
                SuttonFunctions.batchAll()
                
                // process the newly created batch
                let bp = BatchProcessing()
                bp.processSutton()
                
                // and render the template (once we have the template complete)
                response.render(template: "views/batch")
                response.completed()
                
            }
        }
    }
}

fileprivate extension HTTPResponse {
    var groupDNE : Void {
        return try! self.setBody(json: ["errorCode":"GroupDNE", "message": "The group id does not exist."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 404, message: "The Group Id does not exist."))
    }
    var alreadyDeleted : Void {
        return try! self.setBody(json: ["errorCode":"GroupAlreadyDeleted", "message": "The group has already been deleted."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 404, message: "The Group Id does not exist."))
    }
}
