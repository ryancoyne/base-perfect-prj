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
        
        //MARK: - Close Interval Function
        public static func redeemCode(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Okay.  We are redeeming a qr code transaction for a user.
                
            }
        }
        
    }
}

fileprivate extension HTTPResponse {

}
