//
//  StagesConnector.swift
//  offroaddcPackageDescription
//
//  Created by Mike Silvers on 2/21/18.
//

import StORM
import Foundation
//import PerfectCURL
//import PostgresStORM
//import JSONConfigEnhanced
//import PerfectLocalAuthentication

class ExternalServicesConnecter {
    
    // Singleton configuration
    static let sharedInstance = ExternalServicesConnecter()
    
    private init() {
        
    }

    @discardableResult
    func server1SyncUsers(_ location:String? = nil)->[String:Any] {
        
        var returnDict:[String:Any] = [:]
        
        // server 1 is Stages.... update the users
        let serverRet1 = StagesConnecter.sharedInstance.retrieveUsers()
        
        for (key,value) in serverRet1 {
            returnDict[key] = value
        }
        
        let serverRet2 = StagesConnecter.sharedInstance.associateUsers()

        var tmpk:[String:Any] = [:]
        
        for (key,value) in serverRet2 {
            tmpk[key] = value
            if !returnDict[key].stringValue.isEmptyOrNil {
                
            } else {
                
            }
            returnDict[key] = value
        }

        return returnDict
    }

    @discardableResult
    func server2SyncUsers(_ location:String? = nil)->[String:Any] {
        
        var returnDict:[String:Any] = [:]
        
        // this is where we add server 2 (Mindbody):
        
        return returnDict
    }


}

