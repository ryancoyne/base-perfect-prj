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
                ["method":"post",    "uri":"/api/v1/testingProcess", "handler":testFunction]
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

                self.addTestTransactions(request: request, response: response)
                
                
                
                
                
                // END SET TESTING STUFF

                response.setBody(string: "Completed testing.")
                return response.completed(status: .ok)
                
            }
        }
        
        public static func addTestTransactions (request:HTTPRequest, response: HTTPResponse) {
            
            let user = request.session!.userid
            
            // Delete the testing codes not in the history
            let sql = "DELETE FROM code_transaction WHERE client_location LIKE('TESTING_\(user)_%')"
            let current_codes = CodeTransaction()
            let _ = try? current_codes.sqlRows(sql, params: [])
            
            // Delete the testing codes in the history
            let sql2 = "DELETE FROM code_transaction_history WHERE client_location LIKE('TESTING_\(user)_%')"
            let current_codes2 = CodeTransactionHistory()
            let _ = try? current_codes2.sqlRows(sql2, params: [])
            
            // look for a terminal
            let term = Terminal()
            let _ = try? term.findAll()
            let rows = term.rows().first
            
            let ret_id = rows?.retailer_id!
            let term_id = rows?.serial_number!
            
            for i in 1...250 {
                let ccode = Retailer().createCustomerCode([:])
                
                if ccode.success {
                    
                    var qrCodeURL = ""
                    qrCodeURL.append(EnvironmentVariables.sharedInstance.PublicServerURL?.absoluteString ?? "")
                    qrCodeURL.append("/redeem/")
                    qrCodeURL.append(ccode.message)
                    
                    // We need to go and get the integer terminal id:
//                    let retailer = Retailer()
//                    let _ = try? retailer.find(["retailer_code":"\(ret_id!)"])
                    
                    let terminal = Terminal()
                    let _ = try? terminal.find(["serial_number":"\(term_id!)"])
                    
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
            
            let reup_sql = "SELECT * FROM code_transaction WHERE client_location LIKE ('TESTING_%') "
            let reup_ct = CodeTransaction()
            let reup_res = try? reup_ct.sqlRows(reup_sql, params: [])
            
            if reup_res.isNotNil {
                for i in reup_res! {
                    
                    // redeem the transactions
                    
                    let ct = CodeTransaction()
                    let rsp = try? ct.sqlRows("SELECT * FROM code_transaction_view_deleted_no WHERE customer_code = $1", params: ["\(i.data["customer_code"]!)"])
                    
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

        }
    }
}
