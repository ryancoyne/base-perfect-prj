//
//  Currency.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Currency: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var name     : String? = nil
    var country_id     : Int? = nil
    var code_numeric : String? = nil

    //MARK: Table name
    override public func table() -> String { return "currency" }
    
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
        
        if let data = this.data.currencyDic.name {
            name = data
        }
        
        if let data = this.data.currencyDic.codeNumeric {
            code_numeric = data
        }
        
        if let data = this.data.currencyDic.countryId {
            country_id = data
        }
        
    }
    
    func rows() -> [Currency] {
        var rows = [Currency]()
        for i in 0..<self.results.rows.count {
            let row = Currency()
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
                
            case "code_numeric":
                if !(value as! String).isEmpty {
                    self.code_numeric = (value as! String)
                }
                
            case "country_id":
                if (value as? Int).isNotNil {
                    self.country_id = (value as! Int)
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
            dictionary.countryDic.name = self.name
        }
        
        if self.country_id.isNotNil {
            dictionary.currencyDic.countryId = self.country_id
        }
        
        if self.code_numeric.isNotNil {
            dictionary.countryDic.codeNumeric = self.code_numeric
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: Currency)-> Bool {
        
        var diff = true
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.code_numeric != targetItem.code_numeric {
            diff = false
        }
        
        if diff == true, self.country_id != targetItem.country_id {
            diff = false
        }
    
        return diff
        
    }
}
