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

/// This is the class that defines the order, by line, of which Sutton requires us to upload details.
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
    /// This can be fh(file header), fc, bh(batch header), bc, bd (batch detail).
    var batch_group     : String? = nil
    /// This is the line of the file.  The file header being 1, the batch header being 2, and so on.
    var batch_order     : Int? = nil

    var detail_line_length : Int? = nil
    var detail_line     : String? = nil

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
        
        if let data = this.data.batchDetailDic.detail_line_length {
            detail_line_length = data
        }

        if let data = this.data.batchDetailDic.detail_line {
            detail_line = data
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
                if (value as? String).isNotNil {
                    self.batch_group = (value as! String)
                }

            case "batch_order":
                if (value as? Int).isNotNil {
                    self.batch_order = (value as! Int)
                }
                
            case "detail_line_length":
                if (value as? Int).isNotNil {
                    self.detail_line_length = (value as! Int)
                }

            case "detail_line":
                if (value as? String).isNotNil {
                    self.detail_line = (value as! String)
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
        
        if self.detail_line_length.isNotNil {
            dictionary.batchDetailDic.detail_line_length = self.detail_line_length
        }

        if self.batch_group.isNotNil {
            dictionary.batchDetailDic.batch_group = self.batch_group
        }

        if self.batch_order.isNotNil {
            dictionary.batchDetailDic.batch_order = self.batch_order
        }

        if self.detail_line.isNotNil {
            dictionary.batchDetailDic.detail_line = self.detail_line
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
        
        if diff == true, self.detail_line_length != targetItem.detail_line_length {
            diff = false
        }

        if diff == true, self.detail_line != targetItem.detail_line {
            diff = false
        }

        return diff
        
    }
}

