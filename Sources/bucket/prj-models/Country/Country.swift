//
//  Country.swift
//  COpenSSL
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Country: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var name     : String? = nil
    var local_name     : String? = nil
    var code_numeric : Int? = nil
    var code_alpha_3  : String? = nil
    var code_alpha_2 : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "country" }
    
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
        
        if let data = this.data.countryDic.name {
            name = data
        }

        if let data = this.data.countryDic.localName {
            local_name = data
        }
        
        if let data = this.data.countryDic.codeNumeric {
            code_numeric = data
        }
        
        if let data = this.data.countryDic.codeAlpha2 {
            code_alpha_2 = data
        }
        
        if let data = this.data.countryDic.codeAlpha3 {
            code_alpha_3 = data
        }
        
    }
    
    func rows() -> [Country] {
        var rows = [Country]()
        for i in 0..<self.results.rows.count {
            let row = Country()
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
                
            case "local_name":
                if !(value as! String).isEmpty {
                    self.local_name = (value as! String)
                }
                
            case "code_alpha_2":
                if !(value as! String).isEmpty {
                    self.code_alpha_2 = (value as! String)
                }
                
            case "code_numeric":
                if (value as? Int).isNotNil {
                    self.code_numeric = (value as! Int)
                }
                
            case "code_alpha_3":
                if !(value as! String).isEmpty {
                    self.code_alpha_3 = (value as! String)
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
        
        if self.name.isNotNil {
            dictionary.countryDic.name = self.name
        }
        
        if self.local_name.isNotNil {
            dictionary.countryDic.localName = self.local_name
        }
        
        if self.code_numeric.isNotNil {
            dictionary.countryDic.codeNumeric = self.code_numeric
        }
        
        if self.code_alpha_2.isNotNil {
            dictionary.countryDic.codeAlpha2 = self.code_alpha_2
        }
        
        if self.code_alpha_3.isNotNil {
            dictionary.countryDic.codeAlpha3 = self.code_alpha_3
        }
    
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: Country)-> Bool {
        
        var diff = true
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.local_name != targetItem.local_name {
            diff = false
        }
        
        if diff == true, self.code_alpha_2 != targetItem.code_alpha_2 {
            diff = false
        }
        
        if diff == true, self.code_alpha_3 != targetItem.code_alpha_3 {
            diff = false
        }
        
        if diff == true, self.code_numeric != targetItem.code_numeric {
            diff = false
        }

        return diff
        
    }
}
