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
    
    var session_id      : String? = nil
    var audit_group     : String? = nil
    var audit_action    : String? = nil
    var row_data        : [String:Any]? = nil
    var changed_fields  : [String:Any]? = nil
    var description     : String? = nil
    
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
        
        if let data = this.data.auditRecordDic.session_id {
            session_id = data
        }
        
        if let data = this.data.auditRecordDic.audit_action {
            audit_action = data
        }
        
        if let data = this.data.auditRecordDic.audit_group {
            audit_group = data
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
            
            case "session_id":
                if (value as? String).isNotNil {
                    self.session_id = (value as! String)
                }

            case "audit_group":
                if (value as? String).isNotNil {
                    self.audit_group = (value as! String)
                }

            case "audit_action":
                if (value as? String).isNotNil {
                    self.audit_action = (value as! String)
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

        if self.session_id.isNotNil {
            dictionary.auditRecordDic.session_id = self.session_id
        }

        if self.audit_group.isNotNil {
            dictionary.auditRecordDic.audit_group = self.audit_group
        }

        if self.audit_action.isNotNil {
            dictionary.auditRecordDic.audit_action = self.audit_action
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
        
        if diff == true, self.audit_group != targetItem.audit_group {
            diff = false
        }

        if diff == true, self.session_id != targetItem.session_id {
            diff = false
        }

        if diff == true, self.audit_action != targetItem.audit_action {
            diff = false
        }

        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        if diff {
            
            if self.row_data.isNotNil, targetItem.row_data.isNotNil,
                self.row_data?.count == targetItem.row_data?.count {
                
                var found = true
                for (key, value) in self.row_data! {
                    // if the key is not in the target - then true
                    if targetItem.row_data.isNotNil, let val = targetItem.row_data![key] {
                        if !self.checkValuesEqual(source: value, destination: val) { diff = false } else { diff = true; break }
                    } else {
                        found = false
                    }
                }
                // this is if we did not find one of the particular fields
                if !found { diff = true }
            } else if self.row_data.isNil && targetItem.row_data.isNil {
                // do nothing
            } else {
                // the number of records is different between the two
                diff = true
            }
        }

        if diff {
            
            if self.changed_fields.isNotNil, targetItem.changed_fields.isNotNil,
                self.changed_fields?.count == targetItem.changed_fields?.count {
                
                var found = true
                for (key, value) in self.changed_fields! {
                    // if the key is not in the target - then true
                    if targetItem.changed_fields.isNotNil, let val = targetItem.changed_fields![key] {
                        if !self.checkValuesEqual(source: value, destination: val) { diff = false } else { diff = true; break }
                    } else {
                        found = false
                    }
                }
                // this is if we did not find one of the particular fields
                if !found { diff = true }
            } else if self.changed_fields.isNil && targetItem.changed_fields.isNil {
                // do nothing
            } else {
                // the number of records is different between the two
                diff = true
            }
        }

        return diff
        
    }
    
    private func checkValuesEqual(source: Any?, destination: Any?)->Bool {
        
        // if they are both nil, they are equal
        if source.isNil && destination.isNil { return true }
        if source.isNil && destination.isNotNil { return false }
        if source.isNotNil && destination.isNil { return false }

        if (source is String) && !(destination is String) { return false }
        if (source is Int) && !(destination is Int) { return false }
        if (source is Double) && !(destination is Double) { return false }
        if (source is [String:Any]) && !(destination is [String:Any]) { return false }

        switch source {
            
        case let o_string as String:
            let d_string = destination as! String
            if o_string == d_string { return true }

        case let o_int as Int:
            let d_int = destination as! Int
            if o_int == d_int { return true }
            
        case let o_double as Double:
            let d_double = destination as! Double
            if o_double == d_double { return true }
            
        case let o_bool as Bool:
            let d_bool = destination as! Bool
            if o_bool == d_bool { return true }
                        
        default:
            print("The type for the comparison in AuditRecord is not found.")
        }
        
        return false
    }
}
