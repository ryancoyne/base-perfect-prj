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
struct RetailerAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
                ["method":"get",    "uri":"/api/v1/closeInterval/{retailerId}", "handler":closeInterval],
                ["method":"post",    "uri":"/api/v1/registerterminal", "handler":registerTerminal],
                ["method":"post",    "uri":"/api/v1/transaction/{retailerId}", "handler":createTransaction]
            ]
        }
        //MARK: - Close Interval Function
        public static func closeInterval(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
            
                guard let retailerId = request.retailerId else { return response.completed(status: .forbidden)  }
                
                return response.completed(status: .ok)
                
            }
        }
        //MARK: - Register Terminal Function
        public static func registerTerminal(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                
                
            }
        }
        //MARK: - Create Transaction
        public static func createTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                
            }
        }
    }
}

fileprivate extension HTTPRequest {
    var retailerId : String? {
        return self.urlVariables["retailerId"]
    }
}


extension Retailer {

    public static func retailerBounce(_ request: HTTPRequest, _ response: HTTPResponse) {
        
        let sqlCheck = "SELECT "
        
        let terminal = Terminal()
        
        // this is where we will check the temrminal ID, retailer and the secret to make sure the terminal is approved.
        
        do {
            try terminal.get(request.session?.userid ?? "")
//            if user.usertype != .admin {
//                response.redirect(path: "/")
//            }
        } catch {
            print(error)
        }
    }
 
}
