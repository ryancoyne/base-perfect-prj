import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib

public class SuttonoFunctions {

    struct SuttonDefaults {
        static let schema = "us"
    }
    
    func startBatch(_ userId:String? = nil,_ batchId:Int? = nil,_ batchIdentifier:String? = nil) {
        
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
        self.addHeader(runningUser, runningBatchId)
        nextnumber = self.addCodes(nextNumber: nextnumber, runningUser, runningBatchId)
        nextnumber = self.addUsers(nextNumber: nextnumber, runningUser, runningBatchId)
        self.addFooter(runningUser, runningBatchId)
    }

    private func addHeader(_ userId:String? = nil,_ batchId:Int? = nil) {
        
        
    }

    private func addFooter(_ userId:String? = nil,_ batchId:Int? = nil) {
        
        
    }

    private func addUsers(nextNumber:Int,_ userId:String? = nil,_ batchId:Int? = nil)-> Int {
        
        
        return nextNumber + 1
    }

    private func addCodes(nextNumber:Int,_ userId:String? = nil,_ batchId:Int? = nil)-> Int {
        
        
        return nextNumber + 1
    }
    
}
