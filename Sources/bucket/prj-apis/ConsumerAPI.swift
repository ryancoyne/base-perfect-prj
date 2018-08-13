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
