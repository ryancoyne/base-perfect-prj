import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import SwiftMoment

/// The select option gives you the functionality of selecting which batch cases you want to write to the database.  Each grouping of batch cases is one file.  This allows you to create a file for each, or a file for two and another file for two.
public enum Batch {
    case all(BatchOptions, user_id: String?), select([[BatchCase]])
    public enum BatchCase {
        case accountCodeDetails, accountCodeStatuses, bucketAccountDetail, bucketAccountStatuses
    }
    public enum BatchOptions {
        case singleFileWithOrder(to: Int, from: Int, schema: String, order: [BatchCase], description : String), separateFiles(to: Int, from: Int, schema: String), oneFile(to: Int, from: Int, schema: String, isRepeat: Bool, description : String)
    }
}

extension NumberFormatter {
    func format(_ value : Int, buffingCharacters: Int) -> String? {
        self.minimumIntegerDigits = buffingCharacters
        self.maximumIntegerDigits = buffingCharacters
        self.maximumFractionDigits = 0
        self.minimumFractionDigits = 0
        return self.string(from: NSNumber(value: value))
    }
    func format(_ value : Double, buffingCharacters: Int, decimalLimit: Int) -> String? {
        self.minimumIntegerDigits = buffingCharacters
        self.maximumIntegerDigits = buffingCharacters
        self.minimumFractionDigits = decimalLimit
        self.maximumFractionDigits = decimalLimit
        return self.string(from: NSNumber(value: value))
    }
}

public enum BatchExeption : Error {
    case invalidDates, invalidSchema(String), noDetailRecords(to: Int, from: Int)
}

typealias BatchResult = (batchCount : Int, totalDetailRecords : Int)

public class SuttonFunctions {
    
