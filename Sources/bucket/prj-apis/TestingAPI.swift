//
//  TestingAPI.swift
//  bucket
//
//  Created by Mike Silvers on 8/13/18.
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
struct TestingAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
                ["method":"post",    "uri":"/api/v1/testingProcess", "handler":testFunction],
                ["method":"get",    "uri":"/api/v1/testing/fillCodes/{countryCode}", "handler":addTestTransaction]
            ]
        }
        //MARK: - Close Interval Function
        public static func testFunction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // make sure we are NOT in production
                if EnvironmentVariables.sharedInstance.Server!.rawValue == "PROD" {
                    let _ = try? response.setBody(json: " { \"error\": \"This function is not on\" } ")
                    return response.completed(status: .internalServerError)
                }
                
                guard !Account.userBouce(request, response) else { return }
                
                // SET TESTING STUFF HERE:

                
                
                // END SET TESTING STUFF

                response.setBody(string: "Completed testing.")
                return response.completed(status: .ok)
                
            }
        }
        
        public static func addTestTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // make sure we are NOT in production
                if EnvironmentVariables.sharedInstance.Server!.rawValue == "PROD" {
                    let _ = try? response.setBody(json: ["error":"This function is not on."])
                    return response.completed(status: .internalServerError)
                }
                
                guard !Account.userBouce(request, response) else { return }
            
                // get the country code
                // Here we need to get all the modes, and get all the fields
                guard let countryCode = request.countryCode else { return response.invalidCountryCode }

                // they may send in either the code number of the alpha for the code
                
                var countryId = ""
                if countryCode.isNumeric() {
                    countryId = countryCode
                } else {
                    countryId = String(SupportFunctions.sharedInstance.getCountryId(countryCode))
                    if countryId == "0" {
                        return response.invalidCountryCode
                    }
                }

                
                let user = request.session!.userid
            
                // SECTION 1: Delete all the existing test records for the user and the country
                
                // Delete the testing codes not in the history
                let sql = "DELETE FROM code_transaction WHERE client_location LIKE('TESTING_\(user)_%') AND country_id = \(countryId.intValue!)"
                let current_codes = CodeTransaction()
                let _ = try? current_codes.sqlRows(sql, params: [])
            
                // Delete the testing codes in the history
                let sql2 = "DELETE FROM code_transaction_history WHERE client_location LIKE('TESTING_\(user)_%') AND country_id = \(countryId.intValue!)"
                let current_codes2 = CodeTransactionHistory()
                let _ = try? current_codes2.sqlRows(sql2, params: [])
            
                
                // update the balances table eventially (now that we have country codes)

                // SECTION 2: Get a terminal for a retailer for the country
                
                // look for a retailer in the country we are using
                var add_id = 0
                let sql_add = "SELECT id from address WHERE retailer_id > 0 AND country_id = \(countryId.intValue!)"
                let addy = Address()
                let addy_ret = try? addy.sqlRows(sql_add, params: [])
                if addy_ret.isNotNil {
                    // grab the address id to look up in the terminal file
                    // set the add_id
                    add_id = addy_ret?.first?.data["id"].intValue ?? 0
                } else {
                    // error that there is no terminal for that country code
                    // error must return an error code for the response and get out of this flow
                    try? response.setBody(json: ["error":"There are no retailers in country id \(countryId)"]).completed(status: .custom(code: 450, message: "No Retailers in Country \(countryId)"))
                    return
                }
                
                // look for a terminal
                var ret_id = 0
                var term_serial = ""
                let term = Terminal()
                let _ = try? term.find(["address_id": "\(add_id)"])
                if let t = term.rows().first {
                    ret_id = t.retailer_id!
                    term_serial = t.serial_number!
                } else {
                    
                    // return the no terminal for that country error
                    // error must return an error code for the response and get out of this flow
                    try? response.setBody(json: ["error":"There are no terminals in country id \(countryId)"]).completed(status: .custom(code: 451, message: "No Terminals in Country \(countryId)"))
                    return
                    
                }

                // SECTION 3: Adding the new customer codes for the terminal
                
                for i in 1...250 {
                    let ccode = Retailer().createCustomerCode([:])
                
                    if ccode.success {
                    
                        var qrCodeURL = ""
                        qrCodeURL.append(EnvironmentVariables.sharedInstance.PublicServerURL?.absoluteString ?? "")
                        qrCodeURL.append("/redeem/")
                        qrCodeURL.append(ccode.message)
                    
                        let terminal = Terminal()
                        let _ = try? terminal.find(["serial_number":"\(term_serial)"])
                    
                        // lets get the country id for this transaction
                        let add = Address()
                        try? add.find(["id":String(terminal.address_id!)])
                    
                        var bucket_amount = drand48()
                        bucket_amount = Double(round(bucket_amount * 100) / 100)
                        let total_trans = arc4random_uniform(10)
                        let total_trans_dbl = Double(round(Double(total_trans) * 100) / 100)
                    
                        let transaction = CodeTransaction()
                        transaction.created = (CCXServiceClass.sharedInstance.getNow() + i)
                        transaction.amount = bucket_amount
                        transaction.amount_available = bucket_amount
                        transaction.total_amount = (1 - bucket_amount) + total_trans_dbl + 1
                        transaction.client_location = "TESTING_\(user)_\(i)"
                        transaction.client_transaction_id = "TESTING_\(user)_\(i)"
                        transaction.terminal_id = terminal.id
                        transaction.retailer_id = ret_id
                        transaction.customer_code = ccode.message
                        transaction.customer_codeurl = qrCodeURL
                        if let cc = add.country_id {
                            transaction.country_id = cc
                        }
                        
                        // Save the transaction
                        let _ = try? transaction.saveWithCustomType(CCXDefaultUserValues.user_server)
                        
                        // and now - lets save the transaction in the Audit table
                        let af = AuditFunctions()
                        af.addCustomerCodeAuditRecord(transaction)
                        
                    }
                }
            
                // SECTION 4: Claim the customer codes we just added (to make sure the process is working correctly)
                
                let reup_sql = "SELECT * FROM code_transaction WHERE client_location LIKE ('TESTING_%') AND country_id = \(countryId)"
                let reup_ct = CodeTransaction()
                let reup_res = try? reup_ct.sqlRows(reup_sql, params: [])
                
                if reup_res.isNotNil {
                    for i in reup_res! {
                        
                        // redeem the transactions
                        
                        let ct = CodeTransaction()
                        let rsp = try? ct.sqlRows("SELECT * FROM code_transaction_view_deleted_no WHERE customer_code = $1 AND country_id = $2 ", params: ["\(i.data["customer_code"]!)", countryId])
                        
                        if rsp?.first.isNil == false {
                            var retCode:[String:Any] = [:]
                            
                            // lets redeem the code now
                            let redeemed        = CCXServiceClass.sharedInstance.getNow()
                            let redeemedby      = request.session!.userid
                            try? ct.get(rsp!.first!.data.id!)
                            
                            ct.redeemed         = redeemed
                            ct.redeemedby       = redeemedby
                            ct.status           = CodeTransactionCodes.merchant_pending
                            if let _            = try? ct.saveWithCustomType(redeemedby) {
                                
                                // this means it was saved - audit and archive
                                AuditFunctions().addCustomerCodeAuditRecord(ct)
                                
                                // update the users record
                                UserBalanceFunctions().adjustUserBalance(redeemedby, countryid: ct.country_id!, increase: ct.amount!, decrease: 0.0)
                                
                                // prepare the return
                                retCode["amount"] = ct.amount!
                                
                                let wallet = UserBalanceFunctions().getConsumerBalances(redeemedby)
                                if wallet.count > 0 {
                                    retCode["buckets"] = wallet
                                }
                                
                                // now archive the record
                                ct.archiveRecord()
                                
                            }
                        }
                    }
                }
                _=try? response.setBody(json: ["message": "Added transactions and redeemed them to your account!"])
                return response.completed(status: .ok)
            }
        }
    }
}

fileprivate extension HTTPRequest {
    var countryCode : String? {
        return self.urlVariables["countryCode"]
    }
    var countryId : Int? {
        return self.urlVariables["countryId"].intValue
    }
}

fileprivate extension HTTPResponse {
    var invalidCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such code found"])
            .setHeader(.contentType, value: "application/json")
            .completed(status: .notAcceptable)
    }
    var invalidCountryCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such country code found"])
            .setHeader(.contentType, value: "application/json")
            .completed(status: .notAcceptable)
    }
}
