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
    
    //MARK: - Web Routes:
    struct web {
        // POST request for login
        static var routes : [[String:Any]] {
            return [
                ["method":"post", "uri":"/login", "handler":login],
                ["method":"get", "uri":"/forgotpassword", "handler":forgotPassword],
                ["method":"post", "uri":"/forgotpasswordEntered", "handler":forgotPasswordEntered],
            ]
        }
        
        public static func forgotPassword(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                response.render(template: "views/forgotpassword")
                response.completed()
                
            }
        }
        
        public static func forgotPasswordEntered(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // get the email:
                guard let email = request.param(name: "email") else { return }
                // Okay see if we can find the account:
                let find = Account()
                try? find.find(["email":email])
                
                if !find.id.isEmpty {
                    // okay.  we need to create their pass reset thingy and send an email:
                    
                    find.passreset = AccessToken.generate()
                    
                    if (try? find.save()).isNotNil {
                        let h = "<p>To reset your password for your account, please <a href=\"\(AuthenticationVariables.baseURL)/verifyAccount/forgotpassword/\(find.passreset)\">click here</a></p>"
                        
                        response.render(template: "views/forgotpassword", context: ["msg_body":"We sent a confirmation email to \(email).","msg_title":"Success!"])
                        response.completed()
                        
                        Utility.sendMail(name: find.username, address: email, subject: "Password reset!", html: h, text: "")
                    } else {
                        
                        response.render(template: "views/forgotpassword", context: ["msg_body":"Please try again.","msg_title":"Unknown Error."])
                        response.completed()
                        
                    }
                    
                } else {
                    // Show an error:
                    response.render(template: "views/forgotpassword", context: ["msg_body":"We had an issue looking up this email.","msg_title":"Forgot Password Error"])
                    response.completed()
                }
                
            }
        }
        
        public static func login(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                var template = "views/msg" // where it goes to after
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
                var context: [String : Any] = ["title": "Bucket Technologies", "subtitle":"Goodbye coins, Hello Change"]
                context["csrfToken"] = request.session?.data["csrf"] as? String ?? ""
                
                if let email = request.param(name: "email").stringValue, !email.isEmpty,
                    let password = request.param(name: "password").stringValue, !password.isEmpty {
                    do {
                        let account = try Account.loginWithEmail(email, password)
                        request.session?.userid = account.id
                        context["msg_title"] = "Login Successful."
                        context["msg_body"] = ""
                        response.redirect(path: "/")
                    } catch {
                        context["msg_title"] = "Login Error."
                        context["msg_body"] = "Email or password incorrect"
                        template = "views/login"
                    }
                } else {
                    context["msg_title"] = "Login Error."
                    context["msg_body"] = "Email or password not supplied"
                    template = "views/login"
                }
                response.render(template: template, context: context)
                response.completed()
            }
        }
    }
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
                // BALANCE ENDPOINT:
                ["method":"get",    "uri":"/api/v1/balance", "handler":balance],
                ["method":"get",    "uri":"/api/v1/balance/{countryId}", "handler":balanceWithCountry],
                // TRANSACTION ENDPOINTS:
                ["method":"get",    "uri":"/api/v1/history", "handler":transactionHistory],
                ["method":"get",    "uri":"/api/v1/redeem/{customerCode}", "handler":redeemCode],
                // CASHOUT ENDPOINTS:
                ["method":"get",    "uri":"/api/v1/cashout/{countryCode}/groups", "handler":cashoutTypes],
                ["method":"get",    "uri":"/api/v1/cashout/{groupId}/options", "handler":cashoutOptions],
                ["method":"post",    "uri":"/api/v1/cashout/{optionId}", "handler":cashout]
            ]
        }
        //MARK: - Balance Function:
        public static func balance(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check the user:
                guard !Account.userBouce(request, response) else { return }
                
                let buckets = UserBalanceFunctions().getConsumerBalances(request.session!.userid)
                try? response.setBody(json: ["buckets":buckets])
                    .completed(status: .ok)
                
            }
        }
        //MARK: - Balance Function (With Country):
        public static func balanceWithCountry(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check the user:
                guard !Account.userBouce(request, response) else { return }
                guard let countryId = request.countryId else { return response.invalidCountryCode }
                
                let amount =
                    UserBalanceFunctions().getCurrentBalance(request.session!.userid, countryid: countryId)
                try? response.setBody(json: ["amount":amount])
                    .completed(status: .ok)
                
            }
        }
        
        //MARK: - Transaction History
        public static func transactionHistory(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBouce(request, response) else { return }
                
                guard let countryid = request.countryId, countryid > 0 else { response.invalidCountryCode; return }
                
                let transType = request.transactionType?.uppercased() ?? "ALL"
                
                let pagination = request.getOffsetLimit()
                
                let userId = request.session!.userid
                
                let schema = Country.getSchema(request)
                
                // Okay we are finding the transaction history - it is all in the code_transaction_history table
                var sql = "SELECT cth.* "

                // we do not need the retailer for cashouts - there will be no retailer for that type.
                if transType != "CASHOUT" {
                    sql.append(", r.name FROM \(schema).code_transaction_history AS cth ")
                    sql.append("LEFT JOIN \(schema).retailer AS r ")
                    sql.append("ON cth.retailer_id = r.id ")
                } else {
                    sql.append("FROM \(schema).code_transaction_history AS cth ")
                }

                sql.append("WHERE cth.redeemedby = '\(userId)' ")
                sql.append("AND cth.country_id = \(countryid) ")
                sql.append("AND cth.deleted = 0 ")
                
                switch transType {
                case "SCAN":
                    sql.append("AND cth.customer_code <> '' ")
                    break
                case "CASHOUT":
                    sql.append("AND (cth.customer_code = '' OR cth.customer_code IS NULL) ")
                    break
                default:
                    // this is both scan and cashout - so do not include the cashout detail records
                    sql.append("OR (cth.cashedout > 0 AND (cth.customer_code = '' OR cth.customer_code IS NULL)) ")
                    break
                }

                sql.append("ORDER BY redeemed DESC ")
                
                if pagination.limitNumber > 0 {
                    sql.append("LIMIT \(pagination.limitNumber) ")
                }
                
                if pagination.offsetNumber > 0 {
                    sql.append("OFFSET \(pagination.offsetNumber) ")
                }
                
                print(sql)
                
                var substuff:[Any] = []
                
                let cth = CodeTransactionHistory()
                
                let res = try? cth.sqlRows(sql, params: [])
                if res.isNotNil {

                    // lets setup the return
                    // note - if the batch ID is not present, the code has not been redeemed.  If the batch ID is there the code has been completed.

                    for i in res! {
                        var tmp:[String:Any] = [:]
                        tmp["amount"] = i.data["amount"].doubleValue
                        tmp["status"] = i.data["status"]
                        
                        if let thetime = i.data["cashedout"].intValue, thetime > 0 {
                            tmp["type"] = "cashout"
                            tmp["description"] = i.data["cashedout_note"]
                            tmp["amount"] = i.data["cashedout_total"]
                            tmp["created"] = thetime.dateString
                        } else {
                            tmp["type"] = "scan"
                            if let thetime = i.data["redeemed"].intValue {
                                tmp["created"] = thetime.dateString
                            }
                        }
                        
                        substuff.append(tmp)
                    }
                } else {
                    // THis is most likely an issue with the schema.  Send back unsupported country:
                    return response.unsupportedCountry
                }

                let mainReturn:[String:Any] = ["transactions":substuff]
                
                let _ = try? response.setBody(json: mainReturn)
                response.completed(status: .ok)
                
            }
        }

        //MARK: - Redeem The Transaction:
        public static func redeemCode(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBouce(request, response) else { return }
                
                // Okay, the user is logged in and we have their id!  Lets see if we have the customer code!
                guard let customerCode = request.customerCode, !customerCode.isEmpty else { return response.invalidCode }
                
                // grab the schema from the code
                let index = customerCode.index(of: ".")!
                let schema = customerCode[...index].lowercased()
                
                // Awesome.  We have the customer code, and a user.  Now, we need to find the transaction and mark it as redeemed, and add the value to the ledger table!
                let ct = CodeTransaction()
                let rsp = try? ct.sqlRows("SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE customer_code = $1", params: ["\(request.customerCode!)"])
                
                if rsp?.first.isNil == true {
                    // if we did not find it, check histry to see if we have already redeemed it (we are using the summary table in the public schema
                    // to avoid performance costly functions looking thru schemas
                    let strs = CodeTransactionHistory()
                    let rsp2 = try? strs.sqlRows("SELECT * FROM \(schema).code_transaction_history WHERE customer_code = $1", params: ["\(request.customerCode!)"])
                    if let t = rsp2?.first?.data, (t["created"] as! Int) > 0 {
                        response.invalidCustomerCodeAlreadyRedeemed
                    } else {
                        response.invalidCustomerCode
                    }
                    return
                }
                
                var retCode:[String:Any] = [:]
                
                // lets redeem the code now
                let redeemed        = CCXServiceClass.sharedInstance.getNow()
                let redeemedby      = request.session!.userid
                try? ct.get(rsp!.first!.data.id!)
                
                ct.redeemed         = redeemed
                ct.redeemedby       = redeemedby
                ct.status           = CodeTransactionCodes.merchant_pending
                if let _            = try? ct.saveWithCustomType(schemaIn: schema, redeemedby) {
                    
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
                
                //return the correct codes
                if retCode.count > 0 {
                    _=try? response.setBody(json: retCode)
                    response.completed(status: .ok)
                    return
                    
                } else {
                    // there was a problem....
                    response.completed(status: .custom(code: 500, message: "There was a problem pulling the data from the tables."))
                    return
                }
            
                
            }
        }
        //MARK: - Cashout Options:
        public static func cashoutOptions(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBouce(request, response) else { return }

                guard let groupId = request.groupId, groupId != 0 else { return response.invalidGroupCode }

                guard let countryId = request.countryId, countryId != 0 else { return response.invalidCountryCode }

                // get the correct country
                let schema = Country.getSchema(request)
                
                var sqlstatement = "SELECT * FROM \(schema).cashout_option_view_deleted_no AS coo "
                sqlstatement.append("WHERE group_id = $1 ")
                sqlstatement.append("AND display = true ")
                sqlstatement.append("ORDER BY display_order ASC ")

                let qp = request.getOffsetLimit()
                if qp.limitNumber > 0 {
                    sqlstatement.append(" LIMIT \(qp.limitNumber) ")
                }
                if qp.offsetNumber > 0 {
                    sqlstatement.append(" OFFSET \(qp.offsetNumber) ")
                }
                
                // Here we need to get all the modes, and get all the fields
                let cashoutOptions = CashoutOption()
                let res = try? cashoutOptions.sqlRows(sqlstatement, params: ["\(groupId)"])

                var retJSON:[String:Any] = [:]

                if res.isNotNil {

                    var retJSONSub:[[String:Any]] = []

                    for i in res! {
                        var optdict:[String:Any] = [:]

                        optdict["id"] = i.data.id!
                        optdict["minimumAmount"] = i.data.cashoutOptionsDic.minimum
                        optdict["longDescription"] = i.data.cashoutOptionsDic.longDescription
                        optdict["name"] = i.data.cashoutOptionsDic.name
                        optdict["description"] = i.data.shortdescription
                        optdict["website"] = i.data.cashoutOptionsDic.website
                        if let value = i.data.cashoutOptionsDic.maximum, value > 0 {
                            optdict["maximumAmount"] = value
                        }

                        if let image = i.data.cashoutOptionsDic.pictureURL, image.length > 1 {
                            
                            var imgdict:[String:Any] = [:]
                            // check to see if the image contains http
                            let testimage = image.lowercased()
                            if testimage.contains(string: "http") {
                                imgdict["small"] = image
                                imgdict["large"] = image
                                imgdict["icon"]  = image
                            } else {
                                if let imageurl = EnvironmentVariables.sharedInstance.ImageBaseURL {
                                    imgdict["small"] = "\(imageurl)/small/\(image)"
                                    imgdict["large"] = "\(imageurl)/large/\(image)"
                                    imgdict["icon"]  = "\(imageurl)/icon/\(image)"
                                }
                            }
                            
                            // add the images to the return
                            optdict["image"] = imgdict
                            
                        }
                        
                        // pull in the form fields and add them
                        let fields = SupportFunctions.sharedInstance.getFormFields(i.data.cashoutOptionsDic.formId!)
                        optdict["fields"] = fields

                        retJSONSub.append(optdict)

                    }
                    
                    retJSON["options"] = retJSONSub
                    
                } else {
                    // This is an error with the country id existing, but the schema not being supported.
                    return response.unsupportedCountry
                    
                }
                
                let _ = try? response.setBody(json: retJSON)
                response.completed(status: .ok)

            }
        }
        
        //MARK: - Cashout Types:
        public static func cashoutTypes(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBouce(request, response) else { return }

                // Here we need to get all the modes, and get all the fields
                guard let countryCode = request.countryCode else { return response.invalidCountryCode }

                // get the country for the code
                let schema = Country.getSchema(countryCode)
                
                var countsql = "SELECT cog.*, COUNT(coo.id) AS option_count "
                countsql.append("FROM \(schema).cashout_group AS cog ")
                countsql.append("JOIN \(schema).cashout_option AS coo ")
                countsql.append("ON cog.id = coo.group_id ")
                countsql.append("WHERE cog.country_id = $1 ")
                countsql.append("AND cog.display = true ")
                countsql.append("AND cog.deleted = 0 ")
                countsql.append("AND coo.deleted = 0 ")
                countsql.append("GROUP BY cog.id ")
                countsql.append("ORDER BY cog.display_order ASC ")

                let qp = request.getOffsetLimit()
                if qp.limitNumber > 0 {
                    countsql.append(" LIMIT \(qp.limitNumber) ")
                }
                if qp.offsetNumber > 0 {
                    countsql.append(" OFFSET \(qp.offsetNumber) ")
                }
                
                // now lets get the types for this country
                let cg = CashoutGroup()
                
                // you may pass in either the number or the country code
                var codes = ""
                if countryCode.isNumeric() {
                    codes = countryCode
                } else {
                    codes = String(SupportFunctions.sharedInstance.getCountryId(countryCode))
                }
        
                let res = try? cg.sqlRows(countsql, params: [codes])

                if res.isNotNil {
                    // creating the return JSON with results
                    var retJSONSub:[[String:Any]] = []
                    for i in res! {
                        // put it together..
                        var s:[String:Any] = [:]
                        if let _ = i.data.id { s["id"] = i.data.id! }
                        if let name = i.data.cashoutGroupDic.group_name { s["name"] = name }
                        if let desc = i.data.cashoutGroupDic.description { s["description"] = desc }
                        if let countryId = i.data.cashoutGroupDic.country_id { s["countryId"] = countryId }
                        if let optionCount = i.data["option_count"] {
                            s["optionCount"] = optionCount
                            if let optionLayout = i.data["option_layout"] { s["optionLayout"] = optionLayout }
                        }

                        if let image = i.data.cashoutGroupDic.picture_url, image.length > 1 {

                            var imgdict:[String:Any] = [:]
                            // check to see if the image contains http
                            let testimage = image.lowercased()
                            if testimage.contains(string: "http") {
                                imgdict["small"] = image
                                imgdict["large"] = image
                                imgdict["icon"]  = image
                            } else {
                                if let imageurl = EnvironmentVariables.sharedInstance.ImageBaseURL {
                                    imgdict["small"] = "\(imageurl)/small/\(image)"
                                    imgdict["large"] = "\(imageurl)/large/\(image)"
                                    imgdict["icon"]  = "\(imageurl)/icon/\(image)"
                                }
                            }
                            
                            // add the images to the return
                            s["image"] = imgdict
                        }
                        
                        // add this entry to the array of entries
                        retJSONSub.append(s)
                    }
                    
                    let retJSON:[String:Any] = ["groups":retJSONSub]
                    
                    let _ = try? response.setBody(json: retJSON)
                    response.completed(status: .ok)
                } else {
                    // error that none were found
                    return response.unsupportedCountry
                }
                
                
            }
        }
        
        //MARK: - Cashout:
        public static func cashout(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBouce(request, response) else { return }

                let userId = request.session?.userid
                
                // Okay we are finding the specific type, and grabbing the fields we need:
                var theoption = 0
                if let cooption = request.optionId.intValue, cooption > 0 {
                    theoption = cooption
                } else {
                    // option not sent in
                    return response.invalidOptionCode
                }
                
                // get the country code
                guard let countryId = request.countryId, countryId != 0 else { return response.invalidCountryCode }
                let schema = Country.getSchema(request)

                // lets get the minimum amount permitted
                let sqloption = "SELECT minimum, maximum, name, group_id FROM \(schema).cashout_option_view_deleted_no WHERE id = \(theoption)"
                let coop = CashoutOption()
                let resopt = try? coop.sqlRows(sqloption, params: [])
                
                var min_cashout  = 0.0
                var max_cashout  = 0.0
                var name_cashout = ""
                var group_id     = 0

                if resopt.isNotNil, let i = resopt?.first! {
                    min_cashout  = i.data["minimum"].doubleValue!
                    max_cashout  = i.data["maximum"].doubleValue!
                    name_cashout = i.data["name"].stringValue!
                    group_id     = i.data["group_id"].intValue!
                }
                
                
//                var country_id = 0
//                let sqlgroup = "SELECT country_id FROM cashout_group_view_deleted_no WHERE id = \(group_id)"
//                let cg = CashoutGroup()
//                let resultcg = try? cg.sqlRows(sqlgroup, params: [])
//                if resultcg.isNotNil {
//                    country_id = resultcg!.first!.data["country_id"].intValue!
//                }
                
                // get the cashout amount
                let amount_to_cashout = request.cashoutAmount!
                
                // make sure they are cashing out the correct amount
                if min_cashout > amount_to_cashout {
                    // RETURN AN ERROR:not requesting the minimum
                }
                
                // there are a couple of things we need to do.  First -- we need to loop thru the records - from oldest to newest (based on redeemed code dates)
                var sql = "SELECT id, amount, amount_available, customer_code, redeemedby "
                sql.append("FROM \(schema).code_transaction_history_view_deleted_no ")
                sql.append("WHERE redeemedby = '\(userId!)' ")
                sql.append("AND amount_available > 0 ")
//                sql.append("AND country_id = \(country_id) ")
                sql.append("ORDER BY redeemed ASC")
                let cth = CodeTransactionHistory()
                let cth_rec = try? cth.sqlRows(sql, params: [])
                
                // we will determine the records to use their entire amount and the records to use portions
                
                var included:[Int] = []
                var lastone = 0
                var lastoneamount:Double = 0.0
                var totalcount:Double = 0.0

                // calculate wiich records we will use for the cashout amount.
                if cth_rec.isNotNil {
                    for i in cth_rec! {
                        
                        if let tam = i.data["amount_available"].doubleValue {
                            if (totalcount + tam) <= amount_to_cashout {
                                totalcount += tam
                                included.append(i.data["id"].intValue!)
                            } else if totalcount < amount_to_cashout {
                                lastoneamount = amount_to_cashout - totalcount
                                lastone = i.data["id"].intValue!
                            }
                        }
                    }
                }
                
                // now we have the list of records to include and the final partial record
                if totalcount < amount_to_cashout {
                    // they do not have enough to cashout - something happened wrong here.
                    
                    // RETURN AN ERROR
                    
                }
                
                // process the records
                var thein = ""
                for i in included {
                    thein.append("\(i),")
                }
                // add the last one
                if lastone > 0 {
                    thein.append("\(lastone)")
                } else {
                    // get rid of the last comma
                    thein.removeLast()
                }
                
                // get the records together for us to process:
                let rec_sql = "SELECT * FROM \(schema).code_transaction_history_view_deleted_no WHERE id IN(\(thein))"
                
                let cth_cashedout = CCXServiceClass.sharedInstance.getNow()
                let cth_now = CodeTransactionHistory()
                let resul = try? cth_now.sqlRows(rec_sql, params: [])
                if resul.isNotNil {
                    for i in resul! {
                        let working_cth = CodeTransactionHistory()
                        working_cth.to(i)
                        
                        // update the available amount
                        if working_cth.id != lastone {
                            working_cth.amount_available = 0.0
                            working_cth.cashedout_total  = working_cth.amount
                        } else {
                            working_cth.amount_available = working_cth.amount! - lastoneamount
                            working_cth.cashedout_total  = lastoneamount
                        }
                        
                        working_cth.cashedout      = cth_cashedout
                        working_cth.cashedoutby    = userId!
                        working_cth.cashedout_note = "CASHOUT: \(name_cashout)"
                        
                        // we are complete - lets save and move on
                        let _ = try? working_cth.saveWithCustomType(schemaIn: schema)
                        
                        // Write the audit record
                        AuditFunctions().cashoutCustomerCodeAuditRecord(working_cth)

                    }
                    
                    // add the cashout record to the history record
                    let newrec = CodeTransactionHistory()
                    newrec.amount = 0.0
                    newrec.amount_available = 0.0
                    newrec.archived = cth_cashedout
                    newrec.archivedby = userId!
                    newrec.cashedout = cth_cashedout
                    newrec.cashedout_note = name_cashout
                    newrec.cashedout_total = amount_to_cashout
                    newrec.cashedoutby = userId!
                    newrec.country_id = countryId
                    newrec.redeemed = cth_cashedout
                    newrec.redeemedby = userId!
                    newrec.status = CodeTransactionCodes.cashout_pending
                    
                    let _ = try? newrec.saveWithCustomType(schemaIn: schema, userId!, copyOver: false)
                    
                    // add the cashout record
                    
                    
                    
                    
                    // this is where we show success
                    let _ = try? response.setBody(json: ["amount":amount_to_cashout,"country_id":countryId])
                    response.completed(status: .ok)
                    return
                }
                
                // the steps we need to take here now:
                // 1. Audit the record
                // 2. Update the available amount on the record
                // 3. Update the cashed out timestamp (and user) - all timestamps should be the same - that is the glue that holds the records together
                // 4. Add the total cashout amount to all records
                // 5. Add the cashout note to the records - this should be where they cashout to - it is displayed in history
                // 6. Save a new record to the history for a cashout record - without the coupon code.  This acts as the record for cashout for the API return.
                // 7. Update the user total (decrement by the cashout amount)
                // 8. Send the wonderful cashout message for a successful completion.
                
                
            }
        }
    }
}

