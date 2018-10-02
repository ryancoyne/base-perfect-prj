//
//  Terminal.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Terminal: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var pos_id         : Int? = nil
    var retailer_id    : Int? = nil
    var serial_number  : String? = nil
    var address_id     : Int? = nil
    var name           : String? = nil
    var is_approved    : Bool = false
    var is_sample_only : Bool = false
    var terminal_key   : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "terminal" }
    
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
        
        if let data = this.data.terminalDic.posId {
            pos_id = data
        }
        
        if let data = this.data.terminalDic.retailerId {
            retailer_id = data
        }
        
        if let data = this.data.terminalDic.addressId {
            address_id = data
        }
        
        if let data = this.data.terminalDic.serialNumber {
            serial_number = data
        }
        
        if let data = this.data.terminalDic.name {
            name = data
        }
        
        if let data = this.data.terminalDic.isApproved {
            is_approved = data
        }

        if let data = this.data.terminalDic.isSampleOnly {
            is_sample_only = data
        }

        if let data = this.data.terminalDic.terminalKey {
            terminal_key = data
        }
        
    }
    
    func rows() -> [Terminal] {
        var rows = [Terminal]()
        for i in 0..<self.results.rows.count {
            let row = Terminal()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "pos_id":
                if (value as? Int).isNotNil {
                    self.pos_id = (value as! Int)
                }
                
            case "retailer_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "address_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "serial_number":
                if (value as? String).isNotNil {
                    self.serial_number = (value as! String)
                }
                
            case "terminal_key":
                if (value as? String).isNotNil {
                    self.terminal_key = (value as! String)
                }
                
            case "name":
                if (value as? String).isNotNil {
                    self.name = (value as! String)
                }
            
            case "is_approved":
                if (value as? Bool).isNotNil {
                    self.is_approved = value as? Bool ?? false
                }

            case "is_sample_only":
                if (value as? Bool).isNotNil {
                    self.is_sample_only = value as? Bool ?? false
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
        
        if self.pos_id.isNotNil {
            dictionary.terminalDic.posId = self.pos_id
        }
        
        if self.terminal_key.isNotNil {
            dictionary.terminalDic.terminalKey = self.terminal_key
        }
        
        if self.address_id.isNotNil {
            dictionary.terminalDic.addressId = self.address_id
        }
        
        if self.retailer_id.isNotNil {
            dictionary.terminalDic.retailerId = self.retailer_id
        }
        
        if self.serial_number.isNotNil {
            dictionary.terminalDic.serialNumber = self.serial_number
        }
        
        if self.name.isNotNil {
            dictionary.terminalDic.name = self.name
        }
        
        dictionary.terminalDic.isApproved = self.is_approved

        dictionary.terminalDic.isSampleOnly = self.is_sample_only

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: Terminal)-> Bool {
        
        var diff = true
        
        if diff == true, self.pos_id != targetItem.pos_id {
            diff = false
        }
        
        if diff == true, self.retailer_id != targetItem.retailer_id {
            diff = false
        }
        
        if diff == true, self.address_id != targetItem.address_id {
            diff = false
        }
        
        if diff == true, self.terminal_key != targetItem.terminal_key {
            diff = false
        }
        
        if diff == true, self.serial_number != targetItem.serial_number {
            diff = false
        }
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.is_approved != targetItem.is_approved {
            diff = false
        }

        if diff == true, self.is_sample_only != targetItem.is_sample_only {
            diff = false
        }

        return diff
        
    }
    
    public static func getTerminal(_ schema:Int, _ retailerId:Int, _ terminalSerial:String, _ terminalSecret:String)->Terminal? {

        let terminal = Terminal()
        
        let sql = "SELECT * FROM \(schema).terminal WHERE retailer_id = '\(retailerId)' AND serial_number = '\(terminalSerial)' AND terminal_key = '\(terminalSecret)'"
        let trm = try? terminal.sqlRows(sql, params: [])
        
        if trm.isNil, let term = trm!.first {
            terminal.fromDictionary(sourceDictionary: term.data)
            if terminal.id.isNotNil { return terminal }
        }
        
        
        return nil
        
    }
    
    public static func getFirst(_ schema : String) -> Terminal? {
        
        let term = Terminal()
        let sqlt = "SELECT * FROM \(schema).terminal"
        let trm = try? term.sqlRows(sqlt, params: [])
        if let t = trm?.first {
            term.to(t)
            return term
        } else {
        
            return nil
            
        }
        
    }

}
