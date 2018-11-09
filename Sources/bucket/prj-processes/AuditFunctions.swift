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
        
        // Do NOT audit a sample
        if record.isSample() { return }
        
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

    func redeemCustomerCodeAuditRecord(_ record: CodeTransaction) {
        
        // Do NOT audit a sample
        if record.isSample() { return }

        var schema = ""
        var user = ""
        
        schema = Country.getSchema(record.country_id!)
        
        // picking the user from most important to least important
        if let u = record.redeemedby, !u.isEmpty {
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

    func cashoutCustomerCodeAuditRecord(_ schemaId: String, _ record: CodeTransactionHistory, _ US_detail_disbursement_reasons:Int ) {
        
        // Do NOT audit a sample
        if record.isSample() { return }

        let schema = schemaId.lowercased()
        var user = ""
        
        // picking the user from most important to least important
        if let u = record.redeemedby, !u.isEmpty {
            user = u
        }
        
        if schema == "us" {
            // lets add the audit record for the US
            let usa = USAuditFunctions()
            usa.customerCodeAuditRecord(record, USCodeStatusType.claimed, USCodeStatusType.cashedout)
            usa.customerAccountDetailAuditRecord(userId: user,
                                                 changed: record.cashedout!,
                                                 toValue: USDetailNewValues.fundsDispersed,
                                                 codeNumber: record.customer_code!,
                                                 amount: record.total_amount,
                                                 adjustmentReason: USDetailAdjustmentReasons.generalSubtract,
                                                 disbursementReason: US_detail_disbursement_reasons)
        }
        
        // Add the overall auditing here
        
    }

    
    func deleteCustomerCodeAuditRecord(_ record: Any ) {
        
        var schema = ""
        var user = ""
        
        switch record {
        case is CodeTransaction:
            
            let ct = record as! CodeTransaction
            
            // Do NOT audit a sample
            if ct.isSample() { return }

            schema = Country.getSchema(ct.country_id!)
            
            // picking the user from most important to least important
            if let u = ct.redeemedby, !u.isEmpty {
                user = u
            } else if let u = ct.createdby, !u.isEmpty {
                user = u
            }
            
            // add the deleted record to the file
            if schema == "us" {
                // lets add the audit record for the US
                let usa = USAuditFunctions()
                usa.customerCodeAuditRecord(ct, 1, 3, user)
            }
            
            break
            
        case is CodeTransactionHistory:
            
            let ct = record as! CodeTransactionHistory
            
            // Do NOT audit a sample
            if ct.isSample() { return }

            schema = Country.getSchema(ct.country_id!)
            
            // picking the user from most important to least important
            if let u = ct.redeemedby, !u.isEmpty {
                user = u
            } else if let u = ct.createdby, !u.isEmpty {
                user = u
            }
            
            // add the deleted record to the file
            if schema == "us" {
                // lets add the audit record for the US
                let usa = USAuditFunctions()
                usa.customerCodeAuditRecord(ct, 1, 3, user)
                usa.customerAccountDetailAuditRecord(userId: user,
                                                     changed: CCXServiceClass.getNow(),
                                                     toValue: 4,
                                                     codeNumber: ct.customer_code!,
                                                     amount: ct.total_amount!,
                                                     adjustmentReason: 2,
                                                     disbursementReason: 0)
            }
            
            break
            
        default:
            // do nothing  the correct classes were not passed in
            break
        }
        
    }
}
