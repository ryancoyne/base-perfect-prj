//
//  RetailerAPI.swift
//  COpenSSL
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession

//MARK: - Retailer API
/// This Retailer structure supports all the normal endpoints for a user based login application.
struct ConsumerAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
                ["method":"get",    "uri":"/api/v1/redeem/{customerCode}", "handler":redeemCode]
            ]
        }
        
        //MARK: - Redeem The Transaction:
        public static func redeemCode(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard let userId = request.session?.userid else { return response.notLoggedIn() }
                
                // Okay, the user is logged in and we have their id!  Lets see if we have the customer code!
                guard let customerCode = request.customerCode else { return response.invalidCode }
                
                // Awesome.  We have the customer code, and a user.  Now, we need to find the transaction and mark it as redeemed, and add the value to the ledger table!
                
                
            }
        }
    }
}

fileprivate extension HTTPResponse {
    var invalidCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such code found"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .notAcceptable)
    }
}

fileprivate extension HTTPRequest {
//    @available(*, deprecated, message: "no longer available in version v1.1")
    var customerCode : String? {
        return self.urlVariables["customerCode"]
    }
}
