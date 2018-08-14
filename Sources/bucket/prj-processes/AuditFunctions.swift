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

public class AuditFunctions {

    func addCustomerCodeAuditRecord(_ record: Any) {
        
        // get the audit record type
        let art = LedgerType()
//        art.find(["":])
        
        switch record {
        case is CodeTransaction:
            
            let ct = record as! CodeTransaction
            
            let ar = Ledger()
            ar.code_country_id = ct.country_id
            ar.customer_code = ct.customer_code
            
            break
            
        case is CodeTransactionHistory:

            let ct = record as! CodeTransactionHistory
            
            let ar = Ledger()

            break

        default:
            // do nothing  the correct classes were not passed in
            break
        }
        
    }

    func redeemCustomerCodeAuditRecord(_ record: Any) {
        
        switch record {
        case is CodeTransaction:
            
            
            break
        case is CodeTransactionHistory:
            // Code here
            break
        default:
            // do nothing  the correct classes were not assed in
            break
        }
        
    }

    func deleteCustomerCodeAuditRecord(_ record: Any) {
        
        switch record {
        case is CodeTransaction:
            
            
            break
        case is CodeTransactionHistory:
            // Code here
            break
        default:
            // do nothing  the correct classes were not assed in
            break
        }
        
    }

}