    static var numberFormatter : NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumIntegerDigits = 4
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumIntegerDigits = 4
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter
    }()
    
    struct SuttonDefaults {
        static let schema = "us"
        static let mainFileDirectory    = Dir("/transfer")
        static let usFileDirectory      = Dir("/transfer/tosend")
        static let workFileDirectory    = Dir("/transfer/tmp")
        static let mainFileDirectoryOSX = Dir("transfer")
        static let usFileDirectoryOSX   = Dir("transfer/tosend")
        static let workFileDirectoryOSX = Dir("transfer/tmp")
    }
    
    static func batchAll() {
        
        var date_to_start = 0
        var date_to_end   = 0
        
        let yest = SupportFunctions.yesterday(CCXServiceClass.getNow())
        
        // when was the last one run?
        var sql = "SELECT record_end_date FROM us.batch_header ORDER BY record_end_date DESC LIMIT 1"
        let bh = BatchHeader()
        let bh_r = try? bh.sqlRows(sql, params: [])
        if bh_r!.count == 0 {
            
            sql = "SELECT * FROM us.us_account_code_detail ORDER BY created ASC LIMIT 1"
            let uacd = try? bh.sqlRows(sql, params: [])
            
            var doit = SupportFunctions.yesterday(CCXServiceClass.getNow())
            if uacd!.count > 0 {
                let uacd_d = USAccountCodeDetail()
                uacd_d.to(uacd!.first!)
                doit = SupportFunctions.yesterday(uacd_d.created!)
            }
            
            // there were no records
            date_to_start = doit.start
            date_to_end   = doit.end
        } else {
            
            let bhr = BatchHeader()
            bhr.to(bh_r!.first!)
            
            // the next day - remmeber - all info is not there, just the record_end_date (see the SQL statement)
            date_to_start = bhr.record_end_date! + 1
            date_to_end   = bhr.record_end_date! + 86400
        }
        
        while date_to_end <= yest.end {

            do {
                let numberOfBatches = try SuttonFunctions.batch(in: .all(.oneFile(to: date_to_end,from: date_to_start, schema: "us", isRepeat: false, description: "Batch from \(date_to_start) to \(date_to_end) epoch."), user_id: nil))
                print(numberOfBatches)
            } catch {
                print(error)
            }
            
            // increment the next week
            date_to_start += 86400
            date_to_end   += 86400

        }
        
    }
    
    @discardableResult
    static func batch(in: Batch) throws -> BatchResult {
        let processing_time = Int(Date().timeIntervalSince1970)
        switch `in` {
        case .all(let option, let user_id):
            switch option {
            case .oneFile(let input):
                
                if input.to <= input.from { throw BatchExeption.invalidDates }
                
                // Okay, lets go and create the reference code:
                let referenceCode = String.referenceCode(forSchema: input.schema)
                
                // The batch date for the file name: (this is from the input dates:)
                let momen = moment(TimeZone(abbreviation: "GMT")!, locale: Locale(identifier: "en_US"))
                let fileName = "sutton_accounts_\(input.from.dateString(format: "yyyyMMdd"))"
                
                // We need the country id for the batch header, for whatever reason:
                guard let countryId = Country.idWith(input.schema) else { throw BatchExeption.invalidSchema(input.schema) }
                
                // If we have no detail records to process, we dont want to write ANYTHING.
                var totalDetailRecordsCount = 0
                
                // Before writing anything, lets check if we have records for the following queries:
                let query = USAccountCodeDetail()
                var sqlStatement = "SELECT * FROM \(input.schema).us_account_code_detail_view_processed_no WHERE created BETWEEN \(input.from) AND \(input.to);"

                let accountCodeResults = (try? query.sqlRows(sqlStatement, params: [])) ?? []
                totalDetailRecordsCount += accountCodeResults.count
                
                let query2 = USAccountCodeStatus()

                sqlStatement = "SELECT * FROM \(input.schema).us_account_code_status_view_processed_no WHERE created BETWEEN \(input.from) AND \(input.to);"

                let accountCodeStatusResults = (try? query2.sqlRows(sqlStatement, params: [])) ?? []
                totalDetailRecordsCount += accountCodeStatusResults.count
                
                let query3 = USBucketAccountDetail()

                sqlStatement = "SELECT * from \(input.schema).us_bucket_account_detail_view_processed_no where created BETWEEN \(input.from) AND \(input.to);"

                let bucketAccountDetailResults = (try? query3.sqlRows(sqlStatement, params: [])) ?? []
                totalDetailRecordsCount += bucketAccountDetailResults.count
                
                let query4 = USBucketAccountStatus()

                sqlStatement = "SELECT * from \(input.schema).us_bucket_account_status_view_processed_no where created BETWEEN \(input.from) AND \(input.to);"

                let bucketAccountStatusResults = (try? query4.sqlRows(sqlStatement, params: [])) ?? []
                totalDetailRecordsCount += bucketAccountStatusResults.count
                
                let header = BatchHeader()
                header.batch_identifier = referenceCode
                header.country_id = countryId
                header.batch_type = "sutton_all"
                header.current_status = BatchHeaderStatus.working_on_it

                header.description = input.description
                header.record_start_date = input.from
                header.record_end_date = input.to
                header.status = CCXServiceClass.getNow()
    
                header.statusby = user_id ?? CCXDefaultUserValues.user_server
                header.file_name = fileName
                
                // Okay, we should save the header for now.
                let result = try? header.saveWithCustomType(schemaIn: input.schema)
                header.id = result?.first?.data.id
                
                // Order starts by one:
                var order = 1
                
                // Okay, we need to write out two detail records first before we write out the details:
                let fileHeader = BatchDetail()
                fileHeader.batch_header_id = header.id
                fileHeader.batch_group = "fh"
                fileHeader.batch_order = order; /* Increment the order:*/ order += 1
                
                // Create the detail & save:
                var theDet = "FH"
                // File Creation Date:
                theDet.append(momen.format("yyyyMMdd"))
                // File Creation Time:
                theDet.append(momen.format("hhmmss"))
                // File Number:
                theDet.append(numberFormatter.format(1, buffingCharacters: 9)!)
                theDet.append("            Sutton Bank")
                theDet.append("    Bucket Technologies")
                theDet.append(referenceCode)
                
                if input.isRepeat { theDet.append("Y") } else { theDet.append("N") }
                
                fileHeader.detail_line = theDet
                fileHeader.detail_line_length = theDet.length
                
                // Save the file header:
                _ = try? fileHeader.saveWithCustomType(schemaIn: input.schema)
                
                // For the batch control file, we need the count of detail records.
                var currentDetailRecordsCount = 0
                // The batch count:
                var batchCount = 0
                
                // Okay, here we are writing one file.  So this is one batch for all the different items we are reporting.  First lets update our header file.
                header.current_status = BatchHeaderStatus.in_progress
                _ = try? header.saveWithCustomType(schemaIn: input.schema)
                
                for row in accountCodeResults {
                    
                    // If this is the first record, we need to create the initial batch header.... or if we reset the current detail records to zero
                    if accountCodeResults.first?.data.id == row.data.id || currentDetailRecordsCount == 0 {
                        // Apend the batch count:
                        batchCount += 1
                        // Now we need to create the batch header:
                        let batchHeader = BatchDetail()
                        batchHeader.batch_header_id = header.id
                        batchHeader.batch_group = "bh"
                        batchHeader.batch_order = order; /* Increment the order:*/ order += 1
                        
                        theDet = "BH"
                        theDet.append(momen.format("yyyyMMdd"))
                        theDet.append(momen.format("hhmmss"))
                        // Batch Count:
                        theDet.append(numberFormatter.format(batchCount, buffingCharacters: 9)!)
                        // Batch effective date:
                        theDet.append(input.to.dateString(format: "yyyyMMdd"))
                        theDet.append(referenceCode)
                        
                        if input.isRepeat { theDet.append("Y") } else { theDet.append("N") }
                        
                        batchHeader.detail_line = theDet
                        batchHeader.detail_line_length = theDet.length
                        
                        // Save the batch header:
                        _ = try? batchHeader.saveWithCustomType(schemaIn: input.schema)

                    }
                    
                    // Okay.  We need to go and write a bunch of Batch Detail Records.
                    let detail = BatchDetail()
                    detail.batch_header_id = header.id
                    detail.batch_group = "bd"
                    detail.batch_order = order
                    
                    // Okay we need to write out the detail.
                    var theDetail = "CD"
                    if let changeDate = row.data.usAccountDetailDic.change_date {
                        theDetail.append("\(changeDate)")
                    } else {
                        theDetail.append("        ")
                    }
                    
                    if let changeTime = row.data.usAccountDetailDic.change_time {
                        theDetail.append("\(changeTime)")
                    } else {
                        theDetail.append("      ")
                    }
                    
                    if let code = row.data.usAccountDetailDic.code_number {
                        theDetail.append("\(code)")
                    } else {
                        theDetail.append("              ")
                    }
                    
                    if let originalValue = row.data.usAccountDetailDic.value_original {
                        theDetail.append("\(originalValue)")
                    } else {
                        theDetail.append(" ")
                    }
                    
                    if let newValue = row.data.usAccountDetailDic.value_new {
                        theDetail.append("\(newValue)")
                    } else {
                        theDetail.append(" ")
                    }
                    
                    if let amount = row.data.usAccountDetailDic.amount {
                        
                        let amountString = numberFormatter.format(amount, buffingCharacters: 4, decimalLimit: 2)!
                        theDetail.append(amountString)
                        
                    } else {
                        theDetail.append("       ")
                    }
                    
                    // Okay we have written out the details for this record.  We have to set and save the batch detail:
                    detail.detail_line = theDetail
                    detail.detail_line_length = theDetail.count
                    
                    // Save the Batch detail record:
                    _=try? detail.saveWithCustomType(schemaIn: input.schema)
                    
                    // Append the order for the next record:
                    order += 1
                    currentDetailRecordsCount += 1
                    
                    // If the count is equal to 999, we need to go and start another batch header/control file and set back the detail record count to zero, and finish out the batch control, or if it is the LAST object:
                    if currentDetailRecordsCount == 999 || accountCodeResults.last?.data.id == row.data.id {
                        
                        let batchControl = BatchDetail()
                        batchControl.batch_header_id = header.id
                        batchControl.batch_group = "bc"
                        batchControl.batch_order = order;  /* Increment the order:*/ order += 1
                        
                        theDet = "BC"
                        // Entry Count:
                        theDet.append(numberFormatter.format(currentDetailRecordsCount, buffingCharacters: 3)!)
                        // Batch Number:
                        theDet.append(numberFormatter.format(batchCount, buffingCharacters: 9)!)
                        
                        batchControl.detail_line = theDet
                        batchControl.detail_line_length = theDet.count
                        _ = try? batchControl.saveWithCustomType(schemaIn: input.schema)
                        
                        // Okay, now we need to create the new batchHeader record:
                        // Set the detail records to zero, and append the batch number:
                        currentDetailRecordsCount = 0
                    
                    }
                    
                    // update to processed since we are complete with this row
                    let upd = USAccountCodeDetail()
                    upd.to(row)
                    upd.processed   = processing_time
                    upd.processedby = CCXDefaultUserValues.user_server
                    
                    _ = try? upd.saveWithCustomType(schemaIn: input.schema)
                    
                }
                
                // Okay, now the next table:
                for row in accountCodeStatusResults {
                    
                    // If this is the first record, we need to create the initial batch header
                    if accountCodeStatusResults.first?.data.id == row.data.id || currentDetailRecordsCount == 0 {
                        // Apend the batch count:
                        batchCount += 1
                        // Now we need to create the batch header:
                        let batchHeader = BatchDetail()
                        batchHeader.batch_header_id = header.id
                        batchHeader.batch_group = "bh"
                        batchHeader.batch_order = order; /* Increment the order:*/ order += 1
                        
                        theDet = "BH"
                        theDet.append(momen.format("yyyyMMdd"))
                        theDet.append(momen.format("hhmmss"))
                        // Batch Count:
                        theDet.append(numberFormatter.format(batchCount, buffingCharacters: 9)!)
                        // Batch effective date:
                        theDet.append(input.to.dateString(format: "yyyyMMdd"))
                        theDet.append(referenceCode)
                        
                        if input.isRepeat { theDet.append("Y") } else { theDet.append("N") }
                        
                        batchHeader.detail_line = theDet
                        batchHeader.detail_line_length = theDet.length
                        
                        // Save the batch header:
                        _ = try? batchHeader.saveWithCustomType(schemaIn: input.schema)
                        
                    }
                    
                    let detail = BatchDetail()
                    detail.batch_header_id = header.id
                    detail.batch_group = "bd"
                    detail.batch_order = order
                    
                    // Okay... start writing out the details:
                    var theDetail = "CS"
                    if let changeDate = row.data.usAccountStatusDic.change_date {
                        theDetail.append(changeDate)
                    } else {
                        theDetail.append("        ")
                    }
                    
                    if let changeTime = row.data.usAccountStatusDic.change_time {
                        theDetail.append(changeTime)
                    } else {
                        theDetail.append("      ")
                    }
                    
                    if let code = row.data.usAccountStatusDic.code_number {
                        theDetail.append(code)
                    } else {
                        theDetail.append("              ")
                    }
                    
                    if let originalValue = row.data.usAccountStatusDic.value_original {
                        theDetail.append("\(originalValue)")
                    } else {
                        theDetail.append(" ")
                    }
                    
                    if let newValue = row.data.usAccountStatusDic.value_new {
                        theDetail.append("\(newValue)")
                    } else {
                        theDetail.append(" ")
                    }
                    
                    // Okay we have written out the details for this record.  We have to set and save the batch detail:
                    detail.detail_line = theDetail
                    detail.detail_line_length = theDetail.count
                    
                    // Save the Batch detail record:
                    _=try? detail.saveWithCustomType(schemaIn: input.schema)
                    
                    // Append the order of the batch detail records.
                    order += 1
                    currentDetailRecordsCount += 1
                    
                    // If the count is equal to 999, we need to go and start another batch header/control file and set back the detail record count to zero, and finish out the batch control
                    if currentDetailRecordsCount == 999 || accountCodeStatusResults.last?.data.id == row.data.id {
                        
                        let batchControl = BatchDetail()
                        batchControl.batch_header_id = header.id
                        batchControl.batch_group = "bc"
                        batchControl.batch_order = order;  /* Increment the order:*/ order += 1
                        
                        theDet = "BC"
                        // Entry Count:
                        theDet.append(numberFormatter.format(currentDetailRecordsCount, buffingCharacters: 3)!)
                        // Batch Number:
                        theDet.append(numberFormatter.format(batchCount, buffingCharacters: 9)!)
                        
                        batchControl.detail_line = theDet
                        batchControl.detail_line_length = theDet.count
                        _ = try? batchControl.saveWithCustomType(schemaIn: input.schema)
                        
                        // Okay, now we need to create the new batchHeader record:
                        // Set the detail records to zero, and append the batch number:
                        currentDetailRecordsCount = 0
                        
                    }
                    
                    // update to processed since we are complete with this row
                    let upd = USAccountCodeStatus()
                    upd.to(row)
                    upd.processed   = processing_time
                    upd.processedby = CCXDefaultUserValues.user_server
                    
                    _ = try? upd.saveWithCustomType(schemaIn: input.schema)

                }
                
                // Now the third table:
                for row in bucketAccountDetailResults {
                    
                    // If this is the first record, we need to create the initial batch header
                    if bucketAccountDetailResults.first?.data.id == row.data.id || currentDetailRecordsCount == 0 {
                        // Apend the batch count:
                        batchCount += 1
                        // Now we need to create the batch header:
                        let batchHeader = BatchDetail()
                        batchHeader.batch_header_id = header.id
                        batchHeader.batch_group = "bh"
                        batchHeader.batch_order = order; /* Increment the order:*/ order += 1
                        
                        theDet = "BH"
                        theDet.append(momen.format("yyyyMMdd"))
                        theDet.append(momen.format("hhmmss"))
                        // Batch Count:
                        theDet.append(numberFormatter.format(batchCount, buffingCharacters: 9)!)
                        // Batch effective date:
                        theDet.append(input.to.dateString(format: "yyyyMMdd"))
                        theDet.append(referenceCode)
                        
                        if input.isRepeat { theDet.append("Y") } else { theDet.append("N") }
                        
                        batchHeader.detail_line = theDet
                        batchHeader.detail_line_length = theDet.length
                        
                        // Save the batch header:
                        _ = try? batchHeader.saveWithCustomType(schemaIn: input.schema)
                        
                    }
                    
                    let detail = BatchDetail()
                    detail.batch_header_id = header.id
                    detail.batch_group = "bd"
                    detail.batch_order = order
                    
                    var theDetail = "BD"
                    if let changeDate = row.data.usBucketAccountDetailDic.change_date {
                        theDetail.append(changeDate)
                    } else {
                        theDetail.append("        ")
                    }
                    
                    if let changeTime = row.data.usBucketAccountDetailDic.change_time {
                        theDetail.append(changeTime)
                    } else {
                        theDetail.append("      ")
                    }
                    
                    if let acN = row.data.usBucketAccountDetailDic.account_number {
                        theDetail.append(acN)
                    } else {
                        theDetail.append("              ")
                    }
                    
                    if let newValue = row.data.usBucketAccountDetailDic.value_new {
                        theDetail.append("\(newValue)")
                    } else {
                        theDetail.append(" ")
                    }
                    
                    if let newValue = row.data.usBucketAccountDetailDic.code_number {
                        theDetail.append("\(newValue)")
                    } else {
                        theDetail.append("              ")
                    }
                    
                    if let newValue = row.data.usBucketAccountDetailDic.amount {
                        theDetail.append(numberFormatter.format(newValue, buffingCharacters: 4, decimalLimit: 2)!)
                    } else {
                        theDetail.append("       ")
                    }
                    
                    if let newValue = row.data.usBucketAccountDetailDic.adjustment_reason {
                        
                        theDetail.append(numberFormatter.format(newValue, buffingCharacters: 2)!)
                        
                    } else {
                        theDetail.append("  ")
                    }
                    
                    if let newValue = row.data.usBucketAccountDetailDic.disbursement_reason {
                        
                        theDetail.append(numberFormatter.format(newValue, buffingCharacters: 2)!)
                        
                    } else {
                        theDetail.append("  ")
                    }
                    
                    // Okay we have written out the details for this record.  We have to set and save the batch detail:
                    detail.detail_line = theDetail
                    detail.detail_line_length = theDetail.count
                    
                    // Save the Batch detail record:
                    _=try? detail.saveWithCustomType(schemaIn: input.schema)
                    
                    // Append the order of the batch detail records.
                    order += 1
                    currentDetailRecordsCount += 1
                    
                    // If the count is equal to 999, we need to go and start another batch header/control file and set back the detail record count to zero, and finish out the batch control
                    if currentDetailRecordsCount == 999 || bucketAccountDetailResults.last?.data.id == row.data.id {
                        
                        let batchControl = BatchDetail()
                        batchControl.batch_header_id = header.id
                        batchControl.batch_group = "bc"
                        batchControl.batch_order = order;  /* Increment the order:*/ order += 1
                        
                        theDet = "BC"
                        // Entry Count:
                        theDet.append(numberFormatter.format(currentDetailRecordsCount, buffingCharacters: 3)!)
                        // Batch Number:
                        theDet.append(numberFormatter.format(batchCount, buffingCharacters: 9)!)
                        
                        batchControl.detail_line = theDet
                        batchControl.detail_line_length = theDet.count
                        _ = try? batchControl.saveWithCustomType(schemaIn: input.schema)
                        
                        // Okay, now we need to create the new batchHeader record:
                        // Set the detail records to zero, and append the batch number:
                        currentDetailRecordsCount = 0
                        
                    }
                    
                    // update to processed since we are complete with this row
                    let upd = USBucketAccountDetail()
                    upd.to(row)
                    upd.processed   = processing_time
                    upd.processedby = CCXDefaultUserValues.user_server
                    
                    _ = try? upd.saveWithCustomType(schemaIn: input.schema)

                }
                
                // Now last, but not least:
                for row in bucketAccountStatusResults {
                    
                    // If this is the first record, we need to create the initial batch header
                    if bucketAccountStatusResults.first?.data.id == row.data.id || currentDetailRecordsCount == 0 {
                        // Apend the batch count:
                        batchCount += 1
                        // Now we need to create the batch header:
                        let batchHeader = BatchDetail()
                        batchHeader.batch_header_id = header.id
                        batchHeader.batch_group = "bh"
                        batchHeader.batch_order = order; /* Increment the order:*/ order += 1
                        
                        theDet = "BH"
                        theDet.append(momen.format("yyyyMMdd"))
                        theDet.append(momen.format("hhmmss"))
                        // Batch Count:
                        theDet.append(numberFormatter.format(batchCount, buffingCharacters: 9)!)
                        // Batch effective date:
                        theDet.append(input.to.dateString(format: "yyyyMMdd"))
                        theDet.append(referenceCode)
                        
                        if input.isRepeat { theDet.append("Y") } else { theDet.append("N") }
                        
                        batchHeader.detail_line = theDet
                        batchHeader.detail_line_length = theDet.length
                        
                        // Save the batch header:
                        _ = try? batchHeader.saveWithCustomType(schemaIn: input.schema)
                        
                    }
                    
                    let detail = BatchDetail()
                    detail.batch_header_id = header.id
                    detail.batch_group = "bd"
                    detail.batch_order = order
                    
                    var theDetail = "BS"
                    if let changeDate = row.data.usBucketAccountStatusDic.change_date {
                        theDetail.append(changeDate)
                    } else {
                        theDetail.append("        ")
                    }
                    
                    if let changeTime = row.data.usBucketAccountStatusDic.change_time {
                        theDetail.append(changeTime)
                    } else {
                        theDetail.append("      ")
                    }
                    
                    if let acN = row.data.usBucketAccountStatusDic.account_number {
                        theDetail.append(acN)
                    } else {
                        theDetail.append("              ")
                    }
                    
                    if let originalValue = row.data.usBucketAccountStatusDic.value_original {
                        theDetail.append("\(originalValue)")
                    } else {
                        theDetail.append("      ")
                    }
                    
                    if let newValue = row.data.usBucketAccountStatusDic.value_new {
                        theDetail.append("\(newValue)")
                    } else {
                        theDetail.append("      ")
                    }
                    
                    // Okay we have written out the details for this record.  We have to set and save the batch detail:
                    detail.detail_line = theDetail
                    detail.detail_line_length = theDetail.count
                    
                    // Save the Batch detail record:
                    _=try? detail.saveWithCustomType(schemaIn: input.schema)
                    
                    // Append the order of the batch detail records.
                    order += 1
                    currentDetailRecordsCount += 1
                    
                    // If the count is equal to 999, we need to go and start another batch header/control file and set back the detail record count to zero, and finish out the batch control
                    if currentDetailRecordsCount == 999 || bucketAccountStatusResults.last?.data.id == row.data.id {
                        
                        let batchControl = BatchDetail()
                        batchControl.batch_header_id = header.id
                        batchControl.batch_group = "bc"
                        batchControl.batch_order = order;  /* Increment the order:*/ order += 1
                        
                        theDet = "BC"
                        // Entry Count:
                        theDet.append(numberFormatter.format(currentDetailRecordsCount, buffingCharacters: 3)!)
                        // Batch Number:
                        theDet.append(numberFormatter.format(batchCount, buffingCharacters: 9)!)
                        
                        batchControl.detail_line = theDet
                        batchControl.detail_line_length = theDet.count
                        _ = try? batchControl.saveWithCustomType(schemaIn: input.schema)
                        
                        // Okay, now we need to create the new batchHeader record:
                        // Set the detail records to zero, and append the batch number:
                        currentDetailRecordsCount = 0
                        
                    }
                    
                    // update to processed since we are complete with this row
                    let upd = USBucketAccountStatus()
                    upd.to(row)
                    upd.processed   = processing_time
                    upd.processedby = CCXDefaultUserValues.user_server
                    
                    _ = try? upd.saveWithCustomType(schemaIn: input.schema)

                }
                
                // Now the file control:
                let fileControl  = BatchDetail()
                fileControl.batch_header_id = header.id
                fileControl.batch_group = "fc"
                fileControl.batch_order = order;  /* Increment the order:*/ order += 1
                
                theDet = "FC"
                // Batch Count:
                theDet.append(numberFormatter.format(batchCount, buffingCharacters: 3)!)
                // File Number:  (This should always be one for now.)
                theDet.append(numberFormatter.format(1, buffingCharacters: 9)!)
                
                fileControl.detail_line = theDet
                fileControl.detail_line_length = theDet.count
                
                // Save the file control:
                _ = try? fileControl.saveWithCustomType(schemaIn: input.schema)
                
                // Okay, we wrote everything successfully, lets update the batch header record:
                header.current_status = BatchHeaderStatus.pendingTransfer
                _ = try? header.saveWithCustomType(schemaIn: input.schema)
                
                return (batchCount, totalDetailRecordsCount)
        
            case .separateFiles:
                break
            case .singleFileWithOrder(let input):
                
                // Do the normal setup here.
                for type in input.order {
                    switch type {
                    case .accountCodeDetails:
                        // Perform all the normal operations for the account code details:
                        break
                    case .accountCodeStatuses:
                        // Perform all the normal operations for the account code statuses:
                        break
                    case .bucketAccountDetail:
                        // Perform all the normal operations for the bucket account details:
                        break
                    case .bucketAccountStatuses:
                        // Perform all the normal operations for the bucket account statuses:
                        break
                    }
                }
                break
            }
        case .select(let batches):
            for batchFile in batches {
                // We are creating a new batch here:
                for option in batchFile {
                    switch option {
                    case .accountCodeDetails:
                        break
                    case .accountCodeStatuses:
                        break
                    case .bucketAccountDetail:
                        break
                    case .bucketAccountStatuses:
                        break
                    }
                }
            }
            break
        }
        return (0,0)
    }
    
