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

public class ClassStatus: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    
    var name      : String? = nil
    var description : String? = nil

    //MARK: Table name
    override public func table() -> String { return "class_status" }
    
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
        
        if let data = this.data.class_status.name {
            name = data
        }
        
        if let data = this.data.class_status.description {
            description = data
        }
        
    }
    
    func rows() -> [ClassStatus] {
        var rows = [ClassStatus]()
        for i in 0..<self.results.rows.count {
            let row = ClassStatus()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "name":
                if !(value as! String).isEmpty {
                    self.name = (value as! String)
                }

            case "description":
                if !(value as! String).isEmpty {
                    self.description = (value as! String)
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
        
        if self.name.isNotNil {
            dictionary.class_status.name = self.name
        }
        
        if self.description.isNotNil {
            dictionary.class_status.description = self.description
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: ClassStatus)-> Bool {
        
        var diff = true
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        return diff
        
    }
}