fileprivate extension HTTPResponse {
    var invalidCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such code found"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .notAcceptable)
    }
    var invalidOptionCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such option code found"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .notAcceptable)
    }
    var invalidGroupCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such group code found"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .notAcceptable)
    }
    var invalidCustomerCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such code found"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 406, message: "The customer code was not found"))
    }
    var invalidCustomerCodeAlreadyRedeemed : Void {
        return try! self.setBody(json: ["errorCode":"CodeRedeemed", "message": "Code was already redeemed"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 410, message: "The customer code has been used already"))
    }

}

fileprivate extension HTTPRequest {
//    @available(*, deprecated, message: "no longer available in version v1.1")
    var customerCode : String? {
        return self.urlVariables["customerCode"]
    }
    var groupId : Int? {
        return self.urlVariables["groupId"].intValue
    }
    var optionId : Int? {
        return self.urlVariables["optionId"].intValue
    }
    var transactionType : String? {
        return self.queryParams.first(where: { (param) -> Bool in
            return param.0 == "transactionType"
        })?.1
    }
    var cashoutAmount : Double? {
        if let value = try? self.postBodyJSON()?["amount"].doubleValue, value.isNotNil {
            return value!
        }
        return 0.0
    }
    func getOffsetLimit() -> (offsetNumber:Int, limitNumber:Int) {
        
        var ol = 0, of = 0
        
        let qry = self.queryParams
        
        for i in qry {
            if i.0 == "offset" {
                if let ioo = i.1.intValue {
                    of = ioo
                }
            }
            if i.0 == "limit" {
                if let ioo = i.1.intValue {
                    ol = ioo
                }
            }
        }
        
        
        return (of, ol)
    }
}
