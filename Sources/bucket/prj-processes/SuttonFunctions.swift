import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib

public class SuttonFunctions {

    struct SuttonDefaults {
        static let schema = "us"
        static let mainFileDirectory = Dir("transferfiles")
        static let usFileDirectory = Dir("transferfiles/us")
    }
    
    private func checkFileDirectory() {

        let main_file_dir = SuttonDefaults.mainFileDirectory
        if !main_file_dir.exists {
            let _ = try? main_file_dir.create()
        }

        if main_file_dir.exists {
            let us_file_dir = SuttonDefaults.usFileDirectory
            if !us_file_dir.exists {
                let _ = try? us_file_dir.create()
            }
        }
        
    }
    
    private func createFileHeader(_ fileNumber:Int? = 1, _ fileDate:Date? = nil, _ repeatFile:Bool? = false) -> (file_name: String, main_file_name:String, batch_number:Int, file_date:Date?) {
        
        // make sure the driectory is there
        self.checkFileDirectory()
        
        var finalFileDate:Date? = nil
        if fileDate.isNil {
            // set the date to today - the time does not matter
            let dnow = Double(CCXServiceClass.sharedInstance.getNow())
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
            return ("", "", 0, nil)
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
        
        return (filename, fileprefix, filenumber, finalFileDate)
        
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
    
    func createTransferFile () {

        // order by number.
        // 1 = file header
        // 1x to 99 =
        // 1xxx to 999 =
        // 1xxxx to 9999 =
        // 100000 = file footer

        
        var files:[Int:String] = [:]
        let date_count = Date(timeIntervalSince1970: Double(CCXServiceClass.sharedInstance.getNow()))
        
        
        let header = self.createFileHeader(nil, date_count, false)
        files[1] = header.file_name
        
        var batch_count = 0
        
        // this is where we are creating the batches within this file itself.
        
        
        files[100000] = self.createFileFooter(batch_count, header.batch_number, date_count)
        
        let sortedfiles = files.sorted { $0.key < $1.key }
        
        for (key, value) in sortedfiles {
            print("Sorted: \(key): \(value)")
        }
    }

    private func createBatchHeader(_ batch_number:Int) {
        
    }

    private func createBatchFooter(_ batch_number:Int) {
        
    }

    private func createCodeAccountStatusBatch(_ batch_number:Int) {
        
    }

    private func createBucketAccountStatusBatch(_ batch_number:Int) {
        
    }

    private func createCodeAccountDetailBatch(_ batch_number:Int) {
        
    }

    private func createBucketAccountDetailBatch(_ batch_number:Int) {
        
    }

}
