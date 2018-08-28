//
//  SupportFunctions.swift
//  bucket
//
//  Created by Mike Silvers on 8/15/18.
//

import Foundation
import PostgresStORM
import PerfectHTTP

final class SupportFunctions {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = SupportFunctions()

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
    
}
