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
                ["method":"get",    "uri":"/api/v1/closeInterval/{retailerId}", "handler":closeInterval],
                ["method":"post",    "uri":"/api/v1/registerterminal", "handler":registerTerminal],
                ["method":"post",    "uri":"/api/v1/transaction/{retailerId}", "handler":createTransaction],
                ["method":"post",    "uri":"/api/v1/transaction", "handler":createTransaction]
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
                // *IMPORTANT*  If this is development, then we can automatically verify the device.  If we are production, then we will make them to go the web and verify the device is theirs.
                
                do {
                    
                    // Get our post body JSON.  This will throw an error, along with the string that it tried parsing.
                    let json = try request.postBodyJSON()
                    // Throw an error if the json body is empty.  We should have something in the post body JSON here.
                    guard !json!.isEmpty else { return response.emptyJSONBody }
                    
                    // This should be the retailerBounce part:
                    guard let retailerIntegerId = Retailer.retailerBounce(request, response) else { return }
                    guard let serialNumber = json?["terminalId"].stringValue else { return response.noTerminalId }
                    guard let server = EnvironmentVariables.sharedInstance.Server else { return response.serverEnvironmentError }
                
                    switch server {
                    // Production & Staging are acting the same.
                    case .production, .staging:
                        // We should do everything like regular here:
                        
                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                        let terminal = Terminal()
                        try terminal.find(["serial_number": serialNumber])
                        
                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
                            let term = Terminal()
                            
                            let apiKey = UUID().uuidString
                            term.serial_number = serialNumber
                            term.retailer_id = retailerIntegerId
                            term.terminal_key = apiKey.ourPasswordHash
                            
                            do {
                                
                                try term.saveWithCustomType()
                                try? response.setBody(json: ["isApproved":false, "apiKey":apiKey])
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .created)
                                
                            } catch {
                                // Return some caught error:
                                try? response.setBody(json: ["error":error.localizedDescription])
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .internalServerError)
                            }
                            
                        } else {
                            
                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
                            guard retailerIntegerId == terminal.retailer_id else { return response.alreadyRegistered(serialNumber) }
                            
                            // Save the new password, and return the response:
                            let thePassword = UUID().uuidString
                            
                            // Build the response:
                            var responseDictionary = [String:Any]()
                            responseDictionary["isApproved"] = terminal.is_approved
                            responseDictionary["apiKey"] = thePassword
                            
                            // Create and assign the hashed password:
                            terminal.terminal_key = thePassword.ourPasswordHash
                            
                            // Save:
                            try terminal.saveWithCustomType()
                            
                            // Return the response:
                            try? response.setBody(json: responseDictionary)
                                .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                .completed(status: .ok)
                            
                        }
                        
                        break
                    case .development:
                        // In development, we are automatically setting the terminal as approved, so they do not need to go to the web.
                        
                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                        let terminal = Terminal()
                        try terminal.find(["serial_number": serialNumber])
                        
                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
                            let term = Terminal()
                            
                            let apiKey = UUID().uuidString
                            term.is_approved = true
                            term.serial_number = serialNumber
                            term.retailer_id = retailerIntegerId
                            term.terminal_key = apiKey.ourPasswordHash
                            
                            do {
                                
                                try term.saveWithCustomType()
                                try? response.setBody(json: ["isApproved":true, "apiKey":apiKey])
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .created)
                                
                            } catch {
                                // Return some caught error:
                                try? response.setBody(json: ["error":error.localizedDescription])
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .internalServerError)
                            }
                            
                        } else if terminal.retailer_id.isNotNil && terminal.is_approved {
                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
                            guard retailerIntegerId == terminal.retailer_id else { /* Send back an error indicating this device is on another account */  return response.alreadyRegistered(serialNumber) }
                            
                            // Save the new password, and return the response:
                            let thePassword = UUID().uuidString
                            
                            // Build the response:
                            var responseDictionary = [String:Any]()
                            responseDictionary["isApproved"] = true
                            responseDictionary["apiKey"] = thePassword
                            
                            // Create and assign the hashed password:
                            terminal.terminal_key = thePassword.ourPasswordHash
                            
                            // Save:
                            try terminal.saveWithCustomType()
                            
                            // Return the response:
                            try? response.setBody(json: responseDictionary)
                                .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                .completed(status: .ok)
                            
                        }
                        
                    }
                    
                } catch BucketAPIError.unparceableJSON(let invalidJSONString) {
                    return response.invalidRequest(invalidJSONString)
                    
                } catch {
                    // Not sure what error could be thrown here, but the only one we throw right now is if the JSON is unparceable.
                    // Return some caught error:
                    try? response.setBody(json: ["error":error.localizedDescription])
                        .setHeader(.contentType, value: "application/json; charset=UTF-8")
                        .completed(status: .internalServerError)
                }
            }
        }
        //MARK: - Create Transaction
        public static func createTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
            
                // We should first bouce the retailer (takes care of all the general retailer errors):
                Retailer.retailerTerminalBounce(request, response)
                
                do {

                    // we are using the json variable to return the code too.
                    var json = try request.postBodyJSON()
                    
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
                        
                        // We need to go and get the integer terminal id:
                        let retailer = Retailer()
                        try? retailer.find(["retailer_code":request.retailerId!])
                        
                        let terminal = Terminal()
                        try? terminal.find(["serial_number":request.terminalId!])
                        
                        let transaction = CodeTransaction()
                        transaction.created = Int(Date().timeIntervalSince1970)
                        transaction.amount = json?["amount"].doubleValue
                        transaction.total_amount = json?["totalTransactionAmount"].doubleValue
                        transaction.client_location = json?["locationId"].stringValue
                        transaction.client_transaction_id = json?["clientTransactionId"].stringValue
                        transaction.terminal_id = terminal.id
                        transaction.retailer_id = retailer.id
                        transaction.customer_code = json?["customerCode"].stringValue
                        transaction.customer_codeurl = json?["qrCodeContent"].stringValue
                        
                        // Save the transaction
                        let _ = try? transaction.saveWithCustomType(CCXDefaultUserValues.user_server)
                        
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
        
        //MARK: - Delete Terminal
        static func terminalDelete(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Verify Retailer
                Retailer.retailerBounce(request, response)
                
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
    var unauthorizedTerminal : Void {
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
    var serverEnvironmentError : Void {
        return try! self
            .setBody(json: ["errorCode":"ServerEnvironmentError", "message":"There is a current configuration issue with the system.  Please Contact Bucket's Tech Team."])
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

