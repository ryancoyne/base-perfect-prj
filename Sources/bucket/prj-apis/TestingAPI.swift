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
                ["method":"post",    "uri":"/api/v1/testing/fillCodes/{countryCode}", "handler":addTestTransaction],
                ["method":"post",    "uri":"/api/v1/testing/getQRCodes/{countryCode}", "handler":getCodes]
            ]
        }
        //MARK: - Get QR Codes:
        public static func getCodes(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // make sure we are NOT in production
                if EnvironmentVariables.sharedInstance.Server!.rawValue == "PROD" {
                    return response.functionNotOn
                }
                
                // Bounce the user... we need a user.
                guard !Account.userBouce(request, response) else { return }
                
                // Okay we have a user.  Lets check if they sent their country code in:
                guard let countryId = request.countryId else { return response.invalidCountryCode }
                
                // Get the schema:
                let schema = Country.getSchema(countryId)
                
                // Get how many codes:
                let numberOfQrCodes = request.qrCodeCount
                let codeSize = request.qrCodeSize
                
                let user = request.session!.userid
                let email = request.email ?? request.account!.email
                
                // look for a terminal
                let term = Terminal.getFirst(schema)
                if term.isNil {
                    try? response.setBody(json: ["error":"There are no terminals in country id \(countryId)"]).completed(status: .custom(code: 451, message: "No Terminals in Country \(countryId)"))
                    return
                }
                
                // Okay... lets create the codes, and send the email!
                var theHTML = "<head>\n"
                 theHTML.append("<style>\n")
                 theHTML.append("table, th, td { \n")
                  theHTML.append("   border: 1px solid black; \n")
                 theHTML.append("    border-collapse: collapse; \n")
                 theHTML.append("} \n")
                 theHTML.append("th, td { \n")
                 theHTML.append("    padding: 40px; \n")
                 theHTML.append("    text-align: center; \n")
                 theHTML.append("} \n")
                theHTML.append(" </style> \n")
                 theHTML.append("</head> \n")
                 theHTML.append("<body> \n")
                    
                theHTML.append("<p>Hello there!  We have you your QR Codes!!!</p><br /> \n")
                theHTML.append("<table> \n")
                
                var ctr = 0
                for i in 1...numberOfQrCodes {
                    
                    if ctr == 0 {
                        theHTML.append("<tr> \n")
                    } else if ctr == 4 {
                        theHTML.append("</tr> \n")
                        ctr = 0
                    }
                    ctr += 1
                    
                    // Create the transaction:
                    let transaction = CodeTransaction.qrCodeCreate(schema: schema, user: user, terminal: term!, increment: i)
                    
                    let theQRCodeURL = transaction?.customer_codeurl ?? ""
                    let theHTMLQrCodeURL = "https://api.qrserver.com/v1/create-qr-code/?data=\(theQRCodeURL)&size=\(codeSize)x\(codeSize)"
                    let imageHTML = "<img src='\(theHTMLQrCodeURL)' />"
                    
                    theHTML.append("<td >")
                    theHTML.append(imageHTML)
                    theHTML.append("</td> \n")

                }

                theHTML.append("</tr></table> \n")
                theHTML.append("</body> \n")

                let environment = EnvironmentVariables.sharedInstance.Server!
                    
                // Send the response:
                try? response.setBody(json: ["message":"Success!  Your QR codes are on their way, by email."]).completed(status: .ok)
                Utility.sendMail(name: "Bucket Technologies", address: email, subject: "QR Code Generation for \(environment)", html: theHTML, text: "Please Enable HTML email to get your codes.")
                return
                
            }
        }
        
        //MARK: - Close Interval Function
        public static func testFunction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // make sure we are NOT in production
                if EnvironmentVariables.sharedInstance.Server!.rawValue == "PROD" {
                    return response.functionNotOn
                }
                
                guard !Account.userBouce(request, response) else { return }
                
                // SET TESTING STUFF HERE:


                SuttonFunctions().createTransferFile()
                
