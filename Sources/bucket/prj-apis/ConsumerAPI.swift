//
//  ConsumerAPI.swift
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

//MARK: - Consumer API
/// This Consumer structure supports all the normal endpoints for a user based login application.
struct ConsumerAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
                // BALANCE ENDPOINT:
                ["method":"post",    "uri":"/api/v1/balance", "handler":balance],
                ["method":"post",    "uri":"/api/v1/balance/{countryId}", "handler":balanceWithCountry],
                // TRANSACTION ENDPOINTS:
                ["method":"post",    "uri":"/api/v1/history", "handler":transactionHistory],
                ["method":"post",    "uri":"/api/v1/redeem/{customerCode}", "handler":redeemCode],
                // CODE BALANCE
                ["method":"get",    "uri":"/api/v1/redeem/{customerCode}", "handler":codeBalance],
                // CASHOUT ENDPOINTS:
                ["method":"post",    "uri":"/api/v1/cashout/{countryCode}/groups", "handler":cashoutTypes],
                ["method":"post",    "uri":"/api/v1/cashout/{groupId}/options", "handler":cashoutOptions],
                ["method":"post",    "uri":"/api/v1/cashout/{optionId}", "handler":cashout],
                // Recommend A Retailer
                ["method":"post",    "uri":"/api/v1/referRetailer", "handler":referRetailer]
            ]
        }
        //MARK: - Balance Function:
        public static func balance(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check the user:
                guard !Account.userBounce(request, response) else { return }
                
                AuditRecordActions.pageView(schema: "public",
                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                            page: "/api/v1/balance",
                                            row_data: nil,
                                            description: nil,
                                            viewedby: request.session!.userid)
                
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
                guard !Account.userBounce(request, response) else { return }
                guard let countryId = request.countryId else { return response.invalidCountryCode }
                
                AuditRecordActions.pageView(schema: "public",
                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                            page: "/api/v1/balance/{countryId}",
                                            row_data: ["countryId":countryId],
                                            description: nil,
                                            viewedby: request.session!.userid)

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
                guard !Account.userBounce(request, response) else { return }
                
                guard let countryid = request.countryId, countryid > 0 else { response.invalidCountryCode; return }
                
                let transType = request.transactionType?.uppercased() ?? "ALL"
                
                let pagination = request.getOffsetLimit()
                
                let userId = request.session!.userid
                
                let schema = Country.getSchema(request)
                
                // Okay we are finding the transaction history - it is all in the code_transaction_history table
                var sql = "SELECT cth.* "

                // we do not need the retailer for cashouts - there will be no retailer for that type.
//                if transType != "CASHOUT" {
                    sql.append(", r.name FROM \(schema).code_transaction_history_view_deleted_no AS cth ")
                    sql.append("LEFT JOIN \(schema).retailer AS r ")
                    sql.append("ON cth.retailer_id = r.id ")
//                } else {
//                    sql.append("FROM \(schema).code_transaction_history AS cth ")
//                }

                sql.append("WHERE cth.redeemedby = '\(userId)' ")
                sql.append("AND ")
                sql.append("((cth.country_id = \(countryid) ")
                sql.append("AND cth.country_id = \(countryid) ")
                sql.append("AND cth.deleted = 0) ")
                
                switch transType {
                case "SCAN":
                    sql.append("AND (cth.customer_code <> '') ) ")
                    break
                case "CASHOUT":
                    sql.append(" AND (cth.customer_code = '' OR cth.customer_code IS NULL) ) ")
                    break
                default:
                    // this is both scan and cashout - so do not include the cashout detail records
                    sql.append("OR (cth.cashedout > 0 AND (cth.customer_code = '' OR cth.customer_code IS NULL)) ) ")
                    break
                }

                sql.append("ORDER BY cth.redeemed DESC, ")
                sql.append("cth.amount DESC, ")
                sql.append("cth.description DESC ")

                if pagination.limitNumber > 0 {
                    sql.append("LIMIT \(pagination.limitNumber) ")
                }
                
                if pagination.offsetNumber > 0 {
                    sql.append("OFFSET \(pagination.offsetNumber) ")
                }
                
                print(sql)
                
                var callParms:[String:Any] = [:]
                callParms["LIMIT"] = "\(pagination.limitNumber)"
                callParms["OFFSET"] = "\(pagination.offsetNumber)"
                callParms["country_id"] = "\(countryid)"
                callParms["redeemedby"] = "\(userId)"

                
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
                        
                        if let thetime = i.data["cashedout"].intValue, thetime > 0, let co = i.data["amount"].doubleValue, co == 0.0 {
                            tmp["type"] = "cashout"
                            tmp["description"] = i.data["cashedout_note"]
                            tmp["amount"] = i.data["cashedout_total"].doubleValue
                            tmp["created"] = thetime.dateString
                        } else {
                            tmp["type"] = "scan"
                            if let thetime = i.data["redeemed"].intValue {
                                tmp["created"] = thetime.dateString
                            }
                            if let d = i.data["description"].stringValue {
                                tmp["description"] = d
                            } else if let d = i.data["name"].stringValue {
                                tmp["description"] = d
                            }
                        }
                        
                        substuff.append(tmp)
                    }
                } else {
                    // THis is most likely an issue with the schema.  Send back unsupported country:
                    return response.unsupportedCountry
                }

                let mainReturn:[String:Any] = ["transactions":substuff]
                
                var audit:[String:Any] = mainReturn
                audit["parms"] = callParms
                
                AuditRecordActions.pageView(schema: schema,
                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                            page: "/api/v1/history",
                                            row_data: audit,
                                            description: nil,
                                            viewedby: request.session!.userid)
                
                let _ = try? response.setBody(json: mainReturn)
                response.completed(status: .ok)
                
            }
        }

        //MARK: - Check The Code Balance:
        public static func codeBalance(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
//                guard !Account.userBounce(request, response) else { return }
                
                // Okay, the user is logged in and we have their id!  Lets see if we have the customer code!
                guard let customerCode = request.customerCode, !customerCode.isEmpty else { return response.invalidCode }
                if !customerCode.contains(string: ".") { return response.invalidCode }
                
                // grab the schema from the code
                let index = customerCode.index(of: ".")!
                var schema = customerCode[...index].lowercased()
                schema.removeLast()
                
                // Awesome.  We have the customer code, and a user.  Now, we need to find the transaction and mark it as redeemed, and add the value to the ledger table!
                let ct = CodeTransaction()
                
                // make sure the schema exists - if not we do not service that country
                let sqls = "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '\(schema)'"
                let sct = try? ct.sqlRows(sqls, params: [])
                guard let _ = sct?.first else { return response.unsupportedCountry }
                
                // ok - now we can keep going :)
                let rsp = try? ct.sqlRows("SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE customer_code = $1", params: ["\(request.customerCode!)"])
                
                if rsp?.first.isNil == true {
                    // if we did not find it, check history to see if we have already redeemed it (we are using the summary table in the public schema
                    // to avoid performance costly functions looking thru schemas
                    // (do not use the view deleted no because we want to make sure it was not redeemed and deleted)
                    let strs = CodeTransactionHistory()
                    let rsp2 = try? strs.sqlRows("SELECT * FROM \(schema).code_transaction_history WHERE customer_code = $1", params: ["\(request.customerCode!)"])
                    if let t = rsp2?.first?.data, (t["created"] as! Int) > 0 {
                        
                        AuditRecordActions.customerCodeCheck(schema: schema,
                                                             session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                             row_data: ["customer_code":request.customerCode ?? "NO CODE"],
                                                             changed_fields: nil,
                                                             description: "Code already redeemed.",
                                                             changedby: nil)
                        
                        response.invalidCustomerCodeAlreadyRedeemed
                    } else {
                        
                        AuditRecordActions.customerCodeCheck(schema: schema,
                                                             session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                             row_data: ["customer_code":request.customerCode ?? "NO CODE"],
                                                             changed_fields: nil,
                                                             description: "Code does not exist.",
                                                             changedby: nil)
                        
                        response.invalidCustomerCode
                    }
                    return
                }
                
                var retCode:[String:Any] = [:]
                
                let userid      = request.session?.userid ?? "PUBLIC"
                
                let sql = "SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE id = \(rsp!.first!.data.id!)"
                let ctr = try? ct.sqlRows(sql, params: [])
                if let c = ctr!.first {
                    ct.to(c)
                }
                
                // if the code is a sample code, see if this is a sample user
                if ct.isSample() {
                    
                    let testA = Account()
                    _ = try? testA.get(userid)
                    
                    if testA.id.isEmpty {
                        
                        AuditRecordActions.customerCodeCheck(schema: schema,
                                                             session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                             row_data: ["customer_code":request.customerCode ?? "NO CODE","user_id":userid],
                                                             changed_fields: nil,
                                                             description: "Code is a SAMPLE code.  We could not find the user account.",
                                                             changedby: nil)
                        
                        // we did not pull the account - returh the error
                        return response.unableToGetUser
                    }
                    
                    if !testA.isSample() {
                        
                        AuditRecordActions.customerCodeCheck(schema: schema,
                                                             session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                             row_data: ["customer_code":request.customerCode ?? "NO CODE","user_id":userid],
                                                             changed_fields: nil,
                                                             description: "Code is a SAMPLE code.  The user is not a SAMPLE user.",
                                                             changedby: nil)

                        // this is a sample being redeemed on a non-sample account - NO
                        return response.sampleCodeRedeemError
                    }
                    
                }
                
                // prepare the return
                retCode["amount"] = ct.amount!
                    
                
                //return the correct codes
                if retCode.count > 0 {
                    
                    AuditRecordActions.customerCodeCheck(schema: schema,
                                                         session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                         row_data: ["customer_code":request.customerCode ?? "NO CODE",
                                                                    "user_id":userid,
                                                                    "amount": ct.amount!],
                                                         changed_fields: nil,
                                                         description: "Code value returned",
                                                         changedby: nil)
                    
                    _=try? response.setBody(json: retCode)
                    response.addHeader(HTTPResponseHeader.Name.cacheControl, value: "no-cache")
                    response.completed(status: .ok)
                    return
                    
                } else {
                    // there was a problem....
                    response.completed(status: .custom(code: 500, message: "There was a problem pulling the data from the tables."))
                    return
                }
                
            }
        }

        //MARK: - Redeem The Transaction:
        public static func redeemCode(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBounce(request, response) else { return }
                
                // Okay, the user is logged in and we have their id!  Lets see if we have the customer code!
                guard let customerCode = request.customerCode, !customerCode.isEmpty else { return response.invalidCode }
                if !customerCode.contains(string: ".") { return response.invalidCode }
                
                // grab the schema from the code
                let index = customerCode.index(of: ".")!
                var schema = customerCode[...index].lowercased()
                schema.removeLast()
                
                // Awesome.  We have the customer code, and a user.  Now, we need to find the transaction and mark it as redeemed, and add the value to the ledger table!
                let ct = CodeTransaction()
                
                // make sure the schema exists - if not we do not service that country
                let sqls = "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '\(schema)'"
                let sct = try? ct.sqlRows(sqls, params: [])
                guard let _ = sct?.first else { return response.unsupportedCountry }
                
                // ok - now we can keep going :)
                let rsp = try? ct.sqlRows("SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE customer_code = $1", params: ["\(request.customerCode!)"])
                
                if rsp?.first.isNil == true {
                    // if we did not find it, check history to see if we have already redeemed it (we are using the summary table in the public schema
                    // to avoid performance costly functions looking thru schemas
                    // (do not use the view deleted no because we want to make sure it was not redeemed and deleted)
                    let strs = CodeTransactionHistory()
                    let rsp2 = try? strs.sqlRows("SELECT * FROM \(schema).code_transaction_history WHERE customer_code = $1", params: ["\(request.customerCode!)"])
                    if let t = rsp2?.first?.data, (t["created"] as! Int) > 0 {
                        
                        AuditRecordActions.customerCodeRedeemed(schema: schema,
                                                             session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                             redeemedby: request.session?.userid ?? "NO USER, SESSION nil",
                                                             row_data: ["customer_code":request.customerCode ?? "NO CODE"],
                                                             changed_fields: nil,
                                                             description: "Code already redeemed.",
                                                             changedby: nil)

                        response.invalidCustomerCodeAlreadyRedeemed
                    } else {
                        
                        AuditRecordActions.customerCodeRedeemed(schema: schema,
                                                             session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                             redeemedby: request.session?.userid ?? "NO USER, SESSION nil",
                                                             row_data: ["customer_code":request.customerCode ?? "NO CODE"],
                                                             changed_fields: nil,
                                                             description: "Code does not exist.",
                                                             changedby: nil)

                        response.invalidCustomerCode
                    }
                    return
                }
                
                var retCode:[String:Any] = [:]
                
                // lets redeem the code now
                let redeemed        = CCXServiceClass.sharedInstance.getNow()
                let redeemedby      = request.session!.userid
                
                let sql = "SELECT * FROM \(schema).code_transaction_view_deleted_no WHERE id = \(rsp!.first!.data.id!)"
                let ctr = try? ct.sqlRows(sql, params: [])
                if let c = ctr!.first {
                    ct.to(c)
                }
                
                // if the code is a sample code, see if this is a sample user
                if ct.isSample() {
                    
                    let testA = Account()
                    _ = try? testA.get(redeemedby)
                    
                    if testA.id.isEmpty {
                        
                        AuditRecordActions.customerCodeRedeemed(schema: schema,
                                                             session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                             redeemedby: request.session?.userid ?? "NO USER, SESSION nil",
                                                             row_data: ["customer_code":request.customerCode ?? "NO CODE","user_id":redeemedby],
                                                             changed_fields: nil,
                                                             description: "Code is a SAMPLE code.  We could not find the user account.",
                                                             changedby: nil)
                        
                        // we did not pull the account - returh the error
                        return response.unableToGetUser
                    }
                    
                    if !testA.isSample() {
                        
                        AuditRecordActions.customerCodeRedeemed(schema: schema,
                                                             session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                             redeemedby: request.session?.userid ?? "NO USER, SESSION nil",
                                                             row_data: ["customer_code":request.customerCode ?? "NO CODE","user_id":redeemedby],
                                                             changed_fields: nil,
                                                             description: "Code is a SAMPLE code.  The user is not a SAMPLE user.",
                                                             changedby: nil)
                        
                        // this is a sample being redeemed on a non-sample account - NO
                        return response.sampleCodeRedeemError
                    }

                }
                                
                // we are in the proper status now
                ct.redeemed         = redeemed
                ct.redeemedby       = redeemedby
                ct.status           = CodeTransactionCodes.merchant_pending
                if let _            = try? ct.saveWithCustomType(schemaIn: schema, redeemedby) {
                    
                    // now archive the record: this is a timing issue - we need to do this because of the auditing fucntions
                    ct.archiveRecord(redeemedby)

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
                    
                }
                
                //return the correct codes
                if retCode.count > 0 {
                    
                    AuditRecordActions.customerCodeRedeemed(schema: schema,
                                                         session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                         redeemedby: request.session?.userid ?? "NO USER, SESSION nil",
                                                         row_data: retCode,
                                                         changed_fields: nil,
                                                         description: "Code is a SAMPLE code.  The user is a SAMPLE user.",
                                                         changedby: nil)

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
                guard !Account.userBounce(request, response) else { return }

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
                    
                    var email : String? = nil
                    var fullname : String? = nil
                    // If the users email is Dan's, lets add in defaultValues:
                    if let em = request.account?.email, em == "ryancoyne.ccx@gmail.com" || em  == "daniel@wetinkprinting.com" {
                        email = "hello@buckettechnologies.com"
                        fullname = "Dan Kam"
                    }

                    for i in res! {
                        var optdict:[String:Any] = [:]

                        optdict["id"] = i.data.id!
                        
                        if let val = i.data.cashoutOptionsDic.longDescription, !val.isEmpty {
                            optdict["longDescription"] = val
                        }
                        
                        if let name = i.data.cashoutOptionsDic.name, !name.isEmpty {
                            optdict["name"] = name
                            // Replace the name with the occurance of the string - this is so we dont have to update two columns or any other column that would contain the name of the option.
                            if let cD = i.data.cashoutOptionsDic.confirmationDescription?.replacingOccurrences(of: "{name}", with: name), !cD.isEmpty {
                                optdict["confirmationDescription"] = cD
                            }
                        }
                        
//                        if let val = i.data.cashoutOptionsDic.name, !val.isEmpty {
//                            optdict["name"] = val
//                        }
                        
                        if let val = i.data.shortdescription, !val.isEmpty {
                            optdict["description"] = val
                        }
                        
                        if let val = i.data.cashoutOptionsDic.website, !val.isEmpty {
                            optdict["website"] = val
                        }
                        
                        if let value = i.data.cashoutOptionsDic.maximum, value > 0 {
                            optdict["maximumAmount"] = value
                        }
                        
                        if let value = i.data.cashoutOptionsDic.increment, value > 0 {
                            optdict["incrementAmount"] = value
                        }
                        
                        if let value = i.data.cashoutOptionsDic.minimum, value > 0 {
                            optdict["minimumAmount"] = value
                        }

                        var imgdict:[String:Any] = [:]
                        if let picUrl = i.data.cashoutOptionsDic.pictureURL {
                            imgdict["large"] = picUrl
                        }
                        
                        if let picUrl = i.data.cashoutOptionsDic.smallPictureURL {
                            imgdict["small"] = picUrl
                        }
                        
                        if let picUrl = i.data.cashoutOptionsDic.iconURL {
                            imgdict["icon"] = picUrl
                        }
                        
                        if !imgdict.isEmpty { optdict["image"] = imgdict }
                        
                        // pull in the form fields and add them
                        var fields = SupportFunctions.sharedInstance.getFormFields(i.data.cashoutOptionsDic.formId!, schema: schema)
                        // We want to check if the user is Dan, and if it is, lets add in a defaultValue for his email address:
                        if email.isNotNil || fullname.isNotNil {
                            // We need to add this in as a defaultValue to the email fields:
                            var newFields = [[String:Any]]()
                            for field in fields {
                                var theNewField = field as! [String:Any]
                                if theNewField["fieldType"].stringValue == "E-Mail", email.isNotNil {
                                    theNewField["defaultValue"] = email!
                                }
                                if theNewField["name"].stringValue == "Full Name", fullname.isNotNil {
                                    theNewField["defaultValue"] = fullname!
                                }

                                newFields.append(theNewField)
                            }
                            fields = newFields
                        }
                        optdict["fields"] = fields

                        retJSONSub.append(optdict)

                    }
                    
                    retJSON["options"] = retJSONSub
                    
                } else {
                    
                    var audit:[String:Any] = retJSON
                    audit["limit"] = qp.limitNumber
                    audit["offset"] = qp.offsetNumber

                    AuditRecordActions.pageView(schema: schema,
                                                session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                page: "/api/v1/cashout/{groupId}/options",
                                                row_data: audit,
                                                description: "Unsupported Country for this request.",
                                                viewedby: request.session?.userid)
                    
                    // This is an error with the country id existing, but the schema not being supported.
                    return response.unsupportedCountry
                    
                }

                var audit:[String:Any] = retJSON
                audit["limit"] = qp.limitNumber
                audit["offset"] = qp.offsetNumber

                AuditRecordActions.pageView(schema: schema,
                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                            page: "/api/v1/cashout/{groupId}/options",
                                            row_data: audit,
                                            description: "Unsupported Country for this request.",
                                            viewedby: request.session?.userid)

                let _ = try? response.setBody(json: retJSON)
                response.completed(status: .ok)

            }
        }
        
        //MARK: - Cashout Types:
        public static func cashoutTypes(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBounce(request, response) else { return }

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

                var currentUserBalance = 0.0
                if let countryId = Country.idWith(countryCode) {
                    currentUserBalance = UserBalanceFunctions().getCurrentBalance(request.session!.userid, countryid: countryId)
                }
                
                if res.isNotNil {
                    // creating the return JSON with results
                    var retJSONSub:[[String:Any]] = []
                    for i in res! {
                        // put it together..
                        var s:[String:Any] = [:]
                        if let id = i.data.id { s["id"] = id }
                        if let name = i.data.cashoutGroupDic.group_name { s["name"] = name }
                        if let desc = i.data.cashoutGroupDic.description { s["description"] = desc }
                        if let countryId = i.data.cashoutGroupDic.country_id { s["countryId"] = countryId }
                        if let threshAmount = i.data.cashoutGroupDic.thresholdAmount, threshAmount > 0 {
                            // This is NOT the display boolean.  This is a pre-compared bool to show if the user has enough to even view the options.
                            // The display boolean is used behind the scene to even return the group.
                            s["thresholdAmount"] = threshAmount
                            s["disabled"] = threshAmount > currentUserBalance
                        }
                        if let longDesc = i.data.cashoutGroupDic.longDescription { s["longDescription"] = longDesc }
                        if let optionCount = i.data["option_count"] {
                            s["optionCount"] = optionCount
                            if let optionLayout = i.data["option_layout"] { s["optionLayout"] = optionLayout }
                        }

                        // See if we have any images:
                        var imageDic : [String:Any] = [:]
                        if let background = i.data.cashoutGroupDic.picture_url, !background.isEmpty {
                            imageDic["background"] = background
                        }
                        if let icon = i.data.cashoutGroupDic.iconURL, !icon.isEmpty {
                            imageDic["icon"] = icon
                        }
                        if let icon = i.data.cashoutGroupDic.detailIconURL, !icon.isEmpty {
                            imageDic["detailIcon"] = icon
                        }
                        // Fill the image dictionary if we have any images:
                        if !imageDic.isEmpty {
                            s["image"] = imageDic
                        }
                        
                        // add this entry to the array of entries
                        retJSONSub.append(s)
                    }
                    
                    let retJSON:[String:Any] = ["groups":retJSONSub]
                    
                    var audit:[String:Any] = retJSON
                    audit["limit"] = qp.limitNumber
                    audit["offset"] = qp.offsetNumber
                    
                    AuditRecordActions.pageView(schema: schema,
                                                session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                page: "/api/v1/cashout/{groupId}/options",
                                                row_data: audit,
                                                description: nil,
                                                viewedby: request.session?.userid)

                    let _ = try? response.setBody(json: retJSON)
                    response.completed(status: .ok)
                } else {
                    
                    var audit:[String:Any] = [:]
                    audit["country_id"] = request.countryId
                    audit["limit"] = qp.limitNumber
                    audit["offset"] = qp.offsetNumber
                    
                    AuditRecordActions.pageView(schema: schema,
                                                session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                page: "/api/v1/cashout/{groupId}/options",
                                                row_data: audit,
                                                description: "Unsupported Country for this request.",
                                                viewedby: request.session?.userid)

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
                guard !Account.userBounce(request, response) else { return }
                
                do {
                    
                    let json = try request.postBodyJSON()!
                    if json.isEmpty { return response.emptyJSONBody }
                    
                    let userId = request.session?.userid
                    
                    let user = request.account
                    
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
                    let sqloption = "SELECT minimum, maximum, name, group_id, form_id FROM \(schema).cashout_option_view_deleted_no WHERE id = \(theoption)"
                    let coop = CashoutOption()
                    let resopt = try? coop.sqlRows(sqloption, params: [])
                    
                    var min_cashout  = 0.0
                    var max_cashout  = 0.0
                    var name_cashout = ""
                    var form_id = 0
                    
                    let cog = CashoutGroup()
                    
                    if resopt.isNotNil, let i = resopt?.first! {
                        min_cashout  = i.data["minimum"].doubleValue ?? 0.0
                        max_cashout  = i.data["maximum"].doubleValue ?? 0.0
                        name_cashout = i.data["name"].stringValue ?? ""
                        form_id = i.data["form_id"].intValue ?? 0
                        
                        let gid = i.data["group_id"].intValue
                        let gid_i = try? cog.sqlRows("SELECT * FROM \(schema).cashout_group WHERE id = \(gid!)", params: [])
                        if let g = gid_i?.first {
                            cog.to(g)
                        }
                    }
                    
                    // If no fields are submitted, send back an error.
                    var submittedFields = request.formFields
                    
                    // Now that we have the form id, we can get the form fields, and make sure they are entering these:
                    let formFields = SupportFunctions.sharedInstance.getFormFields(form_id, schema: schema) as?[[String:Any]] ?? []
                    var unsubmittedFields : [String] = []
                    for field in formFields {
                        // Go thru all the fields, if they are required, make sure they are in the submitted fields.
                        if let key = field["key"].stringValue, let name = field["name"].stringValue {
                            if field["isReq"].boolValue == true && submittedFields?[key].isNil == true {
                                unsubmittedFields.append(key+" (\(name))")
                            } else {
                                let c = submittedFields?.removeValue(forKey: key)
                                submittedFields?[name] = c
                            }
                        }
                    }
                    
                    // Send back the unsubmitted fields.
                    guard unsubmittedFields.isEmpty else { return response.missingFormFields(unsubmittedFields) }
                    
                    // get the cashout amount
                    let amount_to_cashout = request.cashoutAmount!
                    
                    // make sure they are cashing out the correct amount
                    if min_cashout > amount_to_cashout {
                        return response.invalidCashoutAmount
                    }
                    
                    // there are a couple of things we need to do.  First -- we need to loop thru the records - from oldest to newest (based on redeemed code dates)
//                    var sql = "SELECT id, amount, amount_available, customer_code, redeemedby "
                    var sql = "SELECT * "
                    sql.append("FROM \(schema).code_transaction_history_view_deleted_no ")
                    sql.append("WHERE redeemedby = '\(userId!)' ")
                    sql.append("AND amount_available > 0 ")
                    //                sql.append("AND country_id = \(country_id) ")
                    sql.append("ORDER BY redeemed ASC")
                    let cth = CodeTransactionHistory()
                    let cth_rec = try? cth.sqlRows(sql, params: [])
                    
                    // we will determine the records to use their entire amount and the records to use portions
                    
//                    var included:[Int] = []
//                    var lastone = 0
                    var lastoneamount:Double = 0.0
                    var totalcount:Double = 0.0
                    
                    var theitems:[CodeTransactionHistory] = []
                    var thelastone:CodeTransactionHistory? = nil
                    
                    var codes_used:[String:Any] = [:]
                    
                    // calculate wiich records we will use for the cashout amount.
                    if cth_rec.isNotNil {
                        for i in cth_rec! {
                            
                            let cth_r = CodeTransactionHistory()
                            cth_r.to(i)
                            
                            if let tam = cth_r.amount_available {
                                if (totalcount + tam) <= amount_to_cashout {
                                    // keet looping because we did not pick enough of the codes yet
                                    totalcount += tam
//                                    included.append(cth_r.id!)
                                    theitems.append(cth_r)
                                    
                                    codes_used["\(cth_r.customer_code!)"] = [cth_r.amount_available, cth_r.amount_available]
                                    
                                } else if (tam > amount_to_cashout) && (totalcount == 0) {
                                    // the rare case where one code is worth more than the cashout request
                                    totalcount = tam
                                    lastoneamount = amount_to_cashout
//                                    lastone = cth_r.id!
                                    thelastone = cth_r

                                    codes_used["\(cth_r.customer_code!)"] = [amount_to_cashout, cth_r.amount_available]

                                    break
                                } else if totalcount < amount_to_cashout {
                                    // the last one still has a small amount of value left
                                    lastoneamount = amount_to_cashout - totalcount
//                                    lastone = cth_r.id!
                                    totalcount = totalcount + lastoneamount
                                    thelastone = cth_r

                                    codes_used["\(cth_r.customer_code!)"] = [lastoneamount, cth_r.amount_available]

                                    break
                                }
                            }
                        }
                    }
                    
                    // now we have the list of records to include and the final partial record
                    if totalcount < amount_to_cashout {
                        
                        var audit:[String:Any]     = codes_used
                        audit["totalcount"]        = totalcount
                        audit["amount_to_cashout"] = amount_to_cashout

                        AuditRecordActions.addGenericrecord(schema: schema,
                                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                            audit_group: "CASHOUT",
                                                            audit_action: "ERROR",
                                                            row_data: audit,
                                                            changed_fields: nil,
                                                            description: "There is not enough to cash out.",
                                                            user: userId!)
                        return response.invalidCashoutBalance
                    }
                    
                    var audit_fields:[String:Any] = [:]
                    
                    // The user has enough to cashout, so lets go and write in their entered fields:
                    // only do this if the user is NOT a sample account
                    if submittedFields?.isEmpty == false, user.isNotNil, !user!.isSample() {
                        
                        let cfHeader = CompletedFormsHeader()
                        _=try? cfHeader.saveWithCustomType(schemaIn: schema, userId!)
                        
                        // Now write in the details:
                        for field in submittedFields! {
                            let detail = CompletedFormsDetail()
                            detail.cf_header_id = cfHeader.id
                            detail.field_name = field.key
                            detail.field_value = field.value
                            
                            audit_fields["\(field.key)"] = field.value
                            
                            _=try? detail.saveWithCustomType(schemaIn: schema, userId!)
                        }
                    }

                    // process the records we saved earlier
                    let cth_cashedout = CCXServiceClass.sharedInstance.getNow()
                    if theitems.count > 0 {
                        for working_cth in theitems {

                            // update the available amount
                            working_cth.amount_available = 0.0
                            working_cth.cashedout_total  = working_cth.amount
                            
                            working_cth.cashedout      = cth_cashedout
                            working_cth.cashedoutby    = userId!
                            working_cth.cashedout_note = "CASHOUT: \(name_cashout)"
                            
                            // we are complete - lets save and move on
                            let _ = try? working_cth.saveWithCustomType(schemaIn: schema)
                            
                            // Write the audit record
                            if schema == "us" {
                                // figure out what type
                                let co_type = cog.detail_disbursement_reasons ?? 0
                                
                                AuditFunctions().cashoutCustomerCodeAuditRecord(schema, working_cth, co_type)
                            }
                        }
                        
                        // if there is a last record, lets process that single recors
                        if thelastone.isNotNil, let lastonenow = thelastone {

                            let amount_left = lastonenow.amount_available! - lastoneamount
                            lastonenow.amount_available = amount_left
                            lastonenow.cashedout_total  = lastoneamount
                            
                            lastonenow.cashedout      = cth_cashedout
                            lastonenow.cashedoutby    = userId!
                            lastonenow.cashedout_note = "CASHOUT: \(name_cashout)"
                            
                            // we are complete - lets save and move on
                            let _ = try? lastonenow.saveWithCustomType(schemaIn: schema)
                            
                            // Write the audit record
                            if schema == "us" {
                                // figure out what type
                                let co_type = cog.detail_disbursement_reasons ?? 0
                                
                                AuditFunctions().cashoutCustomerCodeAuditRecord(schema, lastonenow, co_type)
                            }

                        }
                        
                        // add the cashout record to the history record
                        let newrec = CodeTransactionHistory()
                        newrec.id = 0
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
                        
                        let _ = try? newrec.saveWithCustomType(schemaIn: schema, userId!)
                        
                        // add the cashout record
                        
                        
                        // Decrement the users balance:
                        UserBalanceFunctions().adjustUserBalance(schemaId: nil, userId!, countryid: countryId, decrease: amount_to_cashout)
                        
                        // this is where we show success
                        // show the bucket amount response like in the login
                        let buckets = UserBalanceFunctions().getConsumerBalances(userId!)
                        
                        var audit:[String:Any] = [:]
                        audit["buckets"] = buckets
                        audit["audit_fields"] = audit_fields
                        audit["codes_used"] = codes_used
                        
                        AuditRecordActions.customerCodeAdd(schema: schema,
                                                           session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                           row_data: audit,
                                                           changed_fields: nil,
                                                           description: nil,
                                                           changedby: userId)
                        
                        let _ = try? response.setBody(json: ["buckets":buckets])
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
                    
                } catch BucketAPIError.unparceableJSON(let string) {
                    return response.invalidRequest(string)
                } catch {
                    
                }

            }
        }
        //MARK: - Refer Retailer Function:
        public static func referRetailer(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check the user:
                guard !Account.userBounce(request, response) else { return }
                
                // lets get the parms
                if let json = try? request.postBodyJSON() {
                    
                    let rr = RecommendRetailer()

                    if let n = json!["name"].stringValue {
                        rr.name = n
                    }
                    
                    if let n = json!["phoneNumber"].stringValue {
                        rr.phone = n
                    }
                    

                    if let n = json!["state"].stringValue {
                        rr.state = n
                    }
                    

                    if let n = json!["city"].stringValue {
                        rr.city = n
                    }
                    

                    if let n = json!["address"].stringValue {
                        rr.address = n
                    }
                    

                    if let n = json!["countryCode"].stringValue {
                        rr.country_code = n
                    }
                    

                    if let n = json!["postalCode"].stringValue {
                        rr.postal_code = n
                    }
                    

                    var schema = "public"
                    if let cc = rr.country_code {
                        schema = Country.getSchema(cc)
                    }
                    // check to see if the schema is valid
                    // make sure the schema exists - if not we do not service that country
                    let ct = Country()
                    let sqls = "SELECT schema_name FROM information_schema.schemata WHERE schema_name = '\(schema)'"
                    let sct = try? ct.sqlRows(sqls, params: [])
                    if sct?.first == nil {
                        schema = "public"
                    }

                    
                    // setup the other auditing fields and such
                    rr.user_id = request.session?.userid
                    
                    // now save it all
                    let _ = try? rr.saveWithCustomType(schemaIn: schema, rr.user_id)

                    // and send the email to the correct email address -- well, hopefully!
                    var h = "<p>A Recommended Retailer</p>"
                    h += "<p>"
                    h += "Retailer: \(rr.name ?? "No Name")<br />"
                    h += "Address: \(rr.address ?? "No Address")<br />"
                    h += "City: \(rr.city ?? "No City")<br />"
                    h += "State/Providence: \(rr.state ?? "No State")<br />"
                    h += "Postal Code: \(rr.postal_code ?? "No Postal Code")<br />"
                    h += "Country: \(rr.country_code ?? "No Postal Code")<br />"
                    h += "Phone: \(rr.phone ?? "No Phone")<br />"
                    h += "<hr />Record Database: \(schema).\(rr.table())<hr />"
                    h += "</p>"
                    
                    var t = "A Recommended Retailer\n\n"
                    t += "Retailer: \(rr.name ?? "No Name")\n"
                    t += "Address: \(rr.address ?? "No Address")\n"
                    t += "City: \(rr.city ?? "No City")\n"
                    t += "State/Providence: \(rr.state ?? "No State")\n"
                    t += "Postal Code: \(rr.postal_code ?? "No Postal Code")\n"
                    h += "Country: \(rr.country_code ?? "No Postal Code")\n"
                    t += "Phone: \(rr.phone ?? "No Phone")\n"
                    t += "\nRecord Database: \(schema).\(rr.table())\n"
                    
                    Utility.sendMail(name: EnvironmentVariables.sharedInstance.RECOMMEND_RETAILER_DISPLAY_NAME!,
                                     address: EnvironmentVariables.sharedInstance.RECOMMEND_RETAILER_EMAIL!,
                                     subject: EnvironmentVariables.sharedInstance.RECOMMEND_RETAILER_SUBJECT!,
                                     html: h,
                                     text: t)
                    
                    AuditRecordActions.addGenericrecord(schema: schema,
                                                        session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                        audit_group: "RECOMMEND",
                                                        audit_action: "ADD",
                                                        row_data: rr.asDictionary(),
                                                        changed_fields: nil,
                                                        description: "Recommended A New Retailer",
                                                        user: request.session?.userid ?? "NO USER")
                    
                    try? response.setBody(json: ["message":"Thank you for referring \(rr.name ?? "Oops - No Name").  Our team will review and validate your referral shortly."])
                        .completed(status: .ok)
                    return

                } else {
                    response.invalidJSONFormat
                    return
                }
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
    var invalidCashoutAmount : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCashoutAmount", "message": "The amount you are wanting to cashout, is not of the required minimum amount."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 422, message: "Invalid Cashout Amount"))
    }
    var invalidCashoutBalance : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCashoutBalance", "message": "You do not have enough balance to cashout."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 421, message: "Insufficient Balance"))
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

    func missingFormFields(_ fields : [String]) -> Void {
        return try! self.setBody(json: ["errorCode":"InvalidFormFields", "message": "Required keys for option: \(fields.joined(separator: ","))"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 410, message: "Missing Form Fields"))
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
    var formFields : [String:String]? {
        return try! self.postBodyJSON()?["formFields"] as? [String:String]
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
