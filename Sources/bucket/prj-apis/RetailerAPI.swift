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
                    
                    // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                    let terminal = Terminal()
                    let theTry = try? terminal.find(["serial_number": serialNumber])
                    if theTry.isNil { /* It failed... we may want to do something here? */ }
                    
                    // Check and make sure the terminal is approved or not:
                    if terminal.id.isNil {
                        // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
                        let term = Terminal()
                        
                        term.serial_number = serialNumber
                        term.retailer_id = Int(retailerId)
                        
                        let results = try term.saveWithGIS()
                        
                        try? response.setBody(json: [])
                                                 .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                                 .completed(status: .created)

                        // We want to do the following after the 201 to give back the password.
//                        // Create the new password:
//                        let retailerSecret = UUID().uuidString
//                        guard let hexBytes = retailerSecret.digest(.sha256), let validate = hexBytes.encode(.hex), let theSavedPassword = String(validatingUTF8: validate)  else { return  }
//
//                        term.terminal_key = theSavedPassword
                        
                    } else {
                        // The terminal does exist.  Lets see if we retailer id is the same as what they are saying:
                        
                    }
                
                    
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
            
                Retailer.retailerBounce(request, response)
                
                do {

                    // we are using the json variable to return the code too.
                    var json = try request.postBodyJSON()
                    
                    json!["retailerId"] = request.retailerId ?? ""

                    // get the code
                    let ccode = Retailer().createCustomerCode(json!)
                    
                    // put together the return dictionary
                    if ccode.success {
                        json!["customerCode"] = ccode.message
                        
                    }
                    
                    try? response.setBody(json: json!)
                        .completed(status: .ok)
                    
                } catch BucketAPIError.unparceableJSON(let invalidJSONString) {
                    return response.invalidRequest(invalidJSONString)
                    
                } catch {
                    // Not sure what error could be thrown here, but the only one we throw right now is if the JSON is unparceable.
                    
                }
                
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
    var unauthorizedRetailer : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRetailer", "message":"Please Check Retailer Id and Secret Code."])
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


extension Retailer {

    public static func retailerBounce(_ request: HTTPRequest, _ response: HTTPResponse) {
        
        //Make sure we have the retailer Id and retailer secret:
        guard let retailerSecret = request.retailerSecret, let retailerId = request.retailerId else { return response.unauthorizedRetailer }
        guard let terminalSerialNumber = request.terminalId else { return response.noTerminalId }
        
        // Get our secret code formatted properly to check what we have in the DB:
        if let digestBytes = retailerSecret.digest(.sha256), let hexBytes = digestBytes.encode(.hex), let hexByteString = String(validatingUTF8: hexBytes) {
            // Essentially, we need to make sure a record for the retailer Id exists, and then also make sure we can find a record for the terminal with its serial number and the retailer secret key:
            
            let terminalQuery = Terminal()
            let response = try? terminalQuery.find(["terminal_key":hexByteString, "serial_number":terminalSerialNumber])
            
            if response.isNil { /* See what we should do here. */ }
            // Make sure the retailer_id is the same as whats passed in, otherwise, theres an issue with this device.  See Status Code 409:
            
        }

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
