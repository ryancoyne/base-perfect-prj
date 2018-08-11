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
                    
                    guard let retailerCode = json?["retailerId"].stringValue else { return response.invalidRetailer }
                    guard let serialNumber = json?["terminalId"].stringValue else { return response.noTerminalId }
                    
                    let retailer = Retailer()
                    try? retailer.find(["retailer_code": retailerCode])
                
                    // Lets first check and see if this is a valid retailer:
                    guard retailer.id.isNotNil else { return response.unauthorizedRetailer }
                    
                    switch EnvironmentVariables.sharedInstance.Server {
                    case .production?:
                        // We should do everything like regular here:
                        break
                    case .development?:
                    // We should be automatically making the terminals available:
                        
                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                        let terminal = Terminal()
                        try terminal.find(["serial_number": serialNumber])
                        
                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
                            let term = Terminal()
                            
                            let apiKey = UUID().uuidString
                            term.serial_number = serialNumber
                            term.retailer_id = retailer.id
                            term.terminal_key = apiKey.ourPasswordHash
                            
                            do {
                                
                                try term.saveWithGIS()
                                try? response.setBody(json: ["isApproved":false, "apiKey":apiKey])
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .created)
                                
                            } catch {
                                // TODO:  Return some error:
                                try? response.setBody(json: ["error":error.localizedDescription])
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .internalServerError)
                            }
                            
                        } else if terminal.retailer_id.isNotNil && terminal.is_approved {
                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
                            guard retailer.id! == terminal.retailer_id else { /* Send back an error indicating this device is on another account */  return }
                            
                            // Save the new password, and return the response:
                            let thePassword = UUID().uuidString
                            
                            // Build the response:
                            var responseDictionary = [String:Any]()
                            responseDictionary["isApproved"] = true
                            responseDictionary["apiKey"] = thePassword
                            
                            // Create and assign the hashed password:
                            terminal.terminal_key = thePassword.ourPasswordHash
                            
                            // Save:
                            try terminal.saveWithGIS()
                            
                            // Return the response:
                            try? response.setBody(json: responseDictionary)
                                .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                .completed(status: .ok)
                            
                            // The following case is ONLY for development:
                        } else if terminal.retailer_id.isNotNil && !terminal.is_approved {
                            
                            // First check the retailer id:
                            guard retailer.id! == terminal.retailer_id! else { /* Send back an error indicating this device is on another account */  return response.alreadyRegistered(serialNumber) }
                            
                            terminal.is_approved = true
                            
                            // Lets create the password and send it back:
                            let thePassword = UUID().uuidString
                            
                            // Build the response:
                            var responseDictionary = [String:Any]()
                            responseDictionary["isApproved"] = true
                            responseDictionary["apiKey"] = thePassword
                            
                            // Create and assign the hashed password:
                            guard let hexBytes = thePassword.digest(.sha256), let validate = hexBytes.encode(.hex), let theSavedPassword = String(validatingUTF8: validate)  else { return  }
                            terminal.terminal_key = theSavedPassword
                            
                            // Save:
                            try terminal.saveWithGIS()
                            
                            // Return the response:
                            try? response.setBody(json: responseDictionary)
                                .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                .completed(status: .ok)
                            
                        }
                        
                    default:
                        break
                    }
                    
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
            
                Retailer.retailerTerminalBounce(request, response)
                
                do {

                    // we are using the json variable to return the code too.
                    var json = try request.postBodyJSON()
                    
                    json!["retailerId"] = request.retailerId ?? ""

                    // get the code
                    let ccode = Retailer().createCustomerCode(json!)
                    
                    // put together the return dictionary
                    if ccode.success {
                        
                        json!["customerCode"] = ccode.message
                        
                        var qrCodeURL = ""
                        qrCodeURL.append(EnvironmentVariables.sharedInstance.PublicServerURL?.absoluteString ?? "")
                        qrCodeURL.append("/redeem/")
                        qrCodeURL.append(ccode.message)
                        json!["qrCodeContent"] = qrCodeURL
                        
                        // if we are here then everything went well
                        try? response.setBody(json: json!)
                            .completed(status: .ok)

                    }
                    
                    // we have to work on the correct error return codes
                    // ideas?
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
    func alreadyRegistered(_ serialNumber: String) -> Void {
        return try! self
            .setBody(json: ["errorCode":"AlreadyRegistered", "message":"The terminal with the serial number (\(serialNumber)) is registered to another retailer.  Contact Bucket support."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .conflict)
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

    public static func exists(_ with: String) -> Bool {
        let retailer = Retailer()
        try? retailer.find(["retailer_code":with])
        return retailer.id.isNotNil
    }
    
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

    public static func retailerTerminalBounce(_ request: HTTPRequest, _ response: HTTPResponse) {
        
        //Make sure we have the retailer Id and retailer secret:
        guard let retailerSecret = request.retailerSecret, let retailerId = request.retailerId else { return response.unauthorizedRetailer }
        guard let terminalSerialNumber = request.terminalId else { return response.noTerminalId }
        
        // Get our secret code formatted properly to check what we have in the DB:
        if let digestBytes = retailerSecret.digest(.sha256), let hexBytes = digestBytes.encode(.hex), let hexByteString = String(validatingUTF8: hexBytes) {
            // Essentially, we need to make sure a record for the retailer Id exists, and then also make sure we can find a record for the terminal with its serial number and the retailer secret key:
            
            let terminalQuery = Terminal()
            try? terminalQuery.find(["serial_number":terminalSerialNumber])
            
            // Checking three conditions:
            //  1. The terminal is not registered
            //  2. The terminal is not active
            //  3. The terminal is not for this retailer

            // this means the terminal number is invalid - RETURN the appropriate error code
            if terminalQuery.id.isNil {
                try? response.setBody(json: ["errorCode":"InvalidRetailer","message":"Please Check Retailer Id and Secret Code"])
                response.completed(status: .custom(code: 401, message: "Please check Retailer Id and Secret Code."))
            }

            // this means the terminal is not approved
            if !terminalQuery.is_approved {
                try? response.setBody(json: ["errorCode":"TerminalNotApproved","message":"You must approve the terminal using the Bucket website."])
                response.completed(status: .custom(code: 403, message: "You must approve the terminal using the Bucket website."))
            }

            // Checking the final condition (last condition to minimize the number of queries during error)
            let retailerQuery = Retailer()
            try? retailerQuery.find(["retailer_id":retailerId])
            
            // now lets look to make sure the serial number is to the current retailer
            if retailerQuery.id != terminalQuery.retailer_id {
                // there is a retailer problem
                try? response.setBody(json: ["errorCode":"InvalidRetailerTerminal","message":"Please Check Retailer Id and Secret Code"])
                response.completed(status: .custom(code: 401, message: "Please check Retailer Id and Secret Code."))
            }
            
        }
        
    }

}
