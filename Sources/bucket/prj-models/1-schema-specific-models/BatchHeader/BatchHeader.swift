//
//  CashoutGroup.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

struct BatchHeaderStatus {
    static let working_on_it = "creation"
    static let in_progress   = "in progress"
    static let completed     = "completed"
}

/// This is the class that we will save that defines the export of the file. 
public class BatchHeader: PostgresStORM {

    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    /// Arbitrary field that describes the process and the specific detail of the process.  (i.e.  sutton_codes, sutton_accounts)
    var batch_type  : String? = nil
    /// This will be the 'referenceCode' as laid out in the Google sheet.
    var batch_identifier  : String? = nil
    ///  This is the associated file name for the batch.
    var file_name : String? = nil
    var description       : String? = nil
    var country_id : Int? = nil
    var current_status    : String? = nil
    var status            : Int?    = nil
    var statusby          : String? = nil
    var initial_send      : Int?    = nil
    var initial_sendby    : String? = nil
    var last_send         : Int?    = nil
    var last_sendby       : String? = nil
    var record_start_date : Int?    = nil
    var record_end_date   : Int?    = nil

    //MARK: Table name
    override public func table() -> String { return "batch_header" }
    
    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        if let data = this.data.id.intValue {
            id = data
        }
        
        if let data = this.data.created.intValue {
            created = data
        }
        
        if let data = this.data.modified.intValue {
            modified = data
        }
        
        if let data = this.data.deleted.intValue {
            deleted = data
        }
        
        if let data = this.data.createdBy {
            createdby = data
        }
        
        if let data = this.data.modifiedBy {
            modifiedby = data
        }
        
        if let data = this.data.deletedBy {
            deletedby = data
        }
        
        if let data = this.data.batchHeaderDic.batch_type {
            batch_type = data
        }
        
        if let data = this.data.batchHeaderDic.countryId {
            country_id = data
        }
        
        if let data = this.data.batchHeaderDic.batch_identifier {
            batch_identifier = data
        }
        
        if let data = this.data.batchHeaderDic.description {
            description = data
        }

        if let data = this.data.batchHeaderDic.current_status {
            current_status = data
        }
        
        if let data = this.data.batchHeaderDic.fileName {
            file_name = data
        }

        if let data = this.data.batchHeaderDic.status {
            status = data
        }
        
        if let data = this.data.batchHeaderDic.statusby {
            statusby = data
        }

        if let data = this.data.batchHeaderDic.initial_send {
            initial_send = data
        }
        
        if let data = this.data.batchHeaderDic.initial_sendby {
            initial_sendby = data
        }

        if let data = this.data.batchHeaderDic.last_send {
            last_send = data
        }
        
        if let data = this.data.batchHeaderDic.last_sendby {
            last_sendby = data
        }

        if let data = this.data.batchHeaderDic.record_start_date {
            record_start_date = data
        }

