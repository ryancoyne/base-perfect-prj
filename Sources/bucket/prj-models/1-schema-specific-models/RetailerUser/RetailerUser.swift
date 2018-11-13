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
    
    var retailer_id      : Int? = nil
    var user_custom_id   : String? = nil
    var account_id       : String? = nil
    var date_start       : Int? = nil
    var date_end         : Int? = nil
    var may_use_terminal : Bool = false

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
            retailer_id = data
        }
        
        if let data = this.data.retailerUserDic.userCustomId {
            user_custom_id = data
        }
        
        if let data = this.data.retailerUserDic.accountId {
            account_id = data
        }
        
        if let data = this.data.retailerUserDic.dateStart {
            date_start = data
        }
        
        if let data = this.data.retailerUserDic.dateEnd {
            date_end = data
        }
        
        if let data = this.data.retailerUserDic.mayUseTerminal {
            may_use_terminal = data
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
                    self.retailer_id = (value as! Int)
                }
                
            case "user_custom_id":
                if (value as? String).isNotNil {
                    self.user_custom_id = (value as! String)
                }
                
            case "account_id":
                if (value as? String).isNotNil {
                    self.account_id = (value as! String)
                }
                
            case "date_start":
                if (value as? Int).isNotNil {
                    self.date_start = (value as! Int)
                }
                
            case "date_end":
                if (value as? Int).isNotNil {
                    self.date_end = (value as! Int)
                }
                
            case "may_use_terminal":
                if (value as? Bool).isNotNil {
                    self.may_use_terminal = value as? Bool ?? false
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
        
        if self.retailer_id.isNotNil {
            dictionary.retailerUserDic.retailerId = self.retailer_id
        }

        if self.account_id.isNotNil {
            dictionary.retailerUserDic.accountId = self.account_id
        }
        
        if self.retailer_id.isNotNil {
            dictionary.retailerUserDic.userCustomId = self.user_custom_id
        }
        
        if self.retailer_id.isNotNil {
            dictionary.retailerUserDic.dateStart = self.date_start
        }
        
        if self.retailer_id.isNotNil {
            dictionary.retailerUserDic.dateEnd = self.date_end
        }

        dictionary.retailerUserDic.mayUseTerminal = self.may_use_terminal

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: RetailerUser)-> Bool {
        
        var diff = true
        
        if diff == true, self.retailer_id != targetItem.retailer_id {
            diff = false
        }
        
        if diff == true, self.user_custom_id != targetItem.user_custom_id {
            diff = false
        }
        
        if diff == true, self.account_id != targetItem.account_id {
            diff = false
        }
        
        if diff == true, self.date_start != targetItem.date_start {
            diff = false
        }
        
        if diff == true, self.date_end != targetItem.date_end {
            diff = false
        }
        
        if diff == true, self.may_use_terminal != targetItem.may_use_terminal {
            diff = false
        }
        
        return diff
        
    }
}
