//
//  CashoutOptionTable.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PostgresStORM

final class CashoutOptionTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = CashoutOptionTable()
    let tbl = CashoutOption()
    
    let tablelevel = 1.00
    
    //MARK:-
    //MARK: Cashout Option table
    func create() {
        
        for i in PRJCountries.list  {
            createCashoutOption((i.uppercased()))
        }
    }

    //MARK:-
    //MARK: cashout option table
    private func createCashoutOption(_ schemaIn:String? = "public") {
        
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
        createsql.append("cashout_source_id int NOT NULL DEFAULT 0, ")
        createsql.append("group_id int NOT NULL DEFAULT 0, ")
        createsql.append("maximum numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("minimum numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("increment numeric(10,5) NOT NULL DEFAULT 0, ")
        createsql.append("form_id int NOT NULL DEFAULT 0, ")
        createsql.append("name text COLLATE pg_catalog.default, ")
        createsql.append("picture_url text COLLATE pg_catalog.default, ")
        createsql.append("sm_picture_url text COLLATE pg_catalog.default, ")
        createsql.append("icon_url text COLLATE pg_catalog.default, ")
        createsql.append("website text COLLATE pg_catalog.default, ")
        createsql.append("description text COLLATE pg_catalog.default, ")
        createsql.append("long_description text COLLATE pg_catalog.default, ")
        createsql.append("display_order int NOT NULL DEFAULT 0, ")
        createsql.append("display bool NOT NULL DEFAULT false, ")

        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}
