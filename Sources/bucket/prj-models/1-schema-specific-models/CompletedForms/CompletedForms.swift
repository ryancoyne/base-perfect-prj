//
//  CompletedForms.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class CompletedForms: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var form_id     : Int? = nil
    var option_id     : Int? = nil
    var user_id     : String? = nil
    var field_name     : String? = nil
    var field_value     : String? = nil
    var value_data_type     : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "completed_forms" }
    
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
        
        if let data = this.data.completedFormsDic.formId {
            form_id = data
        }
        
        if let data = this.data.completedFormsDic.optionId {
            option_id = data
        }
        
        if let data = this.data.completedFormsDic.userId {
            user_id = data
        }
        
        if let data = this.data.completedFormsDic.fieldValue {
            field_value = data
        }
        
        if let data = this.data.completedFormsDic.fieldName {
            field_name = data
        }
        
        if let data = this.data.completedFormsDic.valueDataType {
            value_data_type = data
        }
        
    }
    
    func rows() -> [CompletedForms] {
        var rows = [CompletedForms]()
        for i in 0..<self.results.rows.count {
            let row = CompletedForms()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "form_id":
                if (value as? Int).isNotNil {
                    self.form_id = (value as! Int)
                }
                
            case "option_id":
                if (value as? Int).isNotNil {
                    self.option_id = (value as! Int)
                }
                
            case "user_id":
                if (value as? String).isNotNil {
                    self.user_id = (value as! String)
                }
                
            case "field_value":
                if (value as? String).isNotNil {
                    self.field_value = (value as! String)
                }
                
            case "field_name":
                if (value as? String).isNotNil {
                    self.field_name = (value as! String)
                }
                
            case "value_data_type":
                if (value as? String).isNotNil {
                    self.value_data_type = (value as! String)
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
        
        if self.form_id.isNotNil {
            dictionary.completedFormsDic.formId = self.form_id
        }
        
        if self.option_id.isNotNil {
            dictionary.completedFormsDic.optionId = self.form_id
        }
        
        if self.user_id.isNotNil {
            dictionary.completedFormsDic.userId = self.user_id
        }
        
        if self.field_value.isNotNil {
            dictionary.completedFormsDic.fieldValue = self.field_value
        }
        
        if self.field_name.isNotNil {
            dictionary.completedFormsDic.fieldName = self.field_name
        }
        
        if self.value_data_type.isNotNil {
            dictionary.completedFormsDic.valueDataType = self.value_data_type
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: CompletedForms)-> Bool {
        
        var diff = true
        
        if diff == true, self.form_id != targetItem.form_id {
            diff = false
        }
        
        if diff == true, self.option_id != targetItem.option_id {
            diff = false
        }
        
        if diff == true, self.user_id != targetItem.user_id {
            diff = false
        }
        
        if diff == true, self.field_value != targetItem.field_value {
            diff = false
        }
        
        if diff == true, self.field_name != targetItem.field_name {
            diff = false
        }
        
        if diff == true, self.value_data_type != targetItem.value_data_type {
            diff = false
        }
        
        return diff
        
    }
}
