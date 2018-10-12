//
//  Address.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class USAccountCodeStatus: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var record_type     : String? = nil
    var change_date     : String? = nil
    var change_time     : String? = nil
    var code_number     : String? = nil
    var value_original  : Int? = nil
    var value_new       : Int? = nil
    var note            : String? = nil
    
    var processed : Int? = nil
    var processedby : String? = nil

    //MARK: Table name
    override public func table() -> String { return "us_account_code_status" }
    
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
        
        if let data = this.data.usAccountStatusDic.record_type {
           record_type  = data
        }
        
        if let data = this.data.usAccountDetailDic.processed {
            processed  = data
        }
        
        if let data = this.data.usAccountDetailDic.processedby {
            processedby  = data
        }
        
        if let data = this.data.usAccountStatusDic.change_date {
            change_date = data
        }
        
        if let data = this.data.usAccountStatusDic.change_time {
            change_time = data
        }
        
        if let data = this.data.usAccountStatusDic.code_number {
            code_number = data
        }
        
        if let data = this.data.usAccountStatusDic.value_original {
            value_original = data
        }
        
        if let data = this.data.usAccountStatusDic.value_new {
            value_new = data
        }
        
        if let data = this.data.usAccountStatusDic.note {
            note = data
        }

    }
    
    func rows() -> [USAccountCodeStatus] {
        var rows = [USAccountCodeStatus]()
        for i in 0..<self.results.rows.count {
            let row = USAccountCodeStatus()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "record_type":
                if (value as? String).isNotNil {
                    self.record_type = (value as! String)
                }
                
            case "change_date":
                if (value as? String).isNotNil {
                    self.change_date = (value as! String)
                }
                
            case "change_time":
                if (value as? String).isNotNil {
                    self.change_time = (value as! String)
                }
                
            case "processedby":
                if (value as? String).isNotNil {
                    self.processedby = (value as! String)
                }
                
            case "processed":
                if (value as? Int).isNotNil {
                    self.processed = (value as! Int)
                }
                
            case "code_number":
                if (value as? String).isNotNil {
                    self.code_number = (value as! String)
                }
                
            case "value_original":
                if (value as? Int).isNotNil {
                    self.value_original = (value as! Int)
                }
                
            case "value_new":
                if (value as? Int).isNotNil {
                    self.value_new = (value as! Int)
                }

            case "note":
                if (value as? String).isNotNil {
                    self.note = (value as! String)
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
        
        if self.record_type.isNotNil {
            dictionary.usAccountStatusDic.record_type = self.record_type
        }
        
        if self.change_date.isNotNil {
            dictionary.usAccountStatusDic.change_date = self.change_date
        }
        
        if self.change_time.isNotNil {
            dictionary.usAccountStatusDic.change_time = self.change_time
        }
        
        if self.code_number.isNotNil {
            dictionary.usAccountStatusDic.code_number = self.code_number
        }
        
        if self.value_original.isNotNil {
            dictionary.usAccountStatusDic.value_original = self.value_original
        }
        
        if self.value_new.isNotNil {
            dictionary.usAccountStatusDic.value_new = self.value_new
        }

        if self.note.isNotNil {
            dictionary.usAccountStatusDic.note = self.note
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: USAccountCodeStatus)-> Bool {
        
        var diff = true
        
        if diff == true, self.record_type != targetItem.record_type {
            diff = false
        }
        
        if diff == true, self.change_date != targetItem.change_date {
            diff = false
        }
        
        if diff == true, self.change_time != targetItem.change_time {
            diff = false
        }
        
        if diff == true, self.code_number != targetItem.code_number {
            diff = false
        }
        
        if diff == true, self.value_original != targetItem.value_original {
            diff = false
        }
        
        if diff == true, self.value_new != targetItem.value_new {
            diff = false
        }

        if diff == true, self.note != targetItem.note {
            diff = false
        }

        return diff
        
    }
}


