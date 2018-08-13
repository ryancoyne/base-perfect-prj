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

fileprivate extension HTTPRequest {
    
//    @available(*, deprecated, message: "no longer available in version v1.1")
    var retailerId : String? {
        return self.header(.custom(name: "retailerId")) ?? self.urlVariables["retailerId"]
    }
    var retailerSecret : String? {
        return self.header(.custom(name: "x-functions-key"))
    }
    var terminalId : String? {
        let theTry = try? self.postBodyJSON()?["terminalId"].stringValue
        if theTry.isNil {
            return nil
        } else {
            return theTry!
        }
    }
    
    var terminal : Terminal? {
        // Lets see if we have a terminal from the input data:
        // They need to input the x-functions-key as their retailer password.
        return nil
    }
    
}
