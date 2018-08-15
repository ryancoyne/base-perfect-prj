//
//  SupportFunctions.swift
//  bucket
//
//  Created by Mike Silvers on 8/15/18.
//

import Foundation
import PostgresStORM

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
    
}
