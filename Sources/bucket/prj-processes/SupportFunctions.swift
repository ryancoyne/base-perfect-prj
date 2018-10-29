//
//  SupportFunctions.swift
//  bucket
//
//  Created by Mike Silvers on 8/15/18.
//

import Foundation
import PostgresStORM
import PerfectHTTP
import SwiftMoment

final class SupportFunctions {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = SupportFunctions()

    func getDateAndTime(_ formatTime:Int? = nil)->(date:String, time:String) {
        
        var checkTime = 0
        
        if formatTime.isNil {
            checkTime = CCXServiceClass.getNow()
        } else {
            checkTime = formatTime!
        }
        
        let thedate = Date(timeIntervalSince1970: TimeInterval(checkTime))
        
        // date formatter: yyyyMMdd
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let retDate = dateFormatter.string(from: thedate)
        
        // time formatter: hhmmss
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hhmmss"
        timeFormatter.timeZone = TimeZone(identifier: "UTC")
        let retTime = timeFormatter.string(from: thedate)
        
        return (retDate,retTime)
    }
    
    func getCountryId(_ countryCode: String)->Int {
        
        let cc = Country()
        
        
        // lets see if there is an entry for this country code
        switch countryCode.length {
        case 2:
            try? cc.find(["code_alpha_2" : "\(countryCode.trimmed())"])
            break
            
        case 3:
            try? cc.find(["code_alpha_3" : "\(countryCode.trimmed())"])
            break
            
        default:
            break
        }
        
        // if we found it, then return it
        if cc.id.isNotNil {
            return cc.id!
        }
        
        return 0
    }
    
    func getFormFields(_ form_id:Int, schema : String)->[Any] {
        
        let form_fields = FormFields()
        var sql = "SELECT ffs.field_id, ffs.display_order, ff.*, fft.name AS form_field_type_name FROM \(schema).form_fields AS ffs "
        sql.append("LEFT JOIN \(schema).form_field AS ff ON ffs.field_id = ff.id ")
        
        sql.append("LEFT JOIN \(schema).form_field_type AS fft ON ff.type_id = fft.id ")
        
        sql.append("WHERE ffs.form_id = $1 ")
        sql.append("ORDER BY ffs.display_order ASC ")
        let res = try? form_fields.sqlRows(sql, params: ["\(form_id)"])
        
        print(sql)
        
        var returnDataArray:[Any] = []
        if res.isNotNil {
            for i in res! {
                var tmp:[String:Any] = [:]
                tmp["name"] = i.data["name"]
                tmp["key"] = i.data["id"]
                tmp["isReq"] = i.data["is_required"]
                tmp["confirmValue"] = i.data["needs_confirmation"]
                tmp["displayOrder"] = i.data["display_order"]
                tmp["fieldType"] = i.data["form_field_type_name"]
                returnDataArray.append(tmp)
            }
        }
        
        return returnDataArray
    }
    
    func getNextBatch(schemaId:String? = "public",_ prefix:String? = nil, _ userId:String? = nil)->(headerId:Int, batchIdentifier: String) {
        
        var schema = "public"
        if schemaId.isNotNil { schema = schemaId!.lowercased() }
        
        var current_userId = CCXDefaultUserValues.user_server
        if userId.isNotNil { current_userId = userId! }
        
        var batch_id = 1
        var start_date = 0
        
        let bh = BatchHeader()
        let sql = "SELECT * FROM \(schema).batch_header ORDER BY id DESC "
        let idh = try? bh.sqlRows(sql, params: [])
        if let i = idh?.first {
            batch_id = i.data["id"].intValue!
            batch_id = batch_id + 1
            if let sd = i.data["record_end_date"].intValue, sd > 0 {
                start_date = sd + 1
            }
        }

        let nowdate = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let now = df.string(from: nowdate)

        var batch = ""
        if prefix.isNotNil {
            batch = "\(prefix!)-\(now)"
        } else {
            batch = "\(now)"
        }
        
        // we are going to make sure the identifier has not been used up until this point
        var tryme = "\(batch)-\(batch_id)"
        var sql2 = ""
        var keepgoing = true
        
        var retInt = 0
        var retString = ""
        
        while keepgoing {
            sql2 = "SELECT * FROM \(schema).batch_header WHERE batch_identifier = '\(tryme)'"
            let bhchk = try? bh.sqlRows(sql2, params: [])
            if let _ = bhchk?.first {
                // found - update the batch ID and retry
                batch_id = batch_id + 1
                tryme = "\(batch)-\(batch_id)"
            } else {
                // it does not exist!
                
                bh.batch_identifier = tryme
                bh.status = CCXServiceClass.getNow()
                bh.statusby = current_userId
                bh.current_status = BatchHeaderStatus.working_on_it
                
                // if there is an end date, set the start datee one second after the end date
                if start_date > 0 {
                    bh.record_start_date = start_date
                }
                
                let bhs = try? bh.saveWithCustomType(schemaIn: schema)
                if let b = bhs?.first {
                    bh.to(b)
                    retInt = bh.id!
                    retString = tryme
                }
                keepgoing = false
            }
        }
        
        return (retInt, retString)
    }
    
    static func yesterday(_ epoch:Int,_ days:Int? = 1) -> (start:Int, end:Int) {
        
        let timeZone = TimeZone(secondsFromGMT: 0)!
        let locale = Locale(identifier: "en_US_POSIX")
        
        let now = moment(Date(timeIntervalSince1970: TimeInterval(epoch)), timeZone: timeZone, locale: locale)
        
        let hour = now.hour
        let min = now.minute
        let sec = now.second
        
        let daysec_calc = (hour*60*60) + (min*60) + sec
        
        let day_end = (epoch - daysec_calc) - 1
        
        // add the one to make it midnight.  If we do not add the 1 the start is 11:59:59 the day before (24 hours earlier)
        var day_start = ((day_end - now.dayInSeconds) + 1)
        if days.isNotNil, days! > 1 {
            day_start = day_start - (days! * 86400)
        }

        return (day_start,day_end)
        
    }
    
}
