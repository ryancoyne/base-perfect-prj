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
                ["method":"get",    "uri":"/api/v1/redeem/{customerCode}", "handler":redeemCode],
                ["method":"get",    "uri":"/api/v1/cashout/types/{countryCode}", "handler":cashoutTypes],
                ["method":"get",    "uri":"/api/v1/cashout/options/{groupId}", "handler":cashoutOptions],
                ["method":"post",    "uri":"/api/v1/cashout/{optionId}", "handler":cashout]
            ]
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
                
                
            }
        }
        //MARK: - Cashout Options:
        public static func cashoutOptions(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBouce(request, response) else { return }

                guard let groupId = request.groupId.intValue, groupId == 0 else { return response.invalidGroupCode }

                var sqlstatement = "SELECT * FROM cashout_option_view_deleted_no WHERE group_id = $1 ORDER BY display_order ASC"
                
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
//                guard !Account.userBouce(request, response) else { return }

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
//                let res = try? cg.sqlRows("SELECT * FROM cashout_group WHERE country_id = $1 ORDER BY display_order ASC ", params: ["\(SupportFunctions.sharedInstance.getCountryId(countryCode))"])
                let res = try? cg.sqlRows(countsql, params: ["\(SupportFunctions.sharedInstance.getCountryId(countryCode))"])

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
        
        //MARK: - Cashout Type:
        public static func cashoutType(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBouce(request, response) else { return }

                // Okay we are finding the specific type, and grabbing the fields we need:
                
                
            }
        }
        
        //MARK: - Cashout:
        public static func cashout(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Check if the user is logged in:
                guard !Account.userBouce(request, response) else { return }

                // Okay we are finding the specific type, and grabbing the fields we need:
                
                
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

}

fileprivate extension HTTPRequest {
//    @available(*, deprecated, message: "no longer available in version v1.1")
    var customerCode : String? {
        return self.urlVariables["customerCode"]
    }
    var countryCode : String? {
        return self.urlVariables["countryCode"]
    }
    var countryId : String? {
        return self.urlVariables["countryId"]
    }
    var groupId : String? {
        return self.urlVariables["groupId"]
    }
    var optionId : String? {
        return self.urlVariables["optionId"]
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
