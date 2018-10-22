//
//  BatchProcessing.swift
//  bucket
//
//  Created by Mike Silvers on 10/18/18.
//

import Foundation
import PerfectLib
import PostgresStORM

struct TransferMount {
    static let mainMountPoint          = Dir("/transfer")
    static let mainMountPointTmp       = Dir("/transfer/tmp")
    static let mainMountPointToSend    = Dir("/transfer/tosend")
    static let mainMountLockFile       = File("\(TransferMount.mainMountPoint).lock")
    static let mainMountPointOSX       = Dir("transfer")
    static let mainMountPointTmpOSX    = Dir("transfer/tmp")
    static let mainMountPointToSendOSX = Dir("transfer/tosend")
    static let mainMountLockFileOSX    = File("\(TransferMount.mainMountPointOSX).lock")
    static let ubuntuMount  = "/bin/mount"
    static let ubuntuUMount = "/bin/umount"
    static let ubuntuSudo   = "/usr/bin/sudo"
}

public class BatchProcessing {

    func processSutton(_ days:Int? = 1,_ start:Int? = 0,_ processuser:String? = nil) {
        
        var user_id = ""
        if processuser.isNil {
            user_id = CCXDefaultUserValues.user_server
        } else {
            user_id = processuser!
        }
        // this will tell us how many days and when we start.
        var stt = 0
        if start.isNotNil { stt = start! }
        if stt == 0 { stt = Int(Date().timeIntervalSince1970) }
        
        var std = 1
        if days.isNotNil, days! > 1 { std = days! }
        
        let timerange = SupportFunctions.yesterday(stt, std)
        
        // we now have the timerange for the sutton file creation
        self.processBatch("US", "sutton_all", timerange.start, timerange.end, user_id)
        
    }
    
    private func processBatch(_ schemain:String,_ batch_type:String, _ start:Int, _ end:Int,_ user_id:String) {
        
        let schema = schemain.lowercased()
        
        // grab the header records
        var sel_h = "SELECT * FROM \(schema).batch_header_view_deleted_no "
        sel_h.append("WHERE (record_start_date >= \(start)) ")
        sel_h.append("AND (record_end_date <= \(end)) ")
        sel_h.append("AND (current_status = 'pending transfer') ")
        sel_h.append("ORDER BY id ASC; ")
        
        var locked: File
        self.mountFileDirectory()

        
        // lets loop thru and process the records
        let bch_h = BatchHeader()
        let bch_r = try? bch_h.sqlRows(sel_h, params: [])
        if bch_r.isNotNil {
            
            let processing_time = Int(Date().timeIntervalSince1970)
            
            #if os(Linux)
            
                // check to see if we are locked - if so - we do not proceed
                locked = TransferMount.mainMountLockFile
            
            #else
            
                locked = TransferMount.mainMountLockFileOSX
            
            #endif
            
            if locked.exists {
                // this is already running
                return
            }
            
            // let them know we are locking
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "+%Y-%m-%d %H:%M:%S %Z"
            
            do {
                try locked.open(File.OpenMode.readWrite, permissions: File.PermissionMode.rwUserGroup)
            } catch {
                print("File error: \(error)")
            }
            
            let fd_o = try? locked.open(File.OpenMode.readWrite, permissions: File.PermissionMode.rwUserGroup)
            if fd_o != nil {
                _ = try? locked.write(string: dateformatter.string(from: Date()))
                locked.close()
            }
            
            for r in bch_r! {
                
                let bh = BatchHeader()
                bh.to(r)
                
                var filename = "sutton_no_name"
                if bh.file_name.isNotNil { filename = bh.file_name! }
                
                // process the detail records
                self.processBatchDetail(bh.id!, processing_time, user_id, filename)
                
                // update the current record
                bh.last_send   = processing_time
                bh.last_sendby = user_id
                
                if bh.initial_send.isNil, bh.initial_send! == 0 { bh.initial_send = processing_time; bh.initial_sendby = user_id }

                bh.current_status = BatchHeaderStatus.completed
                bh.status   = processing_time
                bh.statusby = user_id
                
                _ = try? bh.saveWithCustomType()
                
            }
            
            // we are done.....  delete the lock and unmount
            
        }
    }
    
    private func processBatchDetail(_ header_id:Int, _ processing_time:Int, _ processed_by:String,_ filename:String) {
        
        
    }
    
    private func mountFileDirectory() {
        
        #if os(Linux)
        
            // Mount the directory in Linux
            let task = Process()
        
            print("Mounting the main directory \(TransferMount.mainMountPoint.name)")
        
            task.launchPath = TransferMount.ubuntuSudo
            task.arguments = [TransferMount.ubuntuMount,"\(TransferMount.mainMountPoint.name)"]
        
            let pipe = Pipe()
            task.standardOutput = pipe
        
            task.launch()
        
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
            print("Main directory mount output: \(output!)")
        
            print("Complete with the mounting")
        
        #else
        
            // Make sure the directory exists in OSX
        let the_d  = TransferMount.mainMountPointOSX
        let the_dt = TransferMount.mainMountPointTmpOSX
        let the_ds = TransferMount.mainMountPointToSendOSX

        if !the_d.exists {
            _ = try? the_d.create(perms: .rwUserGroup)
        }
        
        if !the_dt.exists {
            _ = try? the_dt.create(perms: .rwUserGroup)
        }
        
        if !the_ds.exists {
            _ = try? the_ds.create(perms: .rwUserGroup)
        }
        
        #endif
    }
    
    private func umountFileDirectory() {
        
        let task = Process()
        
        print("Unmounting the main directory \(TransferMount.mainMountPoint.name)")
        
        task.launchPath = TransferMount.ubuntuSudo
        task.arguments = [TransferMount.ubuntuSudo,"\(TransferMount.mainMountPoint.name)"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        print("Main directory umount output: \(output!)")
        
        print("Complete with the mounting")
        
    }
}
