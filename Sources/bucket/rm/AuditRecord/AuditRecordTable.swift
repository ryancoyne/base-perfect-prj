//
//  LedgerTable.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PostgresStORM

final class AuditRecordTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = AuditRecordTable()
    let tbl = AuditRecord()
    
    let tablelevel = 1.00
    
    //MARK:-
    //MARK: badges table
    func create() {
        
        let config = RMConfig()
        
        // make sure the schema exists
        let _ = try? config.sqlRows(PRJDBTables.sharedInstance.addSchema("\(tbl.schema())"), params: [])

        // make sure the table level is correct
        var thesql = "SELECT val, name FROM config WHERE name = $1"
        var tr = try! config.sqlRows(thesql, params: ["table_\(tbl.schema())_\(tbl.table())"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!)
            }
        } else {
            
            let sequencesql = RMDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table(), tbl.schema())
            
            // create the sequence
            let _ = try? tbl.sqlRows(sequencesql, params: [])
            
            let _ = try! tbl.sqlRows(self.table(), params: [])
            
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('table_\(tbl.schema())_\(tbl.table())','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["view_\(tbl.schema())_\(tbl.table())_deleted_yes"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!)
            }
        } else {
            // add the deleted views
            let _ = try! tbl.sqlRows(RMDBTables.sharedInstance.addDeletedViewsYes(tbl.table(), tbl.schema()), params: [])
            
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('view_\(tbl.schema())_\(tbl.table())_deleted_yes','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        tr = try! config.sqlRows(thesql, params: ["view_\(tbl.schema())_\(tbl.table())_deleted_no"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!)
            }
        } else {
            let _ = try! tbl.sqlRows(RMDBTables.sharedInstance.addDeletedViewsNo(tbl.table(), tbl.schema()), params: [])
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('view_\(tbl.schema())_\(tbl.table())_deleted_no','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
        
    }
    
    private func update(currentlevel: Double) {
        
        // PERFORM THE UPDATE ACCORFING TO REQUIREMENTS
        print("UPDATE \(tbl.table().capitalized).  Current Level \(currentlevel), Required Level: \(tablelevel)")
        
    }
    
    private func table()-> String {
        
        var createsql = "CREATE TABLE IF NOT EXISTS "
        createsql.append("\(tbl.schema()).\(tbl.table()) ")
        
        // common
        createsql.append("( ")
        createsql.append("id integer NOT NULL DEFAULT nextval('\(tbl.schema()).\(tbl.table())_id_seq'::regclass), ")
        
        createsql.append(RMDBTables.sharedInstance.addCommonFields())
        
        // table specific fields
        createsql.append("session_id text COLLATE pg_catalog.default, ")
        createsql.append("audit_group text COLLATE pg_catalog.default, ")
        createsql.append("audit_action text COLLATE pg_catalog.default, ")
        createsql.append("description text COLLATE pg_catalog.default, ")
        createsql.append("row_data jsonb, ")
        createsql.append("changed_fields jsonb, ")
        
        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}
