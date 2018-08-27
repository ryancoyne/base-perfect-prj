//
//  RetailerContacts.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class RetailerContacts: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var user_id     : String? = nil
    var retailer_id : Int? = nil
    var contact_type_id : Int? = nil
    var email_address     : String? = nil
    var name     : String? = nil
    var phone_number     : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "retailer_contacts" }
    
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
        
        if let data = this.data.retailerContactsDic.userId {
            user_id = data
        }
        
        if let data = this.data.retailerContactsDic.retailerId {
            retailer_id = data
        }
        
        if let data = this.data.retailerContactsDic.name {
            name = data
        }
        
        if let data = this.data.retailerContactsDic.emailAddress {
            email_address = data
        }
        
        if let data = this.data.retailerContactsDic.phoneNumber {
            phone_number = data
        }
        
        if let data = this.data.retailerContactsDic.contactTypeId {
            contact_type_id = data
        }
        
    }
    
    func rows() -> [Retailer] {
        var rows = [Retailer]()
        for i in 0..<self.results.rows.count {
            let row = Retailer()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "user_id":
                if (value as? String).isNotNil {
                    self.user_id = (value as! String)
                }
                
            case "contact_type_id":
                if (value as? Int).isNotNil {
                    self.contact_type_id = (value as! Int)
                }
                
            case "name":
                if (value as? String).isNotNil {
                    self.name = (value as! String)
                }
                
            case "email_address":
                if (value as? String).isNotNil {
                    self.email_address = (value as! String)
                }
                
            case "phone_number":
                if (value as? String).isNotNil {
                    self.phone_number = (value as! String)
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
        
        if self.user_id.isNotNil {
            dictionary.retailerContactsDic.userId = self.user_id
        }
        
        if self.contact_type_id.isNotNil {
            dictionary.retailerContactsDic.contactTypeId = self.contact_type_id
        }
        
        if self.name.isNotNil {
            dictionary.retailerContactsDic.name = self.name
        }
        
        if self.email_address.isNotNil {
            dictionary.retailerContactsDic.emailAddress = self.email_address
        }
        
        if self.phone_number.isNotNil {
            dictionary.retailerContactsDic.phoneNumber = self.phone_number
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: RetailerContacts)-> Bool {
        
        var diff = true
        
        if diff == true, self.user_id != targetItem.user_id {
            diff = false
        }
        
        if diff == true, self.contact_type_id != targetItem.contact_type_id {
            diff = false
        }
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.email_address != targetItem.email_address {
            diff = false
        }
        
        if diff == true, self.phone_number != targetItem.phone_number {
            diff = false
        }
        
        return diff
        
    }
}