//    static func batchTables(to : Int, from : Int) {
//        //  String date format:       yyyyMMdd      ->
//        let locale = Locale(identifier: "en_US")
//        if let tz = TimeZone(identifier: "GMT"),
//            let toMoment = moment(to, dateFormat: "yyyyMMdd", timeZone: tz, locale: locale),
//            let fromMoment = moment(from, dateFormat: "yyyyMMdd", timeZone: tz, locale: locale) {
//
//            let toInt = Int(toMoment.epoch())
//            let fromInt = Int(fromMoment.epoch())
//
//            // Okay, now we need to query through each of the US audit tables for the accounts and codes:
//            let codeDetails = USAccountCodeDetail()
//
//            // We need to form the SQL statement to find the data for the input dates:
//
//            let sqlStatement = "SELECT * from public.us_account_code_detail where created "
//
//
//        } else {
//
//        }
//
//    }
        
    private func createFileHeader(_ fileNumber:Int? = 1, _ fileDate:Date? = nil, _ repeatFile:Bool? = false, forSchema: String) -> (file_name: String, main_file_name:String, batch_number:Int, file_date:Date?, reference_code: String?) {
        
        // make sure the driectory is there
        
        self.checkFileDirectory()
        
        var finalFileDate:Date? = nil
        if fileDate.isNil {
            // set the date to today - the time does not matter
            let dnow = Double(CCXServiceClass.getNow())
            finalFileDate = Date(timeIntervalSince1970: dnow)
        } else {
            finalFileDate = fileDate!
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let thedate = dateFormatter.string(from: finalFileDate!)
        
        
        // lets put together the file
        let filename = "\(SuttonDefaults.usFileDirectory.path)sutton_accounts_\(thedate).header"
        let fileprefix = "\(SuttonDefaults.usFileDirectory.path)sutton_accounts_\(thedate).txt"
        
        let file = File(filename)
        
        // lets open the file and start writing to it:
        if !file.exists || !file.isOpen {
            // create the file
            let _ = try? file.open(File.OpenMode.readWrite, permissions: .rwUserGroup)
        }

        if file.fd == -1 {
            return ("", "", 0, nil, nil)
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hhmmss"
        let thetime = timeFormatter.string(from: finalFileDate!)
        
        var filenumber = 1
        if !fileNumber.isNil {
            filenumber = fileNumber!
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 9
        numberFormatter.maximumIntegerDigits = 9
        numberFormatter.format = "000000000"
        let thefilenumber = numberFormatter.string(from: NSNumber(value: filenumber))
        
        // ok - it exists and we are starting - so.... lets create the header
        var file_contents = "FH"   // position 1 & 2
        file_contents.append("\(thedate)")   // positions 3 to 10
        file_contents.append("\(thetime)")   // positions 11 to 16
        file_contents.append(thefilenumber!) // positions 17 to 25
        file_contents.append("            Sutton Bank")  // positions 26 to 48
        file_contents.append("    Bucket Technologies")  // position 49 to 71
        
        // Create the reference code:
        let refCode = String.referenceCode(forSchema: forSchema)
        
        file_contents.append("        ")   // position 72 to 79
        if !repeatFile.isNil, repeatFile! {
            file_contents.append("Y")
        } else {
            file_contents.append("N")
        }
        
        // now lets write the contents to the file
        let _ = try? file.write(string: file_contents)

        // and close it...
        file.close()
        
        return (filename, fileprefix, filenumber, finalFileDate, refCode)
        
    }
    
    // returns the string of the file
    private func createFileFooter(_ batch_count:Int, _ batch_number:Int, _ fileDate:Date)-> String {
        
        // make sure the driectory is there
        self.checkFileDirectory()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let thedate = dateFormatter.string(from: fileDate)
        
        
        // lets put together the file
        let filename = "\(SuttonDefaults.usFileDirectory.path)sutton_accounts_\(thedate).footer"
        
        let file = File(filename)
        
        // lets open the file and start writing to it:
        if !file.exists || !file.isOpen {
            // create the file
            let _ = try? file.open(File.OpenMode.readWrite, permissions: .rwUserGroup)
        }
        
        if file.fd == -1 {
            return ""
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 9
        numberFormatter.maximumIntegerDigits = 9
        numberFormatter.format = "000000000"
        let thefilenumber = numberFormatter.string(from: NSNumber(value: batch_number))
        
        numberFormatter.minimumIntegerDigits = 3
        numberFormatter.maximumIntegerDigits = 3
        numberFormatter.format = "000"
        let batchcount = numberFormatter.string(from: NSNumber(value:batch_count))
        
        // ok - it exists and we are starting - so.... lets create the header
        var file_contents = "FC"   // position 1 & 2
        file_contents.append(batchcount!)    // positions 3 to 5
        file_contents.append(thefilenumber!) // positions 6 to 14
        
        // now lets write the contents to the file
        let _ = try? file.write(string: file_contents)
        
        // and close it...
        file.close()

        return filename
    }
    
    func startBatchFileRecord(_ userId:String? = nil,_ batchId:Int? = nil,_ batchIdentifier:String? = nil) {
        
        var runningUser = ""
        if userId.isNotNil {
            runningUser = userId!
        } else {
            runningUser = CCXDefaultUserValues.user_server
        }
        
        // this will setup the batch ID or batch identifier depending on what was sent in
        //   gives us the ability to perform each section indepemndent upon the others
        var runningBatchIdentifier = ""
        var runningBatchId = 0

        if batchId.isNotNil && batchIdentifier.isNotNil {
            runningBatchId = batchId!
            runningBatchIdentifier = batchIdentifier!
        } else if batchId.isNotNil {
            // grab the batch identifier
            let bh = BatchHeader()
            let sql = "SELECT * FROM \(SuttonDefaults.schema).batch_header WHERE id = \(batchId!)"
            let bhr = try? bh.sqlRows(sql, params: [])
            if let b = bhr?.first {
                bh.to(b)
            }
            runningBatchIdentifier = bh.batch_identifier!
        } else if batchIdentifier.isNotNil {
            // grab the batch id
            let bh = BatchHeader()
            let sql = "SELECT * FROM \(SuttonDefaults.schema).batch_header WHERE batch_identifier = \(batchIdentifier!)"
            let bhr = try? bh.sqlRows(sql, params: [])
            if let b = bhr?.first {
                bh.to(b)
            }
            runningBatchId = bh.id!
        } else {
            // get new ones
            let batch = SupportFunctions.sharedInstance.getNextBatch(schemaId: SuttonDefaults.schema, "S", runningUser)
            runningBatchId         = batch.headerId
            runningBatchIdentifier = batch.batchIdentifier
        }
        
        var nextnumber = 0
        
        // we are ready to start putting together the user account information
//        self.addHeader(runningUser, runningBatchId)
//        nextnumber = self.addCodes(nextNumber: nextnumber, runningUser, runningBatchId)
//        nextnumber = self.addUsers(nextNumber: nextnumber, runningUser, runningBatchId)
//        self.addFooter(runningUser, runningBatchId)
    }
    
    func createTransferFile (schema : String) {

        // order by number.
        // 1 = file header
        // 1x to 99 =
        // 1xxx to 999 =
        // 1xxxx to 9999 =
        // 100000 = file footer

        
        var files:[Int:String] = [:]
        let date_count = Date(timeIntervalSince1970: Double(CCXServiceClass.getNow()))
        
        
        let header = self.createFileHeader(nil, date_count, false, forSchema: schema)
        files[1] = header.file_name
        
        var batch_count = 0
        
        // this is where we are creating the batches within this file itself.
        
        
        files[100000] = self.createFileFooter(batch_count, header.batch_number, date_count)
        
        let sortedfiles = files.sorted { $0.key < $1.key }
        
        for (key, value) in sortedfiles {
            print("Sorted: \(key): \(value)")
        }
    }
    
    private func checkFileDirectory() {
        
        var main_file_dir:Dir
        
        #if os(Linux)
            main_file_dir = SuttonFunctions.SuttonDefaults.mainFileDirectory
        #else
            main_file_dir = SuttonFunctions.SuttonDefaults.mainFileDirectoryOSX
        #endif
        
        if !main_file_dir.exists {
            let _ = try? main_file_dir.create()
        }
        
        var us_file_dir:Dir
        
        #if os(Linux)
            us_file_dir = SuttonFunctions.SuttonDefaults.usFileDirectory
        #else
            us_file_dir = SuttonFunctions.SuttonDefaults.usFileDirectoryOSX
        #endif
        
        if main_file_dir.exists {
            if !us_file_dir.exists {
                let _ = try? us_file_dir.create()
            }
        }
        
    }
}
