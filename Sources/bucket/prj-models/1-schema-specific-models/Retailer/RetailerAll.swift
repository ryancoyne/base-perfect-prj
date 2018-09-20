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
}
