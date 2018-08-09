//
//  FormField.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class FormField: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var name     : String? = nil
    var length     : Int? = nil
    var type_id     : Int? = nil
    var is_required     : Bool? = nil
    var needs_confirmation     : Bool? = nil
    
    //MARK: Table name
    override public func table() -> String { return "form_field" }
    
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
        
        if let data = this.data.formFieldDic.name {
            name = data
        }
        
        if let data = this.data.formFieldDic.length {
            length = data
        }
        
        if let data = this.data.formFieldDic.typeId {
            type_id = data
        }
        
        if let data = this.data.formFieldDic.needsConfirmation {
            needs_confirmation = data
        }
        
        if let data = this.data.formFieldDic.isRequired {
            is_required = data
        }
        
    }
    
    func rows() -> [FormField] {
        var rows = [FormField]()
        for i in 0..<self.results.rows.count {
            let row = FormField()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "name":
                if (value as? String).isNotNil {
                    self.name = (value as! String)
                }
                
            case "length":
                if (value as? Int).isNotNil {
                    self.length = (value as! Int)
                }
                
            case "type_id":
                if (value as? Int).isNotNil {
                    self.type_id = (value as! Int)
                }
                
            case "needs_confirmation":
                if (value as? Bool).isNotNil {
                    self.needs_confirmation = (value as! Bool)
                }
                
            case "is_required":
                if (value as? Bool).isNotNil {
                    self.is_required = (value as! Bool)
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
        
        if self.name.isNotNil {
            dictionary.formDic.name = self.name
        }
        
        if self.length.isNotNil {
            dictionary.formFieldDic.length = self.length
        }
        
        if self.type_id.isNotNil {
            dictionary.formFieldDic.typeId = self.type_id
        }
        
        if self.is_required.isNotNil {
            dictionary.formFieldDic.isRequired = self.is_required
        }
        
        if self.needs_confirmation.isNotNil {
            dictionary.formFieldDic.needsConfirmation = self.needs_confirmation
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: FormField)-> Bool {
        
        var diff = true
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.type_id != targetItem.type_id {
            diff = false
        }
        
        if diff == true, self.needs_confirmation != targetItem.needs_confirmation {
            diff = false
        }
        
        if diff == true, self.is_required != targetItem.is_required {
            diff = false
        }
        
        if diff == true, self.length != targetItem.length {
            diff = false
        }
        
        return diff
        
    }
}
