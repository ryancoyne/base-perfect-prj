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
            ]
        }
        
        //MARK: - User Stats Function
        public static func userStats(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { response.badSecurityToken; return }

                guard Account.adminBouce(request, response) else { response.accountPermissionsBounce; return  }
                
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
                return
            }
        }
        
        //MARK: - User Stats Function
        public static func processSuttonBatchAll(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
//                guard request.SecurityCheck() else { response.badSecurityToken; return }
                
//                guard Account.adminBouce(request, response) else { response.accountPermissionsBounce; return  }
                
                // breate the batch
                SuttonFunctions.batchAll()
                
                // process the newly created batch
                let bp = BatchProcessing()
                bp.processSutton()
                
                // and render the template (once we have the template complete)
                response.render(template: "views/batch")
                response.completed()
                return
            }
        }
    }
}
