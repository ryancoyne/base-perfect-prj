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

    func addCustomerCodeAuditRecord(_ record: CodeTransaction ) {
        
        var schema = ""
        var user = ""
        
        schema = Country.getSchema(record.country_id!)
            
        // picking the user from most important to least important
        if let u = record.createdby, !u.isEmpty {
            user = u
        }
        
        if schema == "us" {
            // lets add the audit record for the US
            let usa = USAuditFunctions()
            usa.customerCodeAuditRecord(record, USCodeStatusType.firstentry, USCodeStatusType.create)
        }
        
        // Add the overall auditing here
        
    }

    func redeemCustomerCodeAuditRecord(_ record: CodeTransaction ) {
        
        var schema = ""
        var user = ""
        
        schema = Country.getSchema(record.country_id!)
        
        // picking the user from most important to least important
        if let u = record.createdby, !u.isEmpty {
            user = u
        }
        
        if schema == "us" {
            // lets add the audit record for the US
            let usa = USAuditFunctions()
            usa.customerCodeAuditRecord(record, USCodeStatusType.create, USCodeStatusType.claimed)
            usa.customerAccountDetailAuditRecord(userId: user,
                                                 changed: record.created!,
                                                 toValue: USDetailNewValues.codeAdded,
                                                 codeNumber: record.customer_code,
                                                 amount: record.amount,
                                                 adjustmentReason: nil,
                                                 disbursementReason: nil)
        }
        
        // Add the overall auditing here
        
    }

    func cashoutCustomerCodeAuditRecord(_ record: CodeTransactionHistory ) {
        
        var schema = ""
        var user = ""
        
        schema = Country.getSchema(record.country_id!)
        
        // picking the user from most important to least important
        if let u = record.createdby, !u.isEmpty {
            user = u
        }
        
        if schema == "us" {
            // lets add the audit record for the US
            let usa = USAuditFunctions()
            usa.customerCodeAuditRecord(record, USCodeStatusType.claimed, USCodeStatusType.cashedout)
        }
        
        // Add the overall auditing here
        
    }

    
    func deleteCustomerCodeAuditRecord(_ record: Any ) {
        
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
