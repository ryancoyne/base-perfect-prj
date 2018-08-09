//
//  Retailer.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Retailer: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var contact_id     : Int? = nil
    var retailer_code : String? = nil
    var name     : String? = nil
    var is_suspended     : Bool? = nil
    var is_verified     : Bool? = nil
    var send_settlement_confirmation     : Bool? = nil
    
    //MARK: Table name
    override public func table() -> String { return "retailer" }
    
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
        
        if let data = this.data.retailerDic.contactId {
            contact_id = data
        }
        
        if let data = this.data.retailerDic.name {
            name = data
        }
        
        if let data = this.data.retailerDic.retailerCode {
            retailer_code = data
        }
        
        if let data = this.data.retailerDic.isVerified {
            is_verified = data
        }
        
        if let data = this.data.retailerDic.isSuspended {
            is_suspended = data
        }
    
        if let data = this.data.retailerDic.sendSettlementConfirmation {
            send_settlement_confirmation = data
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
                
            case "country_id":
                if (value as? Int).isNotNil {
                    self.contact_id = (value as! Int)
                }
                
            case "name":
                if (value as? String).isNotNil {
                    self.name = (value as! String)
                }
                
            case "retailer_code":
                if (value as? String).isNotNil {
                    self.retailer_code = (value as! String)
                }
                
            case "is_suspended":
                if (value as? Bool).isNotNil {
                    self.is_suspended = (value as! Bool)
                }
                
            case "is_approved":
                if (value as? Bool).isNotNil {
                    self.is_verified = (value as! Bool)
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
        
        if self.name.isNotNil {
            dictionary.retailerDic.name = self.name
        }
        
        if self.retailer_code.isNotNil {
            dictionary.retailerDic.retailerCode = self.retailer_code
        }
        
        if self.is_suspended.isNotNil {
            dictionary.retailerDic.isSuspended = self.is_suspended
        }
        
        if self.is_verified.isNotNil {
            dictionary.retailerDic.isVerified = self.is_verified
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: Retailer)-> Bool {
        
        var diff = true
        
        if diff == true, self.contact_id != targetItem.contact_id {
            diff = false
        }
        
        if diff == true, self.retailer_code != targetItem.retailer_code {
            diff = false
        }
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.is_verified != targetItem.is_verified {
            diff = false
        }
        
        if diff == true, self.is_suspended != targetItem.is_suspended {
            diff = false
        }
        
        if diff == true, self.send_settlement_confirmation != targetItem.send_settlement_confirmation {
            diff = false
        }
        
        return diff
        
    }
}
