//
//  UserBalanceFunctions.swift
//  bucket
//
//  Created by Mike Silvers on 8/15/18.
//

import Foundation
import PostgresStORM
import PerfectHTTP
import PerfectLib

public class UserBalanceFunctions {

    func getConsumerBalances(_ userid:String)->[Any] {
        
        var retArray:[Any] = []
        
        var thesql = "SELECT ut.*, cc.id AS country_id, cc.code_alpha_2 AS countryCode "
        thesql.append("FROM user_total AS ut ")
        thesql.append("LEFT OUTER JOIN country AS cc ")
        thesql.append("ON ut.country_id = cc.id ")
        thesql.append("WHERE ut.user_id = $1")
        
        let w = UserTotal()
        let resset = try? w.sqlRows(thesql, params: [userid])
        
        if resset.isNotNil {
            for i in resset! {
                var wallet:[String:Any] = [:]
                
                wallet["id"]     = i.data["id"]
                wallet["amount"] = i.data["balance"].doubleValue
                wallet["countryId"] = i.data["country_id"]
                wallet["countryCode"] = i.data["countryCode"]
                retArray.append(wallet)
            }
        }
        
        
        return retArray
    }
    
    func getCurrentBalance(_ userid:String, countryid:Int) -> Double {
        
        var total:Double = 0.0
        
        let ut = UserTotal()
        
        try? ut.find([("user_id", userid),("country_id", countryid)])
        
        // if the record has been found - return it
        if ut.id.isNotNil, ut.id! > 0 {
            total = ut.balance!
        }
        
        return total
    }
    
    func adjustUserBalance(schemaId:String? = "public", _ userid:String, countryid:Int, increase:Double = 0.0, decrease:Double = 0.0) {
        
        var schema = "public"
        if schemaId.isNotNil {
            schema = schemaId!.lowercased()
        }
        
        let ut = UserTotal()
        
        var balance:Double = 0.0
        
        let sql = "SELECT * FROM \(schema).\(ut.table()) WHERE user_id = '\(userid)' AND country_id = \(countryid)"
        let theid = try? ut.sqlRows(sql, params: [])
        if theid.isNotNil, theid!.count > 0 {
            ut.to(theid!.first!)
        }
        
        // if the record has been found - return it
        if ut.id.isNotNil, ut.id! > 0 {
            balance = ut.balance!
        }
        
        // update the amount
        balance -= decrease
        balance += increase
        
        ut.balance    = balance
        ut.user_id    = userid
        ut.country_id = countryid
        
        let _ = try? ut.saveWithCustomType(schemaIn: nil)

    }
}
