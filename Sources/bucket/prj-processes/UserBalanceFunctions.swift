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
    
    func adjustUserBalance(_ userid:String, countryid:Int, increase:Double = 0.0, decrease:Double = 0.0) {
        
        let ut = UserTotal()
        
        var balance:Double = 0.0
        
        try? ut.find([("user_id", userid),("country_id", countryid)])
        
        // if the record has been found - return it
        if ut.id.isNotNil, ut.id! > 0 {
            balance = ut.balance!
        }
        
        // update the amount
        balance -= decrease
        balance += increase
        
        ut.balance = balance
        
        let _ = try? ut.saveWithCustomType()

    }
}
