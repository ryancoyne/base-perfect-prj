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
import SwiftMoment

//MARK: - Retailer API
/// This Retailer structure supports all the normal endpoints for a user based login application.
struct RetailerAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
                ["method":"get",    "uri":"/api/v1/closeInterval/{intervalId}", "handler":closeInterval],
                ["method":"post",    "uri":"/api/v1/billDenoms", "handler":billDenoms],
                ["method":"get",    "uri":"/api/v1/closeInterval", "handler":closeInterval],
                ["method":"post",   "uri":"/api/v1/registerterminal", "handler":registerTerminal],
                ["method":"post",   "uri":"/api/v1/transaction/{retailerId}", "handler":createTransaction],
                ["method":"post",   "uri":"/api/v1/transaction", "handler":createTransaction],
                ["method":"delete", "uri":"/api/v1/transaction/{customerCode}", "handler":deleteTransaction],
            ]
        }
        
        //MARK: - Get Bill Denominations:
        public static func billDenoms(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                // We will have a country passed in through the header:
                guard let _ = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)
                
                switch schema {
                case "us":
                // Return the US denominations:
                    _=try? response.setBody(json: ["usesNaturalChangeFunction":false]).setHeader(.custom(name: "Content-Type"), value: "application/json; charset=UTF-8").completed(status: .ok)
                    break
                case "sg":
                // Return the SG Denominations:
                    _=try? response.setBody(json: ["usesNaturalChangeFunction":true, "denominations":[100.00, 50.00, 20.00, 10.00, 5.00, 2.00]]).setHeader(.custom(name: "Content-Type"), value: "application/json; charset=UTF-8").completed(status: .ok)
                    break
                default: return response.unsupportedCountry
                }
            }
        }
        
        //MARK: - Close Interval Function
        public static func closeInterval(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
            
                // Take care of checking the retailer & terminal:
                guard !Retailer.retailerTerminalBounce(request, response) else { return }
                
                // Okay.. they are good to go.  Here we need to query for all the transactions for right now (minus one day), sum them up, list them, and send them out.
                
                // Lets see if they passed in an intervalId (the yyyyMMdd string):
                let intervalId = request.intervalId ?? moment().intervalString
            
                guard var startDate = moment(intervalId, dateFormat: "yyyyMMdd") else { return }
                startDate = startDate - 4.hours
                let endDate = startDate + (1.days - 1.seconds)
                
//                return response.completed(status: .ok)
                
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
                    guard let _ = request.countryId else { return response.invalidCountryCode }
                
                    let schema = Country.getSchema(request)
                    
                    switch server {
                    // Production & Staging are acting the same.
                    case .production, .staging:
                        // We should do everything like regular here:
                        
                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                        let terminal = Terminal()
                        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(serialNumber)' "
                        let trm = try? terminal.sqlRows(sql, params: [])
                        if let t = trm?.first {
                            terminal.to(t)
                        }
                        
                        
                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
                            let term = Terminal()
                            let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(serialNumber)' "
                            let trm = try? term.sqlRows(sql, params: [])
                            if let t = trm?.first {
                                term.to(t)
                            }

                            let apiKey = UUID().uuidString
                            term.serial_number = serialNumber
                            term.retailer_id = retailerIntegerId
                            term.terminal_key = apiKey.ourPasswordHash
                            
                            do {
                                
                                try term.saveWithCustomType(schemaIn: schema)
                                try? response.setBody(json: ["isApproved":false, "apiKey":apiKey])
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .created)
                                
                            } catch {
                                // Return some caught error:
                                response.caughtError(error)
                                return
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
                            try terminal.saveWithCustomType(schemaIn: schema)
                            
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
                        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(serialNumber)' "
                        let trm = try? terminal.sqlRows(sql, params: [])
                        if let t = trm?.first {
                            terminal.to(t)
                        }
                        
                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
                            let term = Terminal()
                            
                            let apiKey = UUID().uuidString
                            term.is_approved = true
                            term.serial_number = serialNumber
                            term.retailer_id = retailerIntegerId
                            term.terminal_key = apiKey.ourPasswordHash
                            
                            // we will take the first address on file for this retailer and add the location here for them
                            let add = Address()
                            let a_sql = "SELECT * FROM \(schema).address WHERE retailer_id = '\(retailerIntegerId)'"
                            let a_res = try? add.sqlRows(a_sql, params: [])
                            if let a = a_res?.first {
                                add.to(a)
                            }
                            
                            if add.id.isNotNil, add.retailer_id == retailerIntegerId {
                                term.address_id = add.id
                            }
                            
                            do {
                                
                                try term.saveWithCustomType(schemaIn: schema)
                                try? response.setBody(json: ["isApproved":true, "apiKey":apiKey])
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .created)
                                
                            } catch {
                                // Return some caught error:
                                response.caughtError(error)
                                return
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
                            try terminal.saveWithCustomType(schemaIn: schema)
                            
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
                    response.caughtError(error)
                    return
                }
            }
        }
        
        //MARK: - Register Terminal Function
        public static func unregisterTerminal(_ data: [String:Any]) throws -> RequestHandler {
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
                    guard let _ = request.countryId else { return response.invalidCountryCode }
                    
                    let schema = Country.getSchema(request)

                    
                    switch server {
                    // Production & Staging are acting the same.
                    case .production, .staging:
                        // We should do everything like regular here:
                        
//                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
//                        let terminal = Terminal()
//                        try terminal.find(["serial_number": serialNumber])
//
//                        // Check and make sure the terminal is approved or not:
//                        if terminal.id.isNil {
//                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
//                            let term = Terminal()
//
//                            let apiKey = UUID().uuidString
//                            term.serial_number = serialNumber
//                            term.retailer_id = retailerIntegerId
//                            term.terminal_key = apiKey.ourPasswordHash
//
//                            do {
//
//                                try term.saveWithCustomType()
//                                try? response.setBody(json: ["isApproved":false, "apiKey":apiKey])
//                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                    .completed(status: .created)
//
//                            } catch {
//                                // Return some caught error:
//                                try? response.setBody(json: ["error":error.localizedDescription])
//                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                    .completed(status: .internalServerError)
//                            }
//
//                        } else {
//
//                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
//                            guard retailerIntegerId == terminal.retailer_id else { return response.alreadyRegistered(serialNumber) }
//
//                            // Save the new password, and return the response:
//                            let thePassword = UUID().uuidString
//
//                            // Build the response:
//                            var responseDictionary = [String:Any]()
//                            responseDictionary["isApproved"] = terminal.is_approved
//                            responseDictionary["apiKey"] = thePassword
//
//                            // Create and assign the hashed password:
//                            terminal.terminal_key = thePassword.ourPasswordHash
//
//                            // Save:
//                            try terminal.saveWithCustomType()
//
//                            // Return the response:
//                            try? response.setBody(json: responseDictionary)
//                                .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                .completed(status: .ok)
//
//                        }
                        
                        break
                    case .development:
                        // In development, we are automatically setting the terminal as approved, so they do not need to go to the web.
                        
                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                        let terminal = Terminal()
                        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(serialNumber)' "
                        let trmn = try? terminal.sqlRows(sql, params: [])
                        if trmn.isNotNil, let c = trmn!.first {
                            terminal.to(c)
                        }

                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
//                            let term = Terminal()
//
//                            let apiKey = UUID().uuidString
//                            term.is_approved = true
//                            term.serial_number = serialNumber
//                            term.retailer_id = retailerIntegerId
//                            term.terminal_key = apiKey.ourPasswordHash
//
//                            // we will take the first address on file for this retailer and add the location here for them
//                            let add = Address()
//                            try? add.find(["retailer_id" : String(retailerIntegerId)])
//
//                            if add.id.isNotNil, add.retailer_id == retailerIntegerId {
//                                term.address_id = add.id
//                            }
//
//                            do {
//
//                                try term.saveWithCustomType()
//                                try? response.setBody(json: ["isApproved":true, "apiKey":apiKey])
//                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                    .completed(status: .created)
//
//                            } catch {
//                                // Return some caught error:
//                                try? response.setBody(json: ["error":error.localizedDescription])
//                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                    .completed(status: .internalServerError)
//                            }
//
                        } else if terminal.retailer_id.isNotNil {
                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
                            guard retailerIntegerId == terminal.retailer_id else { /* Send back an error indicating this device is on another account */  return response.alreadyRegistered(serialNumber) }
                            
                            // If they are who they say they are, we will go and unregister the terminal:
                            let _  = try? terminal.softDeleteWithCustomType(schemaIn: schema)
                            
                        }
                        
                    }
                    
                } catch BucketAPIError.unparceableJSON(let invalidJSONString) {
                    return response.invalidRequest(invalidJSONString)
                    
                } catch {
                    // Not sure what error could be thrown here, but the only one we throw right now is if the JSON is unparceable.
                    // Return some caught error:
                    response.caughtError(error)
                    return
                }
            }
        }
        
        //MARK: - Create Transaction
        public static func createTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
            
                // We should first bouce the retailer (takes care of all the general retailer errors):
                guard !Retailer.retailerTerminalBounce(request, response) else { return }
                
                guard let _ = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)

                do {

                    // we are using the json variable to return the code too.
                    var json = try request.postBodyJSON()
                    
                    // get the code
                    var ccode = Retailer().createCustomerCode(schemaId: schema, json!)
                    
                    // loop until we get a customer code that is unique
                    while !ccode.success {
                        ccode = Retailer().createCustomerCode(schemaId: schema, json!)
                    }
                    
                    // put together the return dictionary
                    if ccode.success {
                    
                        json!["customerCode"] = ccode.message
                        
                        var qrCodeURL = ""
                        qrCodeURL.append(EnvironmentVariables.sharedInstance.PublicServerApiURL?.absoluteString ?? "")
                        qrCodeURL.append("redeem/")
                        qrCodeURL.append(ccode.message)
                        json!["qrCodeContent"] = qrCodeURL
                        
                        // We need to go and get the integer terminal id:
                        let retailer = Retailer()
                        var sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(request.retailerId!)' "
                        let rtlr = try? retailer.sqlRows(sql, params: [])
                        if rtlr.isNotNil, let c = rtlr!.first {
                            retailer.to(c)
                        }
                        
                        let terminal = Terminal()
                        sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(request.terminalId!)' "
                        let trmn = try? terminal.sqlRows(sql, params: [])
                        if trmn.isNotNil, let c = trmn!.first {
                            terminal.to(c)
                        }
                        
                        // lets get the country id for this transaction
                        let add = Address()
                        sql = "SELECT * FROM \(schema).address WHERE id = \(String(terminal.address_id!)) "
                        let adr = try? terminal.sqlRows(sql, params: [])
                        if adr.isNotNil, let c = adr!.first {
                            add.to(c)
                        }

                        let transaction = CodeTransaction()
                        transaction.created = CCXServiceClass.sharedInstance.getNow()
                        transaction.amount = json?["amount"].doubleValue
                        transaction.amount_available = json?["amount"].doubleValue
                        transaction.total_amount = json?["totalTransactionAmount"].doubleValue
                        transaction.client_location = json?["locationId"].stringValue
                        transaction.client_transaction_id = json?["clientTransactionId"].stringValue
                        transaction.terminal_id = terminal.id
                        transaction.retailer_id = retailer.id
                        transaction.customer_code = json?["customerCode"].stringValue
                        transaction.customer_codeurl = json?["qrCodeContent"].stringValue
                        if let cc = add.country_id {
                            transaction.country_id = cc
                        }
                        transaction.description = retailer.name
                        
                        // Save the transaction
                        let trn = try? transaction.saveWithCustomType(schemaIn: schema, CCXDefaultUserValues.user_server)
                        if let t = trn?.first, let tid = t.data["id"]  {
                            transaction.id = tid as! Int
                        }
                        // and now - lets save theb transaction in the Audit table
                        AuditFunctions().addCustomerCodeAuditRecord(transaction)
                        
                        json!["bucketTransactionId"] = transaction.id
                        
                        // if we are here then everything went well
                        try? response.setBody(json: json!)
                            .completed(status: .ok)
                        return
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

        
        //MARK: - Delete Transaction
        public static func deleteTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // We should first bouce the retailer (takes care of all the general retailer errors):
                guard !Retailer.retailerTerminalBounce(request, response) else { return }
                
                guard let code = request.customerCode else { response.invalidCustomerCode; return }
                guard let _ = request.countryId else { response.invalidCountryCode; return }
                
                let schema = Country.getSchema(request)
                
                // note that since the unclaimed codes are not in the individual countries (yet), there is only one table in the public schema to deal with
                // get the code from the url path
                // lets see if the code has not been redeemed yet :)
                let thecode = CodeTransaction()
                
                let sql = "SELECT * FROM \(schema).code_transaction WHERE customer_code = '\(code)' "
                let cde = try? thecode.sqlRows(sql, params: [])
                if cde.isNotNil, let c = cde!.first {
                    thecode.to(c)
                }

                // We should also check and make sure the retailer is deleting their own transaction:
                guard let retailerId = request.retailer?.id, thecode.retailer_id == retailerId else { return response.incorrectRetailer }
                
                // Check if we have a returning object:
                if thecode.id.isNotNil {

                    // see if the code is deleted
                    guard thecode.deleted! == 0 else { _ = try? response.setBody(json: ["errorCode":"CodeDeleted","message":"The code was already deleted."])
                        response.completed(status: .custom(code: 451, message: "Code Already Deleted"))
                        return }
                    
                    // Make sure the retailers match:
                    // Return a general error with a different status code that we will know that the retailers are not matching.
                    // We will tell them to go to Bucket for support.  If they report an error of code 454, we know there is an issue with the retailers matching.
                    let retailer = Retailer()
                    let sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(request.retailerId!)' "
                    let rtlr = try? retailer.sqlRows(sql, params: [])
                    if rtlr.isNotNil, let c = rtlr!.first {
                        retailer.to(c)
                    }

                    guard thecode.retailer_id == retailer.id else { _ = try? response.setBody(json: ["errorCode":"UnexpectedIssue","message":"There is an issue with this transaction.  Please contact Bucket Support."])
                        response.completed(status: .custom(code: 454, message: "Contact Support"))
                        return }
                    
                    // lets delete the code
                    thecode.deleted = CCXServiceClass.sharedInstance.getNow()
                    
                    let terminal = request.terminal!
                    thecode.deleted_reason = "Terminal \(terminal.serial_number!) deleted this transaction at \(thecode.deleted!.dateString) GMT"
                    
                    // see if a user is logged in
                    if let user = request.session?.userid, !user.isEmpty {
                        thecode.deletedby = user
                    } else {
                        thecode.deletedby = CCXDefaultUserValues.user_server
                    }
                    
                    let _ = try? thecode.saveWithCustomType(schemaIn: schema,thecode.deletedby, copyOver: false)
                    
                    // audit the delete
                    AuditFunctions().deleteCustomerCodeAuditRecord(thecode)
                    
                    // all OK - returned at the bottom
                    _=try? response.setBody(json: ["result":"Successfully deleted the transaction."])
                    response.completed(status: .ok)
                    
                } else {
                    
                    // We did not... if it is in the history table, then it is already redeemed...
                    let theCode = CodeTransactionHistory()
                    let sql = "SELECT * FROM \(schema).code_transaction_history WHERE customer_code = '\(code)'"
                    let cde = try? theCode.sqlRows(sql, params: [])
                    if cde.isNotNil, let c = cde!.first {
                        theCode.to(c)
                    }

                    if theCode.id.isNotNil {
                        let _ = try? response.setBody(json: ["errorCode":"CodeRedeemed","message":"The code was redeemed already.  Please Contact Bucket Support."])
                        response.completed(status: .custom(code: 452, message: "Code Redeemed Already"))
                        return
                    }
                    
                    response.invalidCustomerCode
                    return
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
    var incorrectRetailer : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRetailer", "message":"You cannot delete another retailer's transaction."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 453, message: "Retailer Conflict"))
    }
    var noTerminalId : Void {
        return try! self
            .setBody(json: ["errorCode":"NoTerminalId", "message":"You must send in a 'terminalId' key with the serial number of the device as the value."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .forbidden)
    }
    var noLocationTerminal : Void {
        return try! self
            .setBody(json: ["errorCode":"NoTerminalLocation", "message":"You must set the location for the terminal before using the terminal.  Set the location on your retailer portal."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 460, message: "No Terminal Location"))
    }
    var serverEnvironmentError : Void {
        return try! self
            .setBody(json: ["errorCode":"ServerEnvironmentError", "message":"There is a current configuration issue with the system.  Please Contact Bucket's Tech Team."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .internalServerError)
    }
    var invalidCustomerCode : Void {
        let _ = try? self.setBody(json: ["errorCode":"InvalidCode", "message":"Please check your customer code."])
        return self.completed(status: .custom(code: 450, message: "Code Not On Record For UnRedeemed"))
    }
    func alreadyRegistered(_ serialNumber: String) -> Void {
        return try! self
            .setBody(json: ["errorCode":"AlreadyRegistered", "message":"The terminal with the serial number (\(serialNumber)) is registered to another retailer.  Contact Bucket support."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 410, message: "Terminal Registered"))
    }

}

fileprivate extension Moment {
    /// This is the yyyyMMdd formatted string for right now.
    var intervalString : String {
        return self.format("yyyyMMdd")
    }
}

fileprivate extension HTTPRequest {
    
//    @available(*, deprecated, message: "no longer available in version v1.1")
    var retailerId : String? {
        return self.header(.custom(name: "retailerId")) ?? self.urlVariables["retailerId"]
    }
    var intervalId : String? {
        return self.urlVariables["intervalId"]
    }
    var customerCode : String? {
        return self.urlVariables["customerCode"]
    }
    var retailerSecret : String? {
        return self.header(.custom(name: "x-functions-key"))
    }
    var terminalId : String? {
        if let terminalIdFromHeader = self.header(.custom(name: "terminalId")).stringValue {
            return terminalIdFromHeader
        }
        let theTry = try? self.postBodyJSON()?["terminalId"].stringValue
        if theTry.isNil {
            return nil
        } else {
            return theTry!
        }
    }

    var retailer : Retailer? {
        guard let retailerId = retailerId, let countryId = countryId else { return nil }
        let schema = Country.getSchema(countryId)
        let retailer = Retailer()
        let sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(retailerId)'"
        if let res = try? retailer.sqlRows(sql, params: []), let row = res.first {
            retailer.to(row)
            return retailer
        } else {
            return nil
        }
    }
    var terminal : Terminal? {
        // Lets see if we have a terminal from the input data:
        // They need to input the x-functions-key as their retailer password.
        guard let password = self.retailerSecret, let terminalId = self.terminalId, let countryId = self.countryId else { return nil }
        
        let schema = Country.getSchema(countryId)
        
        let term = Terminal()
        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(terminalId)' AND terminal_key = '\(password.ourPasswordHash!)' "
        let trm = try? term.sqlRows(sql, params: [])
        if trm.isNotNil, let t = trm?.first {
            term.to(t)
        }

        if term.id.isNotNil { return term }
            
        else { return nil }
    }
    
}


extension Retailer {

    public static func exists(_ with: String, _ countryId: String) -> Bool {
        
        let schema = Country.getSchema(countryId)
        if schema.isEmpty { return false }
        
        // Find the terminal
        let retailer = Retailer()
        let sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(with)'"
        let rtlr = try? retailer.sqlRows(sql, params: [])
        if rtlr.isNotNil, let t = rtlr?.first {
            retailer.to(t)
        }

        return retailer.id.isNotNil
        
    }
    
    @discardableResult
    public static func retailerBounce(_ request: HTTPRequest, _ response: HTTPResponse) -> Int? {
        
        //Make sure we have the retailer Id and retailer secret:
        guard let retailerId = request.retailerId else { response.invalidRetailer; return nil }
        guard let countryId = request.countryId else {  response.invalidCountryCode; return nil }
        
        let schema = Country.getSchema(countryId)
        if schema.isEmpty { response.invalidCountryCode; return nil }

        // Find the terminal
        let retailer = Retailer()
        let sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(retailerId)'"
        let rtlr = try? retailer.sqlRows(sql, params: [])
        if rtlr.isNotNil, let t = rtlr?.first {
            retailer.to(t)
        }

        // this is where we will check the temrminal ID, retailer and the secret to make sure the terminal is approved.
        
        if retailer.id.isNil { response.invalidRetailer; return nil }
        
        return retailer.id
        
    }

    public static func retailerTerminalBounce(_ request: HTTPRequest, _ response: HTTPResponse) -> Bool {
        
        //Make sure we have the retailer Id and retailer secret:
        guard let retailerSecret = request.retailerSecret, let retailerId = request.retailerId else { response.unauthorizedTerminal; return true }
        guard let terminalSerialNumber = request.terminalId else { response.noTerminalId; return true }
        guard let _ = request.countryId else { response.invalidCountryCode; return true }
        
        let schema = Country.getSchema(request)
        
        // Get our secret code formatted properly to check what we have in the DB:
        let passwordToCheck = retailerSecret.ourPasswordHash!
        
        let terminalQuery = Terminal()
        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(terminalSerialNumber)' AND terminal_key = '\(passwordToCheck)' "
        let term = try? terminalQuery.sqlRows(sql, params: [])
        if term.isNotNil, let t = term?.first {
            terminalQuery.to(t)
        }
        
        // Checking three conditions:
        //  1. The terminal is not registered
        //  2. The terminal is not active
        //  3. The terminal is not for this retailer
        //  4. The terminal is not assigned to an address
        
        // this means the terminal number is invalid - RETURN the appropriate error code
        if terminalQuery.id.isNil { response.unauthorizedTerminal; return true }
        
        // this means the terminal is not approved
        if !terminalQuery.is_approved { response.unauthorizedTerminal; return true }
        
        // and finally - make sure there is an address assigned to this terminal
        if terminalQuery.address_id.isNil || terminalQuery.address_id == 0 { response.noLocationTerminal; return true }

        // Checking the final condition (last condition to minimize the number of queries during error)
        let retailerQuery = Retailer()
        let sqlr = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(retailerId)'"
        let rtl = try? retailerQuery.sqlRows(sqlr, params: [])
        if rtl.isNotNil, let t = rtl?.first {
            retailerQuery.to(t)
        }

        // now lets look to make sure the serial number is to the current retailer
        if retailerQuery.id != terminalQuery.retailer_id { response.alreadyRegistered(terminalSerialNumber); return true }
        
        return false
    }

}