//                var batch = SupportFunctions.sharedInstance.getNextBatch(schemaId: "us", "STTN")
//                print("Batch test: \(batch.headerId):\(batch.batchIdentifier)")
//
//                batch = SupportFunctions.sharedInstance.getNextBatch(schemaId: "us", "STTN")
//                print("Batch test: \(batch.headerId):\(batch.batchIdentifier)")
//
//                batch = SupportFunctions.sharedInstance.getNextBatch(schemaId: "us", "STTN")
//                print("Batch test: \(batch.headerId):\(batch.batchIdentifier)")
//
//                batch = SupportFunctions.sharedInstance.getNextBatch(schemaId: "us", "STTN")
//                print("Batch test: \(batch.headerId):\(batch.batchIdentifier)")
//
//                batch = SupportFunctions.sharedInstance.getNextBatch(schemaId: "us", "STTN")
//                print("Batch test: \(batch.headerId):\(batch.batchIdentifier)")
//
//                batch = SupportFunctions.sharedInstance.getNextBatch(schemaId: "us", "STTN")
//                print("Batch test: \(batch.headerId):\(batch.batchIdentifier)")
//
//                batch = SupportFunctions.sharedInstance.getNextBatch(schemaId: "us", "STTN")
//                print("Batch test: \(batch.headerId):\(batch.batchIdentifier)")

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
                
                let schema = Country.getSchema(countryCode)

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

                var endmessage = ""
                
                let user = request.session!.userid
            
                // SECTION 1: Delete all the existing test records for the user and the country
                // BUT: only if the count == 0
                // get the count
                let cnt = request.header(.custom(name: "count")).intValue ?? 20

                switch cnt {
                case 0:
                    
                    // Delete the testing codes not in the history
//                    let sql = "DELETE FROM \(schema).code_transaction WHERE client_location LIKE('TESTING_\(user)_%') AND country_id = \(countryId.intValue!)"
//                    let current_codes = CodeTransaction()
//                    let _ = try? current_codes.sqlRows(sql, params: [])

                    let deletedtime = CCXServiceClass.sharedInstance.getNow()
                    
                    let sql = "SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE client_location LIKE('TESTING_\(user)_%') AND country_id = \(countryId.intValue!) "
                    let current_codes = CodeTransaction()
                    let ct = try? current_codes.sqlRows(sql, params: [])
                    if ct.isNotNil {
                        for c in ct! {
                            let ctt = CodeTransaction()
                            ctt.to(c)
                            ctt.deleted = deletedtime
                            ctt.deletedby = user
                            _ = try? ctt.saveWithCustomType(schemaIn: schema, user, copyOver: false)

                            if schema == "us" { AuditFunctions().deleteCustomerCodeAuditRecord(ctt) }

                        }
                    }

                    // Delete the testing codes in the history
                    let sql2 = "SELECT * FROM \(schema).code_transaction_history_view_deleted_no WHERE client_location LIKE('TESTING_\(user)_%') AND country_id = \(countryId.intValue!)"
                    let current_codes2 = CodeTransactionHistory()
                    let cth = try? current_codes2.sqlRows(sql2, params: [])
                    
                    if cth.isNotNil {
                        for c in cth! {
                            let ctth = CodeTransactionHistory()
                            ctth.to(c)
                            ctth.deleted = deletedtime
                            ctth.deletedby = user
                            _ = try? ctth.saveWithCustomType(schemaIn: schema, user, copyOver: false)
                            
                            // decrement the users balance
                            UserBalanceFunctions().adjustUserBalance(schemaId: nil, user, countryid: ctth.country_id!, increase: 0.00, decrease: ctth.amount!)
                            
                            if schema == "us" { AuditFunctions().deleteCustomerCodeAuditRecord(ctth) }
                            
                        }
                    }
                    
                    // set the account balance to 0
                    let sql_del = "UPDATE public.user_total SET balance = 0.0 WHERE country_id = \(countryId.intValue!) AND user_id = '\(user)'"
                    let _ = try? current_codes.sqlRows(sql_del, params: [])
                    
                    endmessage = "Transactions were removed from your account!"
                    
                default:
                    // SECTION 2: Get a terminal for a retailer for the country
                    var nbr_added = 0
                    
                    // look for a retailer in the country we are using
                    let sql_add = "SELECT id from \(schema).address WHERE retailer_id > 0 AND country_id = \(countryId.intValue!)"
                    let addy = Address()
                    let addy_ret = try? addy.sqlRows(sql_add, params: [])
                    if addy_ret.isNil {
                        // error that there is no terminal for that country code
                        // error must return an error code for the response and get out of this flow
                        try? response.setBody(json: ["error":"There are no retailers in country id \(countryId)"]).completed(status: .custom(code: 450, message: "No Retailers in Country \(countryId)"))
                        return
                    }
                    
                    // look for a terminal
                    let term = Terminal.getFirst(schema)
                    if term.isNil {
                        try? response.setBody(json: ["error":"There are no terminals in country id \(countryId)"]).completed(status: .custom(code: 451, message: "No Terminals in Country \(countryId)"))
                        return
                    }
                    
                    // SECTION 3: Adding the new customer codes for the terminal
                    
                    for i in 1...cnt {
                        // This was all chopped down to this function to use to email QR Codess
                        CodeTransaction.qrCodeCreate(schema: schema, user: user, terminal: term!, increment: i)
                    }
                    
                    // SECTION 4: Claim the customer codes we just added (to make sure the process is working correctly)
                    
                    let reup_sql = "SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE client_location LIKE ('TESTING_%') AND country_id = \(countryId)"
                    let reup_ct = CodeTransaction()
                    let reup_res = try? reup_ct.sqlRows(reup_sql, params: [])
                    
                    if reup_res.isNotNil {
                        for i in reup_res! {
                            
                            // redeem the transactions
                            
                            let ct = CodeTransaction()
                            let rsp = try? ct.sqlRows("SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE customer_code = $1 AND country_id = $2 ", params: ["\(i.data["customer_code"]!)", countryId])
                            
                            if let r = rsp?.first {
                                var retCode:[String:Any] = [:]
                                
                                // lets redeem the code now
                                let redeemed        = CCXServiceClass.sharedInstance.getNow()
                                let redeemedby      = request.session!.userid
                                
                                ct.to(r)
                                
                                ct.redeemed         = redeemed
                                ct.redeemedby       = redeemedby
                                ct.status           = CodeTransactionCodes.merchant_pending
                                if let _            = try? ct.saveWithCustomType(schemaIn: schema, redeemedby) {
                                    
                                    // this means it was saved - audit and archive
                                    AuditFunctions().redeemCustomerCodeAuditRecord(ct)
                                    
                                    // update the users record
                                    UserBalanceFunctions().adjustUserBalance(schemaId: nil ,redeemedby, countryid: ct.country_id!, increase: ct.amount!, decrease: 0.0)
                                    
                                    // prepare the return
                                    retCode["amount"] = ct.amount!
                                    
                                    let wallet = UserBalanceFunctions().getConsumerBalances(redeemedby)
                                    if wallet.count > 0 {
                                        retCode["buckets"] = wallet
                                    }
                                    
                                    // now archive the record
                                    ct.archiveRecord()
                                    
                                    nbr_added += 1
                                    
                                }
                            }
                        }
                    }
                    
                    endmessage = "Added \(nbr_added) transactions and redeemed them to your account!"
                    
                }
                
                    // update the balances table eventially (now that we have country codes)

                
                _=try? response.setBody(json: ["message": endmessage])
                return response.completed(status: .ok)
            }
        }
    }
}

fileprivate extension HTTPRequest {
    var qrCodeCount : Int {
        return self.header(.custom(name: "count")).intValue ?? 20
    }
    var qrCodeSize : Int {
        return self.header(.custom(name: "size")).intValue ?? 150
    }
    var email : String? {
        return self.header(.custom(name: "email")).stringValue
    }
}
