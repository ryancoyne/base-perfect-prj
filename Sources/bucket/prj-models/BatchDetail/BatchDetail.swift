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

public class BatchDetail: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var batch_header_id : Int? = nil
    var batch_group     : Int? = nil
    var batch_order     : Int? = nil

    //MARK: Table name
    override public func table() -> String { return "batch_detail" }
    
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
        
        if let data = this.data.batchDetailDic.batch_header_id {
            batch_header_id = data
        }
        
        if let data = this.data.batchDetailDic.batch_group {
            batch_group = data
        }

        if let data = this.data.batchDetailDic.batch_order {
            batch_order = data
        }

    }
    
    func rows() -> [BatchDetail] {
        var rows = [BatchDetail]()
        for i in 0..<self.results.rows.count {
            let row = BatchDetail()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "batch_header_id":
                if (value as? Int).isNotNil {
                    self.batch_header_id = (value as! Int)
                }
                
            case "batch_group":
                if (value as? Int).isNotNil {
                    self.batch_header_id = (value as! Int)
                }

            case "batch_order":
                if (value as? Int).isNotNil {
                    self.batch_order = (value as! Int)
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
        
        if self.batch_header_id.isNotNil {
            dictionary.batchDetailDic.batch_header_id = self.batch_header_id
        }

        if self.batch_group.isNotNil {
            dictionary.batchDetailDic.batch_group = self.batch_group
        }

        if self.batch_order.isNotNil {
            dictionary.batchDetailDic.batch_order = self.batch_order
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: BatchDetail)-> Bool {
        
        var diff = true
        
        if diff == true, self.batch_header_id != targetItem.batch_header_id {
            diff = false
        }
        
        if diff == true, self.batch_group != targetItem.batch_group {
            diff = false
        }

        if diff == true, self.batch_order != targetItem.batch_order {
            diff = false
        }

        return diff
        
    }
}

