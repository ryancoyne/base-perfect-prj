//
//  CCXStatisticsAPI.swift
//  findapride
//
//  Created by Mike Silvers on 10/13/17.
//
//

import Foundation
import PerfectHTTP
import PerfectLocalAuthentication

struct CCXStatisticsAPI {
    
    //MARK: -
    //MARK: Main function to get statistics
    static func getAdminStatistics(_ dic : [String:Any]) throws -> [String:Any] {
        
        var returndict:[String:Any] = [:]
        
        //MARK: Today accounts
        // get the created statistics - since midnight
        var start = CCXServiceClass.sharedInstance.getMidnight()
        var end = CCXServiceClass.sharedInstance.getNow()
        var sqlstatement = "SELECT COUNT(id) FROM account WHERE (detail #>> '{created}')::int BETWEEN $1 and $2"
        var rows = try Account().sqlRows(sqlstatement, params: [String(describing: start), String(describing: end)])
        print("\(rows[0].data["count"] as! Int)")
        
        var newaccounts:[String:Any] = [:]
        var today:[String:Any] = [:]

        today["total"] = rows[0].data["count"] as! Int

        // stats for todays accounts
        var sqlstatement2 = sqlstatement + " AND (source = 'local') "
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        today["local"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND (source = 'google') "
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        today["google"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND source = 'facebook'"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        today["facebook"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND (detail #>> '{email_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        today["email_verified"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement +  " AND (detail #>> '{phone_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        today["phone_verified"] = rows[0].data["count"] as! Int
        
        var yesterday:[String:Any] = [:]

        //MARK: Yesterday accounts
        // get the created statistics - yesterday
        var daterange = CCXServiceClass.sharedInstance.getYesterday()
        start = daterange["start"]!
        end = daterange["end"]!
        rows = try Account().sqlRows(sqlstatement, params: [String(describing: start), String(describing: end)])
        yesterday["total"] = rows[0].data["count"] as! Int

        // stats for yesterdays accounts
        sqlstatement2 = sqlstatement + " AND (source = 'local') "
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        yesterday["local"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND (source = 'google') "
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        yesterday["google"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND source = 'facebook'"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        yesterday["facebook"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND (detail #>> '{email_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        yesterday["email_verified"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement +  " AND (detail #>> '{phone_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        yesterday["phone_verified"] = rows[0].data["count"] as! Int
        
        var twodaysago:[String:Any] = [:]

        //MARK: Two days ago accounts
        // get the created statistics - two days ago
        daterange = CCXServiceClass.sharedInstance.getTwoDaysAgo()
        start = daterange["start"]!
        end = daterange["end"]!
        rows = try Account().sqlRows(sqlstatement, params: [String(describing: start), String(describing: end)])
        twodaysago["total"] = rows[0].data["count"] as! Int

        // stats for two days ago accounts
        sqlstatement2 = sqlstatement + " AND (source = 'local') "
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        twodaysago["local"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND (source = 'google') "
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        twodaysago["google"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND source = 'facebook'"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        twodaysago["facebook"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND (detail #>> '{email_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        twodaysago["email_verified"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement +  " AND (detail #>> '{phone_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        twodaysago["phone_verified"] = rows[0].data["count"] as! Int
        
        var lastweek:[String:Any] = [:]

        //MARK: last week accounts
        // get the created statistics - last week
        daterange = CCXServiceClass.sharedInstance.getLastWeek()
        start = daterange["start"]!
        end = daterange["end"]!
        rows = try Account().sqlRows(sqlstatement, params: [String(describing: start), String(describing: end)])
        lastweek["total"] = rows[0].data["count"] as! Int

        // stats for two days ago accounts
        sqlstatement2 = sqlstatement + " AND (source = 'local') "
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        lastweek["local"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND (source = 'google') "
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        lastweek["google"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND source = 'facebook'"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        lastweek["facebook"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement + " AND (detail #>> '{email_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        lastweek["email_verified"] = rows[0].data["count"] as! Int
        
        sqlstatement2 = sqlstatement +  " AND (detail #>> '{phone_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement2, params: [String(start), String(end)])
        lastweek["phone_verified"] = rows[0].data["count"] as! Int

        // prepare to add the new accounts
        newaccounts["today"] = today
        newaccounts["yesterday"] = yesterday
        newaccounts["two_days_ago"] = twodaysago
        newaccounts["last_week"] = lastweek
        
        var accounts:[String:Any] = [:]
        accounts["new"] = newaccounts
        
        var allaccounts:[String:Any] = [:]

        //MARK: Total accounts
        // all users
        sqlstatement = "SELECT COUNT(id) FROM account"
        rows = try Account().sqlRows(sqlstatement, params: [])
        allaccounts["total"] = rows[0].data["count"] as! Int

        sqlstatement = "SELECT COUNT(id) FROM account WHERE source = 'local'"
        rows = try Account().sqlRows(sqlstatement, params: [])
        allaccounts["local"] = rows[0].data["count"] as! Int

        sqlstatement = "SELECT COUNT(id) FROM account WHERE source = 'google'"
        rows = try Account().sqlRows(sqlstatement, params: [])
        allaccounts["google"] = rows[0].data["count"] as! Int

        sqlstatement = "SELECT COUNT(id) FROM account WHERE source = 'facebook'"
        rows = try Account().sqlRows(sqlstatement, params: [])
        allaccounts["facebook"] = rows[0].data["count"] as! Int
        
        sqlstatement = "SELECT COUNT(id) FROM account WHERE (detail #>> '{email_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement, params: [])
        allaccounts["email_verified"] = rows[0].data["count"] as! Int

        sqlstatement = "SELECT COUNT(id) FROM account WHERE (detail #>> '{phone_verified}')::bool = true"
        rows = try Account().sqlRows(sqlstatement, params: [])
        allaccounts["phone_verified"] = rows[0].data["count"] as! Int

        accounts["all"] = allaccounts
        returndict["accounts"] = accounts
        
        // see if we need to return breadcrumbs
        if let bc = dic["breadcrumbs"] as? Bool,  bc == true {
            var breadcrumbusers:[String:Any] = [:]
            // lets get the breadcrumb stats.....
            sqlstatement = "SELECT COUNT(*) FROM (SELECT DISTINCT user_id FROM breadcrumbs) AS temp"
            rows = try Breadcrumb().sqlRows(sqlstatement, params: [])
            if let thecount = rows[0].data["count"] as? Int {
                breadcrumbusers["total"] = thecount
            } else {
                breadcrumbusers["total"] = 0
            }

            var bcusers:[String:Any] = [:]
            sqlstatement = "SELECT user_id, COUNT(*) FROM breadcrumbs  GROUP BY user_id"
            rows = try Breadcrumb().sqlRows(sqlstatement, params: [])
            if rows.count > 0 {
                // process each row
                for bc in rows {
                    let data = bc.data
                    var user_id = ""
                    // if this is not set and it crashes - well - that is OK
                    if let uid = data["user_id"].stringValue {
                        user_id = uid
                    } else {
                        user_id = "No UserID"
                    }
                    bcusers[user_id] = (data["count"] as! Int)
                }
            }

            if bcusers.count > 0 {
                breadcrumbusers["users"] = bcusers
            }
        
            // add the breadcrumb section
            if breadcrumbusers.count > 0 {
                returndict["breadcrumbs"] = breadcrumbusers
            }
        }
        
        // set it up with the return data set.
        let returnD = ["result":returndict]
        
        return returnD

    }
}
