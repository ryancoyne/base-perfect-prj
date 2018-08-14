//
//  LedgerAccount.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class LedgerAccount: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var ledger_account_type_id : Int? = nil
    var title                  : String? = nil
    var description            : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "ledger_account" }
    
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
        
        
        if let data = this.data.ledgerAccountDict.ledger_account_type_id {
            ledger_account_type_id = data
        }
        
        if let data = this.data.ledgerAccountDict.title {
            title = data
        }
        
        if let data = this.data.ledgerAccountDict.description {
            description = data
        }
        
    }
    
    func rows() -> [LedgerAccount] {
        var rows = [LedgerAccount]()
        for i in 0..<self.results.rows.count {
            let row = LedgerAccount()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "ledger_account_type_id":
                if (value as? Int).isNotNil {
                    self.ledger_account_type_id = (value as! Int)
                }
            
            case "title":
                if (value as? String).isNotNil {
                    self.title = (value as! String)
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
        
        if self.ledger_account_type_id.isNotNil {
            dictionary.ledgerAccountDict.ledger_account_type_id = self.ledger_account_type_id
        }
        
        if self.title.isNotNil {
            dictionary.ledgerAccountDict.title = self.title
        }
        
        if self.description.isNotNil {
            dictionary.ledgerAccountDict.description = self.description
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: LedgerAccount)-> Bool {
        
        var diff = true
        
        if diff == true, self.ledger_account_type_id != targetItem.ledger_account_type_id {
            diff = false
        }
        
        if diff == true, self.title != targetItem.title {
            diff = false
        }
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        return diff
        
    }
}