        if let data = this.data.batchHeaderDic.record_end_date {
            record_end_date = data
        }

    }
    
    func rows() -> [BatchHeader] {
        var rows = [BatchHeader]()
        for i in 0..<self.results.rows.count {
            let row = BatchHeader()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "batch_type":
                if (value as? String).isNotNil {
                    self.batch_type = (value as! String)
                }

            case "batch_identifier":
                if (value as? String).isNotNil {
                    self.batch_identifier = (value as! String)
                }
                
            case "file_name":
                if (value as? String).isNotNil {
                    self.file_name = (value as! String)
                }
                
            case "description":
                if (value as? String).isNotNil {
                    self.description = (value as! String)
                }
                
            case "current_status":
                if (value as? String).isNotNil {
                    self.current_status = (value as! String)
                }
                
            case "status":
                if (value as? Int).isNotNil {
                    self.status = (value as! Int)
                }
                
            case "country_id":
                if (value as? Int).isNotNil {
                    self.country_id = (value as! Int)
                }
                
            case "statusby":
                if (value as? String).isNotNil {
                    self.statusby = (value as! String)
                }
                
            case "initial_send":
                if (value as? Int).isNotNil {
                    self.initial_send = (value as! Int)
                }
                
            case "initial_sendby":
                if (value as? String).isNotNil {
                    self.initial_sendby = (value as! String)
                }
                
            case "last_send":
                if (value as? Int).isNotNil {
                    self.last_send = (value as! Int)
                }
                
            case "last_sendby":
                if (value as? String).isNotNil {
                    self.last_sendby = (value as! String)
                }
                
            case "record_start_date":
                if (value as? Int).isNotNil {
                    self.record_start_date = (value as! Int)
                }
                
            case "record_end_date":
                if (value as? Int).isNotNil {
                    self.record_end_date = (value as! Int)
                }
                
            default:
                print("This should not occur")
            }
            
        }
        
    }
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.id.isNotNil {
            dictionary.id = self.id
        }
        
        if self.created.isNotNil {
            dictionary.created = self.created
        }
        
        if self.createdby.isNotNil {
            dictionary.createdBy = self.createdby
        }
        
        if self.modified.isNotNil {
            dictionary.modified = self.modified
        }
        
        if self.modifiedby.isNotNil {
            dictionary.modifiedBy = self.modifiedby
        }
        
        if self.deleted.isNotNil {
            dictionary.deleted = self.deleted
        }
        
        if self.deletedby.isNotNil {
            dictionary.deletedBy = self.deletedby
        }
        
        if self.batch_type.isNotNil {
            dictionary.batchHeaderDic.batch_type = self.batch_type
        }
        
        if self.country_id.isNotNil {
            dictionary.batchHeaderDic.countryId = self.country_id
        }
        
        if self.file_name.isNotNil {
            dictionary.batchHeaderDic.fileName = self.file_name
        }
        
        if self.description.isNotNil {
            dictionary.batchHeaderDic.description = self.description
        }

        if self.batch_identifier.isNotNil {
            dictionary.batchHeaderDic.batch_identifier = self.batch_identifier
        }

        if self.current_status.isNotNil {
            dictionary.batchHeaderDic.current_status = self.current_status
        }
        
        if self.status.isNotNil {
            dictionary.batchHeaderDic.status = self.status
        }
        
        if self.statusby.isNotNil {
            dictionary.batchHeaderDic.statusby = self.statusby
        }
        
        if self.initial_send.isNotNil {
            dictionary.batchHeaderDic.initial_send = self.initial_send
        }
        
        if self.initial_sendby.isNotNil {
            dictionary.batchHeaderDic.initial_sendby = self.initial_sendby
        }
        
        if self.last_send.isNotNil {
            dictionary.batchHeaderDic.last_send = self.last_send
        }
        
        if self.last_sendby.isNotNil {
            dictionary.batchHeaderDic.last_sendby = self.last_sendby
        }

        if self.record_start_date.isNotNil {
            dictionary.batchHeaderDic.record_start_date = self.record_start_date
        }

        if self.record_end_date.isNotNil {
            dictionary.batchHeaderDic.record_end_date = self.record_end_date
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: BatchHeader)-> Bool {
        
        var diff = true
        
        if diff == true, self.batch_type != targetItem.batch_type {
            diff = false
        }
        
        if diff == true, self.current_status != targetItem.current_status {
            diff = false
        }
        
        if diff == true, self.status != targetItem.status {
            diff = false
        }
        
        if diff == true, self.statusby != targetItem.statusby {
            diff = false
        }
        
        if diff == true, self.initial_send != targetItem.initial_send {
            diff = false
        }
        
        if diff == true, self.country_id != targetItem.country_id {
            diff = false
        }
        
        if diff == true, self.file_name != targetItem.file_name {
            diff = false
        }
        
        if diff == true, self.initial_sendby != targetItem.initial_sendby {
            diff = false
        }
        
        if diff == true, self.last_send != targetItem.last_send {
            diff = false
        }
        
        if diff == true, self.last_sendby != targetItem.last_sendby {
            diff = false
        }
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }

        if diff == true, self.batch_identifier != targetItem.batch_identifier {
            diff = false
        }

        if diff == true, self.record_start_date != targetItem.record_start_date {
            diff = false
        }

        if diff == true, self.record_end_date != targetItem.record_end_date {
            diff = false
        }

        return diff
        
    }
}

