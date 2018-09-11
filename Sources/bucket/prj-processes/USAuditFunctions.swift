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

public struct USDetailNewValues {
    static let codeAdded         = 1
    static let accountAdjustment = 2
    static let fundsDispersed    = 3
    static let codeReversed      = 4
    static let sentForBreakage   = 5
    static let fundsRemoved      = 6
}

public struct USDetailAdjustmentReasons {
    static let generalAdd              = 1
    static let generalSubtract         = 2
    static let fraudAdd                = 3
    static let fraudSubtract           = 4
    static let customrServiceAdd       = 5
    static let customerServiceSubtract = 6
}

public struct USDetailDisbursementReasons {
    static let openLoopCard   = 1
    static let closedLoopCard = 2
    static let donation       = 3
    static let crypto         = 4
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
    

    // this takes care of when accounts have actions against them (US accounts only)
    func customerAccountStatusAuditRecord(record: Account, changed:Int, fromStatus:Int, toStatus:Int, codeRecord: Any? = nil ) {

        let schema = "us"
        let user   = record.id

        // make sure the acount is not provisional (not yet confirmed)
        if record.usertype == .provisional { return }
        
        // lets first make sure there is a US based transaction before doing this
        var sql = "SELECT id FROM \(schema).code_transaction_history WHERE redeemedby = \(user) LIMIT 1"
        let sql_a = try? record.sqlRows(sql, params: [])
        // if there are no US transactions, then do not continue
        guard (sql_a?.first) != nil else { return }
        
        let changed_date_time = SupportFunctions.sharedInstance.getDateAndTime(changed)
        let timenow           = CCXServiceClass.sharedInstance.getNow()

        var cas = USBucketAccountStatus()
        
        cas  = USBucketAccountStatus()
        // lets setup the status record - it should be updated if it exists
        sql = "SELECT id FROM \(schema).us_bucket_account_status_view_deleted_no WHERE account_number = '\(user)' "
        let sqlr = try? cas.sqlRows(sql, params: [])
        if let a = sqlr?.first {
            cas.to(a)
            cas.modified   = timenow
            cas.modifiedby = user
        } else {
            cas.created   = timenow
            cas.createdby = user
        }
            
        cas.account_number = user
        cas.change_date    = changed_date_time.date
        cas.change_time    = changed_date_time.time
        cas.record_type    = USRecordType.accountStatus
        cas.value_original = fromStatus
        cas.value_new      = toStatus
        
        // save the audit record
        let _ = try? cas.saveWithCustomType(schemaIn: schema, user)

    }
    
    func customerAccountDetailAuditRecord(userId: String, changed:Int, toValue:Int, codeNumber:String? = nil, amount:Double? = nil, adjustmentReason:Int? = nil, disbursementReason:Int? = nil) {

        let record = Account()
        let _ = try? record.get(id: userId)
        
        let schema = "us"
        let user   = record.id
        
        // make sure the acount is not provisional (not yet confirmed)
        if record.usertype == .provisional { return }
        
        // lets first make sure there is a US based transaction before doing this
        let sql = "SELECT id FROM \(schema).code_transaction_history WHERE redeemedby = '\(user)' LIMIT 1"
        let sql_a = try? record.sqlRows(sql, params: [])
        // if there are no US transactions, then do not continue
        guard (sql_a?.first) != nil else { return }
        
        let changed_date_time = SupportFunctions.sharedInstance.getDateAndTime(changed)
        let timenow           = CCXServiceClass.sharedInstance.getNow()

        // see if we need to add the status record
        if !record.countryExists(schema) {
            // add the country
            record.addCountry(schema)
            let _ = try? record.saveWithCustomType()
            
            // add the status record
            let cas = USBucketAccountStatus()
            
            cas.created        = timenow
            cas.createdby      = user
            cas.record_type    = USRecordType.accountStatus
            cas.change_date    = changed_date_time.date
            cas.change_time    = changed_date_time.time
            cas.account_number = user
            cas.value_original = USAccountStatusType.firstentry
            cas.value_new      = USAccountStatusType.active
            
            let _ = try? cas.saveWithCustomType(schemaIn: schema, user)
        }
        
        // add the detail record (always done)
        let cad = USBucketAccountDetail()

        // lets setup the detail record - it always is written
        cad.created        = timenow
        cad.createdby      = user
        cad.record_type    = USRecordType.accountDetail
        cad.change_date    = changed_date_time.date
        cad.change_time    = changed_date_time.time
        cad.account_number = user
        
        // add the values
        cad.value_new = toValue
        if !codeNumber.isNil { cad.code_number = codeNumber! }
        if !amount.isNil { cad.amount = amount! }
        if !adjustmentReason.isNil { cad.adjustment_reason = adjustmentReason! }
        if !disbursementReason.isNil { cad.disbursement_reason = disbursementReason! }

        let _ = try? cad.saveWithCustomType(schemaIn: schema, user)

    }

    
}
