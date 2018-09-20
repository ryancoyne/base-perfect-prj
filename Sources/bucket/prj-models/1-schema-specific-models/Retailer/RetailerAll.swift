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
    var terminals_unassigned:[Terminal]? = nil

    //MARK: Table name
//    override public func table() -> String { return "" }
    
    // perform the function to do the SQL and get the options
    func get(_ schema: String, _ retailer_id:Int) {
        
        // get the information for this retailer
        let sql_retailer = "SELECT * FROM \(schema).retailer WHERE id = \(retailer_id)"
        let ret_storm = try? self.sqlRows(sql_retailer, params: [])
        if ret_storm.isNotNil {
            self.to(ret_storm!.first!)
        } else {
            // we can not proceed without a retailer
            return
        }
        
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
        if terminals_unassigned.isNil { self.terminals_unassigned = [] }
        if self.terminals.isNotNil {
            for i in self.terminals! {
                if i.address_id.isNil || i.address_id == 0 {
                    // process the terminal without an address assigned
                    terminals_unassigned?.append(i)
                } else {
                    // process the terminal for the address
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

}
