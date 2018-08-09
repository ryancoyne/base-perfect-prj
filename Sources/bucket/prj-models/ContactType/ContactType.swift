//
//  ContactType.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class ContactType: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var contact_id     : Int? = nil
    var description     : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "contact_type" }
    
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
        
        if let data = this.data.contactsDic.contactId {
            contact_id = data
        }
        
        if let data = this.data.shortdescription {
            description = data
        }
        
    }
    
    func rows() -> [ContactType] {
        var rows = [ContactType]()
        for i in 0..<self.results.rows.count {
            let row = ContactType()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "contact_id":
                if (value as? Int).isNotNil {
                    self.contact_id = (value as! Int)
                }
                
            case "description":
                if (value as? String).isNotNil {
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
        
        if self.deleted.isNotNil {
            dictionary.deleted = self.deleted
        }
        
        if self.deletedby.isNotNil {
            dictionary.deletedBy = self.deletedby
        }
        
        if self.contact_id.isNotNil {
            dictionary.retailerDic.contactId = self.contact_id
        }
        
        if self.contact_id.isNotNil {
            dictionary.contactsDic.contactId = self.contact_id
        }
        
        if self.description.isNotNil {
            dictionary.shortdescription = self.description
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: ContactType)-> Bool {
        
        var diff = true
        
        if diff == true, self.contact_id != targetItem.contact_id {
            diff = false
        }
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }
            
        return diff
        
    }
}
