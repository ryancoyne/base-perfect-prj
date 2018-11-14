//
//  TransactionTable.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PostgresStORM

final class CodeTransactionTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = CodeTransactionTable()
    let tbl = CodeTransaction()
    
    let tablelevel = 1.00
    
    //MARK:-
    //MARK: code transaction table
    func create() {
        
        for i in PRJCountries.list  {
            createCodeTransaction((i.uppercased()))
        }
    }

    //MARK:-
    //MARK: code transaction table
    private func createCodeTransaction(_ schemaIn:String? = "public") {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }

        
        // make sure the table level is correct
        let config = Config()
        
        // make sure the schema is there
        let _ = try? config.sqlRows(PRJDBTables.sharedInstance.addSchema("\(schema)"), params: [])
        
        var thesql = "SELECT val, name FROM config WHERE name = $1"
        var tr = try! config.sqlRows(thesql, params: ["\(schema).table_\(tbl.table())"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!, schema)
            }
        } else {
            
            let sequencesql = CCXDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table(), schema)
            
            // create the sequence
            let _ = try? tbl.sqlRows(sequencesql, params: [])
            
            let _ = try! tbl.sqlRows(self.table(schema), params: [])
            
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('\(schema).table_\(tbl.table())','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["\(schema).view_\(tbl.table())_deleted_yes"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!, schema)
            }
        } else {
            // add the deleted views
            let _ = try! tbl.sqlRows(CCXDBTables.sharedInstance.addDeletedViewsYes(tbl.table(), schema), params: [])
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('\(schema).view_\(tbl.table())_deleted_yes','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["\(schema).view_\(tbl.table())_deleted_no"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!, schema)
            }
        } else {
            let _ = try! tbl.sqlRows(CCXDBTables.sharedInstance.addDeletedViewsNo(tbl.table(), schema), params: [])
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('\(schema).view_\(tbl.table())_deleted_no','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }

        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["\(schema).view_\(tbl.table())_not_redeemed"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!, schema)
            }
        } else {
            let _ = try! tbl.sqlRows(PRJDBTables.sharedInstance.addCodeTransactionNotRedeemedView(tbl.table(), schema), params: [])
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('\(schema).view_\(tbl.table())_not_redeemed','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }

        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["\(schema).function_gettransactionreport"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!, schema)
            }
        } else {
            do {
                let _ = try tbl.sqlRows(PRJDBTables.sharedInstance.addTransactionReportFunction(schema), params: [])
                // new one - set the default 1.00
                thesql = "INSERT INTO config(name,val) VALUES('\(schema).function_gettransactionreport','1.00')"
                let _ = try config.sqlRows(thesql, params: [])
            } catch {
                // there could be an error if both tables are not there yet
            }
        }
    }
    
    private func update(currentlevel: Double, _ schemaIn:String? = "public") {
        
                var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }


        // PERFORM THE UPDATE ACCORFING TO REQUIREMENTS
        print("UPDATE \(schema).\(tbl.table().capitalized).  Current Level \(currentlevel), Required Level: \(tablelevel)")
        
    }
    
    private func table(_ schemaIn:String? = "public")-> String {
        
                var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }


        var createsql = "CREATE TABLE IF NOT EXISTS "
        createsql.append("\(schema).\(tbl.table()) ")
        
        // common
        createsql.append("( ")
        createsql.append("id integer NOT NULL DEFAULT nextval('\(schema).\(tbl.table())_id_seq'::regclass), ")
        
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
        createsql.append("description text COLLATE pg_catalog.default, ")
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
        createsql.append("processed int NOT NULL DEFAULT 0, ")
        createsql.append("processedby text COLLATE pg_catalog.default, ")
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
