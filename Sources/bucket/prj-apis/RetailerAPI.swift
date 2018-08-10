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
                
                // If this is development, then we can automatically verify the device.  If we are production, then we will make them to go the web and verify the device is theirs.
                do {
                    let json = try request.postBodyJSON()
                
                    guard !json!.isEmpty else { return response.emptyJSONBody }
                    
                    guard let retailerId = json?["retailerId"].stringValue else { return response.invalidRetailer }
                    guard let serialNumber = json?["terminalId"].stringValue else { return response.noTerminalId }
                
                    //TODO: Process the request:
                    
                } catch BucketAPIError.unparceableJSON(let invalidJSONString) {
                    return response.invalidRequest(invalidJSONString)
                
                } catch {
                    // Not sure what error could be thrown here, but the only one we throw right now is if the JSON is unparceable.
                    
                }
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

fileprivate extension HTTPResponse {
    var invalidRetailer : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRetailer", "message":"Please Check Retailer Id"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .unauthorized)
    }
    var noTerminalId : Void {
        return try! self
            .setBody(json: ["errorCode":"NoTerminalId", "message":"You must send in a 'terminalId' key with the serial number of the device as the value."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .unauthorized)
    }
}

fileprivate extension HTTPRequest {
    var retailerId : String? {
        return self.urlVariables["retailerId"]
    }
    
    var terminal : Terminal? {
        // Lets see if we have a terminal from the input data:
        // They need to input the x-functions-key as their retailer password.
        return nil
    }
    
}
