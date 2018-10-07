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
import PerfectThread

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
        static var retailer_names:[String] {
            return [
                "McDonald's",
                "Walmart",
                "7-11",
                "Home Depot",
                "Smart and Final",
                "99 Cents Store",
                "CVS",
                "Walgreens",
                "Kroger",
                "Rite Aid",
                "Starbucks",
                "Chick Fil-A",
                "Dollar General",
                "ARCO",
                "Panda Express"
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
                guard !Account.userBounce(request, response) else { return }
                
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
                    return response.noTerminalsInCountry(countryId: countryId)
                }
                
                let environment = EnvironmentVariables.sharedInstance.Server!

                let queue = Threading.getQueue(name: "code_email", type: .serial)
                queue.dispatch({
                    
                    print(" ")
                    print("//---------//")
                    print("STARTING 'code_email' queue: \(getNow())")
                    print("//---------//")
                    print(" ")

                    // make the variables thread-safe
                    let t_user = user
                    let t_term = term!
                    let t_schema = schema
                    let t_email = email
                    let t_environment = environment
                    
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
                        let transaction = CodeTransaction.qrCodeCreate(schema: t_schema,
                                                                       session: request.session?.token ?? "NO SESSION TOKEN",
                                                                       user: t_user,
                                                                       terminal: t_term,
                                                                       increment: i,
                                                                       minimum: 0.50)
                        
                        let theQRCodeURL = transaction?.customer_codeurl ?? ""
                        let theHTMLQrCodeURL = "https://api.qrserver.com/v1/create-qr-code/?data=\(theQRCodeURL)&size=\(codeSize)x\(codeSize)"
                        let imageHTML = "<img src='\(theHTMLQrCodeURL)' />"
                        
                        theHTML.append("<td >")
                        theHTML.append(imageHTML)
                        theHTML.append("</td> \n")
                        
                    }
                    
                    theHTML.append("</tr></table> \n")
                    theHTML.append("</body> \n")

                    Utility.sendMail(name: "Bucket Technologies", address: t_email, subject: "QR Code Generation for \(t_environment)", html: theHTML, text: "Please Enable HTML email to get your codes.")

                    print(" ")
                    print("//---------//")
                    print("ENDING 'code_email' queue: \(getNow())")
                    print("//---------//")

                })
                
                // Send the response:
                try? response.setBody(json: ["message":"Success!  Your QR codes are being processed, check your email."]).completed(status: .ok)
                return
                
            }
        }
        
        //MARK: - Generic Test Function
        public static func testFunction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // make sure we are NOT in production
                if EnvironmentVariables.sharedInstance.Server!.rawValue == "PROD" {
                    return response.functionNotOn
                }
                
                guard !Account.userBounce(request, response) else { return }
                
                // SET TESTING STUFF HERE:

                // get the logged in user
                if let user = request.account {
                    // add some retailers in the US

                    var dt = try? user.detail.jsonEncodedString()
                    print("Retailer Admin: \(dt ?? "")")

                    user.addRetailerAdmin("us", 1)
                    dt = try? user.detail.jsonEncodedString()
                    print("Retailer Admin: \(dt ?? "")")
                    
                    user.addRetailerAdmin("us", 2)
                    dt = try? user.detail.jsonEncodedString()
                    print("Retailer Admin: \(dt ?? "")")

                    user.addRetailerAdmin("us", 3)
                    dt = try? user.detail.jsonEncodedString()
                    print("Retailer Admin: \(dt ?? "")")

//                    user.addRetailerAdmin("sg", 1)
//                    dt = try? user.detail.jsonEncodedString()
//                    print("Retailer Admin: \(dt ?? "")")

//                    user.deleteRetailerAdmin("us", 2)
//                    dt = try? user.detail.jsonEncodedString()
//                    print("Retailer Admin: \(dt ?? "")")
//
//                    user.deleteRetailerAdmin("us", 1)
//                    dt = try? user.detail.jsonEncodedString()
//                    print("Retailer Admin: \(dt ?? "")")

                }

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
                    return response.functionNotOn
                }
                
                guard !Account.userBounce(request, response) else { return }
            
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

                var endmessage:[String:Any] = [:]
                // lets redeem the code now
                let redeemed        = CCXServiceClass.sharedInstance.getNow()
                let user = request.session!.userid
            
                // SECTION 1: Delete all the existing test records for the user and the country
                // BUT: only if the count == 0
                // get the count
                let cnt = request.header(.custom(name: "count")).intValue ?? 20


                // SECTION 2: Get a terminal for a retailer for the country
                
                // look for a retailer in the country we are using
                var add_id = 0
                let sql_add = "SELECT id from \(schema).address WHERE retailer_id > 0 AND country_id = \(countryId.intValue!)"
                let addy = Address()
                let addy_ret = try? addy.sqlRows(sql_add, params: [])
                if addy_ret.isNotNil {
                    // grab the address id to look up in the terminal file
                    // set the add_id
                    add_id = addy_ret?.first?.data["id"].intValue ?? 0
                } else {
                    // error that there is no terminal for that country code
                    // error must return an error code for the response and get out of this flow
                    return response.noRetailersInCountry(countryId: countryId.intValue!)
                }
                
                // look for a terminal
                let term = Terminal.getFirst(schema)
                if term.isNil {
                    return response.noTerminalsInCountry(countryId: countryId.intValue!)
                } 

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
                            _ = try? ctt.saveWithCustomType(schemaIn: schema, user)

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
                            _ = try? ctth.saveWithCustomType(schemaIn: schema, user)
                            
                            // decrement the users balance
                            UserBalanceFunctions().adjustUserBalance(schemaId: nil, user, countryid: ctth.country_id!, increase: 0.00, decrease: ctth.amount!)
                            
                            if schema == "us" { AuditFunctions().deleteCustomerCodeAuditRecord(ctth) }
                            
                        }
                    }
                    
                    // set the account balance to 0
                    let sql_del = "UPDATE public.user_total SET balance = 0.0 WHERE country_id = \(countryId.intValue!) AND user_id = '\(user)'"
                    let _ = try? current_codes.sqlRows(sql_del, params: [])
                    
                    endmessage["message"] = "Transactions were removed from your account!"
                    
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
                        CodeTransaction.qrCodeCreate(schema: schema,
                                                     session: request.session?.token ?? "NO SESSION TOKEN",
                                                     user: user,
                                                     terminal: term!,
                                                     increment: i,
                                                     minimum: 0.50)
                    }
                    
                    // SECTION 4: Claim the customer codes we just added (to make sure the process is working correctly)
                    
                    let reup_sql = "SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE client_location LIKE ('TESTING_\(user)_%') AND country_id = \(countryId)"
                    let reup_ct = CodeTransaction()
                    let reup_res = try? reup_ct.sqlRows(reup_sql, params: [])
                    
                    let number_of_retailers = Double(self.retailer_names.count)
                    
                    if reup_res.isNotNil {

// we removed the threading for this response.  The problem is tha tthe front end is execting the wallet amounts and they are not getting it
// because of the threading.  This makes the frnt end have problems getting off the page and showing the correct waller amounts.
// back to non-threaded responses.
//                        let queue = Threading.getQueue(name: "code_claim", type: .serial)
                        
//                        queue.dispatch({
                            
                            let t_schema = schema
                            let t_countryId = countryId
                            let t_user = user
                            let t_redeemed = redeemed
                            let t_number_of_retailers = number_of_retailers
                            
                            print(" ")
                            print("//---------//")
                            print("STARTING 'code_claim' queue: \(getNow())")
                            print("//---------//")
                            print(" ")

                            for i in reup_res! {
                                
                                // redeem the transactions
                                
                                let ct = CodeTransaction()
                                let rsp = try? ct.sqlRows("SELECT * FROM \(t_schema).code_transaction_view_deleted_no WHERE customer_code = $1 AND country_id = $2 ", params: ["\(i.data["customer_code"]!)", t_countryId])
                                
                                if let r = rsp?.first {
                                    
                                    ct.to(r)
                                    
                                    ct.redeemed         = t_redeemed
                                    ct.redeemedby       = t_user
                                    ct.status           = CodeTransactionCodes.merchant_pending
                                    
                                    // set the random retailer
                                    // rnd is between 0.0 and 1.0
                                    let rnd = drand48()
                                    var this_retailer_name = ""
                                    if rnd > 0.0 {
                                        let retailer_raw = rnd * (t_number_of_retailers - 1)
                                        let retailer_index = Int(retailer_raw.rounded())
                                        this_retailer_name = retailer_names[retailer_index]
                                    } else {
                                        this_retailer_name = retailer_names[0]
                                    }
                                    ct.description = this_retailer_name
                                    
                                    if let _            = try? ct.saveWithCustomType(schemaIn: t_schema, t_user) {
                                        
                                        // now archive the record
                                        ct.archiveRecord()
                                        
                                        // this means it was saved - audit and archive
                                        AuditFunctions().redeemCustomerCodeAuditRecord(ct)
                                        
                                        // update the users record
                                        UserBalanceFunctions().adjustUserBalance(schemaId: nil ,t_user, countryid: ct.country_id!, increase: ct.amount!, decrease: 0.0)
                                        
                                        nbr_added += 1
                                        
                                    }
                                }
                            }

                            let wallet = UserBalanceFunctions().getConsumerBalances(t_user)
                            if wallet.count > 0 {
                                endmessage["buckets"] = wallet
                            }

                            print(" ")
                            print("//---------//")
                            print("ENDING 'code_claim' queue: \(getNow())")
                            print("//---------//")

//                        })

                    }

                    endmessage["message"] = "We are adding transactions and redeemed them to your account!"
                    
                }
                
                // update the balances table eventially (now that we have country codes)
                _=try? response.setBody(json: endmessage)
                return response.completed(status: .ok)
                
            }
        }
    }
}

fileprivate extension HTTPResponse {
    func noRetailersInCountry(countryId : Int) -> Void {
        return try! self.setBody(json: ["error":"There are no retailers in country id \(countryId)"]).completed(status: .custom(code: 450, message: "No Retailers in Country \(countryId)"))
    }
    func noTerminalsInCountry(countryId : Int) -> Void {
        return try! self.setBody(json: ["errorCode":"NoTerminalsInCountry","message":"There are no terminals in country id \(countryId)"]).completed(status: .custom(code: 451, message: "No Terminals in Country \(countryId)"))
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
