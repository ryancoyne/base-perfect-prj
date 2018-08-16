//
//  Address.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class UserTotal: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var user_id    : String? = nil
    var country_id : Int? = nil
    var balance    : Double? = nil
    
    //MARK: Table name
    override public func table() -> String { return "user_total" }
    
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
        
        if let data = this.data.userTotalDic.userId {
           user_id  = data
        }

        if let data = this.data.userTotalDic.countryId {
            country_id  = data
        }

        if let data = this.data.userTotalDic.balance {
            balance = data
        }
        
    }
    
    func rows() -> [UserTotal] {
        var rows = [UserTotal]()
        for i in 0..<self.results.rows.count {
            let row = UserTotal()
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

            case "country_id":
                if (value as? Int).isNotNil {
                    self.country_id = (value as! Int)
                }

            case "balance":
                if (value as? Double).isNotNil {
                    self.balance = (value as! Double)
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
            dictionary.userTotalDic.userId = self.user_id
        }

        if self.country_id.isNotNil {
            dictionary.userTotalDic.countryId = self.country_id
        }

        if self.balance.isNotNil {
            dictionary.userTotalDic.balance = self.balance
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: UserTotal)-> Bool {
        
        var diff = true
        
        if diff == true, self.user_id != targetItem.user_id {
            diff = false
        }
        
        if diff == true, self.balance != targetItem.balance {
            diff = false
        }
        
        return diff
        
    }
}


