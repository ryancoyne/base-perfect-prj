//
//  Log.swift
//  bucket
//
//  Created by Mike Silvers on 9/29/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class AuditRecord: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var group          : String? = nil
    var action         : String? = nil
    var row_data       : [String:Any]? = nil
    var changed_fields : [String:Any]? = nil
    var description    : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "audit_record" }
    public func schema() -> String { return "audit" }
    
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
        
        if let data = this.data.auditRecordDic.action {
            action = data
        }
        
        if let data = this.data.auditRecordDic.group {
            group = data
        }
        
        if let data = this.data.auditRecordDic.description {
            description = data
        }
        
        if let data = this.data.auditRecordDic.changed_fields {
            changed_fields = data
        }

        if let data = this.data.auditRecordDic.row_data {
            row_data = data
        }

    }
    
    func rows() -> [AuditRecord] {
        var rows = [AuditRecord]()
        for i in 0..<self.results.rows.count {
            let row = AuditRecord()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
            
            case "group":
                if (value as? String).isNotNil {
                    self.group = (value as! String)
                }

            case "action":
                if (value as? String).isNotNil {
                    self.action = (value as! String)
                }
                
            case "description":
                if (value as? String).isNotNil {
                    self.description = (value as! String)
                }
                
            case "row_data":
                if (value as? [String:Any]).isNotNil {
                    self.row_data = (value as! [String:Any])
                }
                
            case "changed_fields":
                if (value as? [String:Any]).isNotNil {
                    self.changed_fields = (value as! [String:Any])
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
        
        if self.group.isNotNil {
            dictionary.auditRecordDic.group = self.group
        }

        if self.action.isNotNil {
            dictionary.auditRecordDic.action = self.action
        }

        if self.description.isNotNil {
            dictionary.auditRecordDic.description = self.description
        }

        if self.row_data.isNotNil {
            dictionary.auditRecordDic.row_data = self.row_data
        }
        
        if self.changed_fields.isNotNil {
            dictionary.auditRecordDic.changed_fields = self.changed_fields
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: AuditRecord)-> Bool {
        
        var diff = true
        
        if diff == true, self.group != targetItem.group {
            diff = false
        }
        
        if diff == true, self.action != targetItem.action {
            diff = false
        }

        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        if diff == true, self.row_data != targetItem.row_data {
            diff = false
        }
        
        if diff == true, self.changed_fields != targetItem.changed_fields {
            diff = false
        }

        return diff
        
    }
}
