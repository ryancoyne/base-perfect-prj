import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication

public struct USRecordType {
    static let codeDetail     = "CD"
    static let accountDetail  = "BD"
    static let codeStatus     = "CS"
    static let accountStatus  = "BS"
}

public struct USCodeStatusType {
    static let firstentry  = 0
    static let create      = 1
    static let claimed     = 2
    static let deactivated = 3
    static let lost        = 4
    static let cashedout   = 5
}

public struct USAccountStatusType {
    static let firstentry  = 0
    static let active      = 1
    static let frozen      = 2
    static let lost_stolen = 3
    static let breakage    = 4
    static let inactive    = 5
    static let fraud       = 6
}

public class USAuditFunctions {
    
    func customerCodeAuditRecord(_ record: Any, _ fromFunction:Int, _ toFunction:Int, _ userId:String? = nil ) {
        
        var schema = ""
        var user = ""
        
        let ar = USAccountCodeStatus()
        ar.record_type = USRecordType.codeStatus
        
        let ad = USAccountCodeDetail()
        ad.record_type = USRecordType.codeDetail
        
        let timenow = CCXServiceClass.sharedInstance.getNow()
        
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
            
            // -- Status Record
            // start completing the record
            let sql = "SELECT id FROM \(schema).\(ar.table()) WHERE code_number = '\(ct.customer_code!)' "
            let slqr = try? ar.sqlRows(sql, params: [])
            if let sqlra = slqr?.first {
                ar.to(sqlra)
            }
            if ar.id.isNil {
                ar.created        = timenow
                ar.createdby      = user
            } else {
                ar.modified   = timenow
                ar.modifiedby = user
            }
            ar.created        = timenow
            ar.createdby      = user
            ar.record_type    = USRecordType.codeStatus
            ar.code_number    = ct.customer_code
            ar.value_original = fromFunction
            ar.value_new      = toFunction
            
            // dates
            let thedates = SupportFunctions.sharedInstance.getDateAndTime(timenow)
            ar.change_date = thedates.date
            ar.change_time = thedates.time

            // -- Detail Record
            // start completing the detail record
            ad.created        = timenow
            ad.createdby      = user
            ad.record_type    = USRecordType.codeDetail
            ad.code_number    = ct.customer_code
            ad.value_original = fromFunction
            ad.value_new      = toFunction
            ad.amount         = ct.amount
            
            // dates
            ad.change_date = thedates.date
            ad.change_time = thedates.time

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
            
            // -- Status Record
            // start completing the record
            let sql = "SELECT id FROM \(schema).\(ar.table()) WHERE code_number = '\(ct.customer_code!)' "
            let slqr = try? ar.sqlRows(sql, params: [])
            if let sqlra = slqr?.first {
                ar.to(sqlra)
            }
            if ar.id.isNil {
                ar.created        = timenow
                ar.createdby      = user
            } else {
                ar.modified   = timenow
                ar.modifiedby = user
            }
            ar.record_type    = USRecordType.codeStatus
            ar.code_number    = ct.customer_code
            ar.value_original = fromFunction
            ar.value_new      = toFunction
            
            // dates
            let thedates = SupportFunctions.sharedInstance.getDateAndTime(timenow)
            ar.change_date = thedates.date
            ar.change_time = thedates.time

            // -- Detail Record
            // start completing the detail record
            ad.created        = timenow
            ad.createdby      = user
            ad.record_type    = USRecordType.codeDetail
            ad.code_number    = ct.customer_code
            ad.value_original = fromFunction
            ad.value_new      = toFunction
            ad.amount         = ct.amount
            
            // dates
            ad.change_date = thedates.date
            ad.change_time = thedates.time

            break
            
        default:
            // do nothing  the correct classes were not passed in
            break
        }
        
        // save the audit record
        let _ = try? ar.saveWithCustomType(schemaIn: schema, user)
        let _ = try? ad.saveWithCustomType(schemaIn: schema, user)

    }
    
    
    func customerAccountAuditRecord(_ record: Account, _ fromFunction:Int, _ toFunction:Int, _ codeRecord: Any? = nil, _ userId:String? = nil  ) {
        
        let cas = USBucketAccountStatus()
        let cad = USBucketAccountDetail()

        
        var schema = "us"
        var user = ""
        
        if !userId.isNil {
            user = userId!
        }
        
        // lets setup the status record - it should be updated if it exists
        let sql = "SELECT id FROM \(schema).us_bucket_account_status WHERE account_number = '\(user)' "
        
        
        // lets setup the detail record - it always is written
        
        
        switch codeRecord {
        case is CodeTransaction:
            break
            
        case is CodeTransactionHistory:
            break
            
        default:
            // do nothing  the correct classes were not passed in
            break
        }

        // save the audit record
        let _ = try? cas.saveWithCustomType(schemaIn: schema, user)
        let _ = try? cad.saveWithCustomType(schemaIn: schema, user)


    }
    
}
