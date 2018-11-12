//
//  Terminal.swift
//  bucket
//
//  Created by Mike Silvers 11/12/18
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class RetailerUser: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var retailerId     : Int? = nil
    var userCustomId   : String? = nil
    var accountId      : String? = nil
    var dateStart      : Int? = nil
    var dateEnd        : Int? = nil
    var mayUseTerminal : Bool = false

    //MARK: Table name
    override public func table() -> String { return "retailer_user" }
    
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
        
        if let data = this.data.retailerUserDic.retailerId {
            retailerId = data
        }
        
        if let data = this.data.retailerUserDic.userCustomId {
            userCustomId = data
        }
        
        if let data = this.data.retailerUserDic.accountId {
            accountId = data
        }
        
        if let data = this.data.retailerUserDic.dateStart {
            dateStart = data
        }
        
        if let data = this.data.retailerUserDic.dateEnd {
            dateEnd = data
        }
        
        if let data = this.data.retailerUserDic.mayUseTerminal {
            mayUseTerminal = data
        }

    }
    
    func rows() -> [RetailerUser] {
        var rows = [RetailerUser]()
        for i in 0..<self.results.rows.count {
            let row = RetailerUser()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "retailer_id":
                if (value as? Int).isNotNil {
                    self.retailerId = (value as! Int)
                }
                
            case "user_custom_id":
                if (value as? String).isNotNil {
                    self.userCustomId = (value as! String)
                }
                
            case "account_id":
                if (value as? String).isNotNil {
                    self.accountId = (value as! String)
                }
                
            case "date_start":
                if (value as? Int).isNotNil {
                    self.dateStart = (value as! Int)
                }
                
            case "date_end":
                if (value as? Int).isNotNil {
                    self.dateEnd = (value as! Int)
                }
                
            case "may_use_terminal":
                if (value as? Bool).isNotNil {
                    self.mayUseTerminal = value as? Bool ?? false
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
        
        if self.retailerId.isNotNil {
            dictionary.retailerUserDic.retailerId = self.retailerId
        }
        
        dictionary.retailerUserDic.mayUseTerminal = self.mayUseTerminal

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: RetailerUser)-> Bool {
        
        var diff = true
        
        if diff == true, self.retailerId != targetItem.retailerId {
            diff = false
        }
        
        if diff == true, self.userCustomId != targetItem.userCustomId {
            diff = false
        }
        
        if diff == true, self.accountId != targetItem.accountId {
            diff = false
        }
        
        if diff == true, self.dateStart != targetItem.dateStart {
            diff = false
        }
        
        if diff == true, self.dateEnd != targetItem.dateEnd {
            diff = false
        }
        
        if diff == true, self.mayUseTerminal != targetItem.mayUseTerminal {
            diff = false
        }
        
        return diff
        
    }
}
