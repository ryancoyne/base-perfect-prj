//
//  AuditFunctions.swift
//
//
//  Created by Mike Silvers on 8/14/18.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication

public class AuditFunctions {

    func customerCodeAuditRecord(_ record: Any ) {
        
        var schema = ""
        var user = ""
        
        
        switch record {
        case is CodeTransaction:
            
            let ct = record as! CodeTransaction
            
            schema = Country.getSchema(ct.country_id!)
            
            // picking the user from most important to least important
            if let u = ct.redeemedby, !u.isEmpty {
                user = u
            } else if let u = ct.createdby, !u.isEmpty {
                user = u
            }
            
            
            break
            
        case is CodeTransactionHistory:
            
            let ct = record as! CodeTransactionHistory
            
            schema = Country.getSchema(ct.country_id!)
            
            // picking the user from most important to least important
            if let u = ct.redeemedby, !u.isEmpty {
                user = u
            } else if let u = ct.createdby, !u.isEmpty {
                user = u
            }
            
            
            break
            
        default:
            // do nothing  the correct classes were not passed in
            break
        }
        
    }
    
    
    func customerAccountAuditRecord(_ record: Account ) {
        
        var schema = ""
        var user = ""
        
        switch record {
        case is CodeTransaction:
            
            let ct = record as! CodeTransaction
            
            schema = Country.getSchema(ct.country_id!)
            
            // picking the user from most important to least important
            if let u = ct.redeemedby, !u.isEmpty {
                user = u
            } else if let u = ct.createdby, !u.isEmpty {
                user = u
            }
            
            break
            
        case is CodeTransactionHistory:
            
            let ct = record as! CodeTransactionHistory
            
            schema = Country.getSchema(ct.country_id!)
            
            // picking the user from most important to least important
            if let u = ct.redeemedby, !u.isEmpty {
                user = u
            } else if let u = ct.createdby, !u.isEmpty {
                user = u
            }
            
            break
            
        default:
            // do nothing  the correct classes were not passed in
            break
        }
        
    }
}
