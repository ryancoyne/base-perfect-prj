//
//  CompletedFormsDetail.swift
//  COpenSSL
//
//  Created by Ryan Coyne on 8/29/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class CompletedFormsDetail: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var field_name : String? = nil
    var field_value : String? = nil
    var cf_header_id : Int? = nil
    var batch_group     : String? = nil
    var batch_order     : Int? = nil
    
    var detail_line     : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "completed_forms_detail" }
    
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
        
        if let data = this.data.cfDetailDic.cfHeaderId {
            cf_header_id = data
        }
        
        if let data = this.data.batchDetailDic.batch_group {
            batch_group = data
        }
        
        if let data = this.data.batchDetailDic.batch_order {
            batch_order = data
        }
        
        if let data = this.data.batchDetailDic.detail_line {
            detail_line = data
        }
        
    }
    
    func rows() -> [CompletedFormsDetail] {
        var rows = [CompletedFormsDetail]()
        for i in 0..<self.results.rows.count {
            let row = CompletedFormsDetail()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "cf_header_id":
                if (value as? Int).isNotNil {
                    self.cf_header_id = (value as! Int)
                }
                
            case "batch_group":
                if (value as? String).isNotNil {
                    self.batch_group = (value as! String)
                }
                
            case "field_name":
                if (value as? String).isNotNil {
                    self.field_name = (value as! String)
                }
                
            case "field_value":
                if (value as? String).isNotNil {
                    self.field_value = (value as! String)
                }
                
            case "batch_order":
                if (value as? Int).isNotNil {
                    self.batch_order = (value as! Int)
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
        
        if self.cf_header_id.isNotNil {
            dictionary.cfDetailDic.cfHeaderId = self.cf_header_id
        }
        
        if self.field_name.isNotNil {
            dictionary.cfDetailDic.fieldName = self.field_name
        }
        
        if self.field_value.isNotNil {
            dictionary.cfDetailDic.fieldValue = self.field_value
        }
        
        if self.batch_group.isNotNil {
            dictionary.cfDetailDic.batch_group = self.batch_group
        }
        
        if self.batch_order.isNotNil {
            dictionary.cfDetailDic.batch_order = self.batch_order
        }
        
        if self.detail_line.isNotNil {
            dictionary.cfDetailDic.detail_line = self.detail_line
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: CompletedFormsDetail)-> Bool {
        
        var diff = true
        
        if diff == true, self.cf_header_id != targetItem.cf_header_id {
            diff = false
        }
        
        if diff == true, self.batch_group != targetItem.batch_group {
            diff = false
        }
        
        if diff == true, self.batch_order != targetItem.batch_order {
            diff = false
        }
        
        if diff == true, self.detail_line != targetItem.detail_line {
            diff = false
        }
        
        return diff
        
    }
}