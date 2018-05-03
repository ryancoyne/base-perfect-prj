//
//  Installation.swift
//  findapride
//
//  Created by Mike Silvers on 7/2/17.
//
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class ClassRegistration: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    
    var user_id         : String? = nil
    var class_date_id   : Int? = nil
    var registered      : Int? = nil
    var registered_by   : String? = nil
    var wait_list_order : Int? = nil

    //MARK: Table name
    override public func table() -> String { return "class_registration" }
    
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
        
        if let data = this.data.createdBy {
            createdby = data
        }
        
        if let data = this.data.modifiedBy {
            modifiedby = data
        }
        
        if let data = this.data.class_registration.user_id {
            user_id = data
        }
        
        if let data = this.data.class_registration.class_date_id {
            class_date_id = data
        }
        
        if let data = this.data.class_registration.registered {
            registered = data
        }
        
        if let data = this.data.class_registration.registered_by {
            registered_by = data
        }
        
        if let data = this.data.class_registration.wait_list_order {
            wait_list_order = data
        }
        
    }
    
    func rows() -> [ClassRegistration] {
        var rows = [ClassRegistration]()
        for i in 0..<self.results.rows.count {
            let row = ClassRegistration()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "user_id":
                if !(value as! String).isEmpty {
                    self.user_id = (value as! String)
                }

            case "class_date_id":
                if  let v = (value as Int) {
                    self.class_date_id = v
                }

            case "registered":
                if  let v = (value as Int) {
                    self.registered = v
                }

            case "registered_by":
                if !(value as! String).isEmpty {
                    self.user_id = (value as! String)
                }

            case "wait_list_order":
                if  let v = (value as Int) {
                    self.wait_list_order = v
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
        
        if self.user_id.isNotNil {
            dictionary.class_registration.user_id = self.user_id
        }
        
        if self.class_date_id.isNotNil {
            dictionary.class_registration.class_date_id = self.class_date_id
        }

        if self.registered.isNotNil {
            dictionary.class_registration.registered = self.registered
        }

        if self.registered_by.isNotNil {
            dictionary.class_registration.registered_by = self.registered_by
        }

        if self.wait_list_order.isNotNil {
            dictionary.class_registration.wait_list_order = self.wait_list_order
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: ClassRegistration)-> Bool {
        
        var diff = true
        
        if diff == true, self.user_id != targetItem.user_id {
            diff = false
        }
        
        if diff == true, self.class_date_id != targetItem.class_date_id {
            diff = false
        }
        
        if diff == true, self.registered != targetItem.registered {
            diff = false
        }
        
        if diff == true, self.registered_by != targetItem.registered_by {
            diff = false
        }
        
        if diff == true, self.wait_list_order != targetItem.wait_list_order {
            diff = false
        }
        
        return diff
        
    }
}

