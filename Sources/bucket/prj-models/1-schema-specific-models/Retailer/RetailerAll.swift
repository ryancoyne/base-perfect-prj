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

public class RetailerAll: Retailer {
    
    var addresses:[Address]? = nil
    var terminals:[Terminal]? = nil
    var terminals_per_address:[Int:[Terminal]]? = nil
    
    //MARK: Table name
//    override public func table() -> String { return "" }
    
    // perform the function to do the SQL and get the options
    func get(_ schema: String, _ retailer_id:Int) {
        
        // fill the addresses
        let sql_address = "SELECT * FROM \(schema.lowercased()).address WHERE retailer_id = \(retailer_id)"
        let add_storm = try? self.sqlRows(sql_address, params: [])
        if self.addresses.isNil { self.addresses = [] }
        if add_storm.isNotNil {
            for i in add_storm! {
                let add = Address()
                add.to(i)
                addresses!.append(add)
            }
        }
        
        // fill the terminals
        let sql_terminals = "SELECT * FROM \(schema.lowercased()).terminal WHERE retailer_id = \(retailer_id)"
        let term_storm = try? self.sqlRows(sql_terminals, params: [])
        if self.terminals.isNil { self.terminals = [] }
        if term_storm.isNotNil {
            for i in term_storm! {
                let term = Terminal()
                term.to(i)
                terminals!.append(term)
            }
        }
        
        // fill the terminals per address - key is the id of the address
        if terminals_per_address.isNil { self.terminals_per_address = [:] }
        if self.terminals.isNotNil {
            for i in self.terminals! {
                if let ts = terminals_per_address![i.address_id!] {
                    var newts = ts
                    newts.append(i)
                    terminals_per_address![i.address_id!] = newts
                } else {
                    terminals_per_address![i.address_id!] = [i]
                }
            }
        }

    }
    
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
        
        if let data = this.data.retailerDic.ach_transfer_minimum_default {
            ach_transfer_minimum_default = data
        }
        
        
    }
    
    func rows() -> [RetailerAll] {
        var rows = [RetailerAll]()
        for i in 0..<self.results.rows.count {
            let row = RetailerAll()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    override func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
            
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

            case "ach_transfer_minimum_default":
                if (value as? Decimal).isNotNil {
                    self.ach_transfer_minimum_default = (value as! Double)
                }
                
            default:
                print("This should not occur")
            }
            
        }
        
    }
    
    
    override func asDictionary() -> [String: Any] {
        
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
        
        if self.ach_transfer_minimum_default.isNotNil {
            dictionary.retailerDic.ach_transfer_minimum_default = self.ach_transfer_minimum_default
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    override func compare(targetItem: Retailer)-> Bool {
        
        var diff = true
        
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

        if diff == true, self.ach_transfer_minimum_default != targetItem.ach_transfer_minimum_default {
            diff = false
        }

        return diff
        
    }
}
