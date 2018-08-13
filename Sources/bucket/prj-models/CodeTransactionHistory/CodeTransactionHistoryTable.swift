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
    //MARK: badges table
    func create() {
        
        // make sure the table level is correct
        let config = Config()
        var thesql = "SELECT val, name FROM config WHERE name = $1"
        var tr = try! config.sqlRows(thesql, params: ["table_\(tbl.table())"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!)
            }
        } else {
            
            let sequencesql = CCXDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table())
            
            // create the sequence
            let _ = try? tbl.sqlRows(sequencesql, params: [])
            
            let _ = try! tbl.sqlRows(self.table(), params: [])
            
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('table_\(tbl.table())','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["view_\(tbl.table())_deleted_yes"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!)
            }
        } else {
            // add the deleted views
            let _ = try! tbl.sqlRows(CCXDBTables.sharedInstance.addDeletedViewsYes(tbl.table()), params: [])
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('view_\(tbl.table())_deleted_yes','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["view_\(tbl.table())_deleted_no"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!)
            }
        } else {
            let _ = try! tbl.sqlRows(CCXDBTables.sharedInstance.addDeletedViewsNo(tbl.table()), params: [])
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('view_\(tbl.table())_deleted_no','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
    }
    
    private func update(currentlevel: Double) {
        
        // PERFORM THE UPDATE ACCORFING TO REQUIREMENTS
        print("UPDATE \(tbl.table().capitalized).  Current Level \(currentlevel), Required Level: \(tablelevel)")
        
    }
    
    private func table()-> String {
        
        var createsql = "CREATE TABLE IF NOT EXISTS "
        createsql.append("public.\(tbl.table()) ")
        
        // common
        createsql.append("( ")
        createsql.append("id integer NOT NULL DEFAULT nextval('\(tbl.table())_id_seq'::regclass), ")
        
        createsql.append(CCXDBTables.sharedInstance.addCommonFields())
        
        // table specific fields
        createsql.append("code_transaction_id int NOT NULL DEFAULT 0, ")
        createsql.append("country_id int NOT NULL DEFAULT 0, ")
        createsql.append("retailer_id int NOT NULL DEFAULT 0, ")
        createsql.append("amount numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("total_amount numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("terminal_id int NOT NULL DEFAULT 0, ")
        createsql.append("batch_id text COLLATE pg_catalog.default, ")
        createsql.append("client_location text COLLATE pg_catalog.default, ")
        createsql.append("client_transaction_id text COLLATE pg_catalog.default, ")
        createsql.append("customer_code text COLLATE pg_catalog.default, ")
        createsql.append("customer_codeURL text COLLATE pg_catalog.default, ")
        createsql.append("disputed int NOT NULL DEFAULT 0, ")
        createsql.append("disputedby text COLLATE pg_catalog.default, ")
        createsql.append("redeemed int NOT NULL DEFAULT 0, ")
        createsql.append("redeemedby text COLLATE pg_catalog.default, ")
        createsql.append("archived int NOT NULL DEFAULT 0, ")
        createsql.append("archivedby text COLLATE pg_catalog.default, ")

        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}
