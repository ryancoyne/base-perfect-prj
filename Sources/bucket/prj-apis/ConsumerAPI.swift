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
                // BALANCE ENDPOINT:
                ["method":"get",    "uri":"/api/v1/balance", "handler":balance],
                ["method":"get",    "uri":"/api/v1/balance/{countryId}", "handler":balance],
                // TRANSACTION ENDPOINTS:
                ["method":"get",    "uri":"/api/v1/history/{countryId}", "handler":transactionHistory],
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
                
                if let countryId = request.countryId {
                    guard countryId != 0 else { response.invalidCountryCode; return }
                    let amount = UserBalanceFunctions().getCurrentBalance(request.session!.userid, countryid: countryId)
                    if amount > 0 {
                        try? response.setBody(json: ["amount": amount])
                                .completed(status: .ok)
                    } else { return response.zeroBalance(countryId) }
                } else {
                    let buckets = UserBalanceFunctions().getConsumerBalances(request.session!.userid)
                    try? response.setBody(json: ["buckets":buckets])
                        .completed(status: .ok)
                }
                // Okay, we have a user id.  Lets get their balance and return the JSON:
                
                
                
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
                
                // Okay we are finding the transaction history - it is all in the code_transaction_history table
                var sql = "SELECT cth.*, r.name FROM code_transaction_history AS cth "

                // we do not need the retailer for cashouts - there will be no retailer for that type.
                if transType != "CASHOUT" {
                    sql.append("LEFT JOIN retailer AS r ")
                    sql.append("ON cth.retailer_id = r.id ")
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
                }

                let mainReturn:[String:Any] = ["transactions":substuff]
                
                try? response.setBody(json: mainReturn)
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
                
                // Awesome.  We have the customer code, and a user.  Now, we need to find the transaction and mark it as redeemed, and add the value to the ledger table!
                let ct = CodeTransaction()
                let rsp = try? ct.sqlRows("SELECT * FROM code_transaction_view_deleted_no WHERE customer_code = $1", params: ["\(request.customerCode!)"])
                
                if rsp?.first.isNil == true {
                    // if we did not find it, check histry to see if we have already redeemed it
                    let rsp2 = try? ct.sqlRows("SELECT * FROM code_transaction_history_view_deleted_no WHERE customer_code = $1", params: ["\(request.customerCode!)"])
                    if let t = rsp2?.first?.data, t.codeTransactionHistoryDic.redeemed! > 0 {
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

                var sqlstatement = "SELECT * FROM cashout_option_view_deleted_no AS coo "
                sqlstatement.append("WHERE group_id = $1 ")
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
                    
                }
                
                try? response.setBody(json: retJSON)
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

                var countsql = "SELECT cog.*, COUNT(coo.id) AS option_count "
                countsql.append("FROM cashout_group AS cog ")
                countsql.append("JOIN cashout_option AS coo ")
                countsql.append("ON cog.id = coo.group_id ")
                countsql.append("WHERE cog.country_id = $1 ")
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
                
//                print(countsql)
                
                // now lets get the types for this country
                let cg = CashoutGroup()
                
                // you may pass n either the number or the country code
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
                        if let _ = i.data.cashoutGroupDic.group_name { s["name"] = i.data.cashoutGroupDic.group_name! }
                        if let _ = i.data.cashoutGroupDic.description { s["description"] = i.data.cashoutGroupDic.description! }
                        if let _ = i.data.cashoutGroupDic.country_id { s["country_id"] = i.data.cashoutGroupDic.country_id! }
                        if let _ = i.data["option_count"] { s["option_count"] = i.data["option_count"]! }

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
                    
                    try? response.setBody(json: retJSON)
                    response.completed(status: .ok)
                } else {
                    // error that none were found
                    return response.invalidCountryCode
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
                
                var amount_to_cashout:Double = 50.0
                
                // there are a couple of things we need to do.  First -- we need to loop thru the records - from oldest to newest (based on redeemed code dates)
                var sql = "SELECT id, amount, amount_available, customer_code, redeemedby "
                sql.append("FROM code_transaction_history_view_deleted_no ")
                sql.append("WHERE redeemedby = \(userId!) ")
                sql.append("AND amount_available > 0 ")
                sql.append("ORDER BY redeemed DESC")
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
    var invalidCountryCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such country code found"])
            .setHeader(.contentType, value: "application/json")
            .completed(status: .notAcceptable)
    }
    func zeroBalance(_ countryId : Int) {
        return try! self.setBody(json: ["errorCode":"ZeroBalance", "message": "You have a zero balance for countryId \(countryId)"])
            .setHeader(.contentType, value: "application/json")
            .completed(status: .notAcceptable)
    }
    var invalidOptionCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such option code found"])
            .setHeader(.contentType, value: "application/json")
            .completed(status: .notAcceptable)
    }
    var invalidGroupCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such group code found"])
            .setHeader(.contentType, value: "application/json")
            .completed(status: .notAcceptable)
    }
    var invalidCustomerCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCode", "message": "No such code found"])
            .setHeader(.contentType, value: "application/json")
            .completed(status: .custom(code: 406, message: "The customer code was not found"))
    }
    var invalidCustomerCodeAlreadyRedeemed : Void {
        return try! self.setBody(json: ["errorCode":"CodeRedeemed", "message": "Code was already redeemed"])
            .setHeader(.contentType, value: "application/json")
            .completed(status: .custom(code: 410, message: "The customer code has been used already"))
    }

}

fileprivate extension HTTPRequest {
//    @available(*, deprecated, message: "no longer available in version v1.1")
    var customerCode : String? {
        return self.urlVariables["customerCode"]
    }
    var countryCode : String? {
        return self.urlVariables["countryCode"]
    }
    var countryId : Int? {
        return self.urlVariables["countryId"].intValue
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
