//
//  TransactionHistoryTable.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PostgresStORM

final class CodeTransactionHistoryTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = CodeTransactionHistoryTable()
    let tbl = CodeTransactionHistory()
    
    let tablelevel = 1.00
    
    //MARK:-
    //MARK: code transaction history table
    func create() {
        
        for i in PRJCountries.list  {
            createCountries((i.uppercased()))
        }
    }
    
    private func createCountries(_ countryIn: String) {
        
        let country = countryIn.lowercased()
        
        let config = Config()

        // make sure the schema is there
        let _ = try? config.sqlRows(PRJDBTables.sharedInstance.addSchema("\(country)"), params: [])

        
        // make sure the table level is correct
        var thesql = "SELECT val, name FROM config WHERE name = $1"
        var tr = try! config.sqlRows(thesql, params: ["\(country).table_\(tbl.table())"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!)
            }
        } else {
            
            let sequencesql = CCXDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table(), country)
            
            // create the sequence
            let _ = try? tbl.sqlRows(sequencesql, params: [])
            
            let _ = try! tbl.sqlRows(self.table(country), params: [])
            
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('\(country).table_\(tbl.table())','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["\(country).view_\(tbl.table())_deleted_yes"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!, country)
            }
        } else {
            // add the deleted views
            let _ = try! tbl.sqlRows(CCXDBTables.sharedInstance.addDeletedViewsYes(tbl.table(), country), params: [])
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('\(country).view_\(tbl.table())_deleted_yes','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["\(country).view_\(tbl.table())_deleted_no"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!, country)
            }
        } else {
            let _ = try! tbl.sqlRows(CCXDBTables.sharedInstance.addDeletedViewsNo(tbl.table(), country), params: [])
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('\(country).view_\(tbl.table())_deleted_no','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
    }
    
    private func update(currentlevel: Double,_ schemaIn:String? = "public") {
        
        let schema = schemaIn?.lowercased()
        
        // PERFORM THE UPDATE ACCORFING TO REQUIREMENTS
        print("UPDATE \(schema!).\(tbl.table().capitalized).  Current Level \(currentlevel), Required Level: \(tablelevel)")
        
    }
    
    private func table(_ schemaIn:String? = "public")-> String {
        
        let schema = schemaIn!.lowercased()
        
        var createsql = "CREATE TABLE IF NOT EXISTS "
        createsql.append("\(schema).\(tbl.table()) ")
        
        // common
        createsql.append("( ")
        createsql.append("id integer NOT NULL DEFAULT 0 UNIQUE, ")
        
        createsql.append(CCXDBTables.sharedInstance.addCommonFields())
        
        // table specific fields
        createsql.append("country_id int NOT NULL DEFAULT 0, ")
        createsql.append("retailer_id int NOT NULL DEFAULT 0, ")
        createsql.append("amount numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("amount_available numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("total_amount numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("terminal_id int NOT NULL DEFAULT 0, ")
        createsql.append("batch_id text COLLATE pg_catalog.default, ")
        createsql.append("client_location text COLLATE pg_catalog.default, ")
        createsql.append("client_transaction_id text COLLATE pg_catalog.default, ")
        createsql.append("status text COLLATE pg_catalog.default, ")
        createsql.append("customer_code text COLLATE pg_catalog.default, ")
        createsql.append("deleted_reason text COLLATE pg_catalog.default, ")
        createsql.append("disputed_reason text COLLATE pg_catalog.default, ")
        createsql.append("customer_codeurl text COLLATE pg_catalog.default, ")
        createsql.append("disputed int NOT NULL DEFAULT 0, ")
        createsql.append("disputedby text COLLATE pg_catalog.default, ")
        createsql.append("redeemed int NOT NULL DEFAULT 0, ")
        createsql.append("redeemedby text COLLATE pg_catalog.default, ")
        createsql.append("archived int NOT NULL DEFAULT 0, ")
        createsql.append("archivedby text COLLATE pg_catalog.default, ")
        createsql.append("cashedout int NOT NULL DEFAULT 0, ")
        createsql.append("cashedoutby text COLLATE pg_catalog.default, ")
        createsql.append("cashedout_total numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("cashedout_note text COLLATE pg_catalog.default, ")

        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}
