//
//  RetailerEventTable.swift
//  bucket
//
//  Created by Ryan Coyne on 11/15/18.
//

import Foundation
import PostgresStORM

final class RetailerEventTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = RetailerEventTable()
    let tbl = RetailerEvent()
    
    let tablelevel = 1.00
    
    //MARK:-
    //MARK: retailer events table
    func create() {
        
        for i in PRJCountries.list  {
            createRetailerEvents((i.uppercased()))
        }
    }
    
    //MARK:-
    //MARK: retailer events by schema table
    private func createRetailerEvents(_ schemaIn:String? = "public") {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        let config = Config()
        
        // make sure the schema is there
        let _ = try? config.sqlRows(PRJDBTables.sharedInstance.addSchema("\(schema)"), params: [])
        
        // make sure the table level is correct
        var thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr1 = try? config.sqlRows(thesql, params: ["\(schema).table_\(tbl.table())"])
        if tr1.isNotNil, let tr = tr1 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != tablelevel {
                    // update to the new installation
                    self.update(currentlevel: testval!, schema)
                }
            } else {
                
                let sequencesql = CCXDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table(), schema)
                
                // create the sequence
                do {
                    try tbl.sqlRows(sequencesql, params: [])
                } catch {
                    print("Error createBatchDetail(): \(error)")
                }
                
                do {
                    try tbl.sqlRows(self.table(schema), params: [])
                } catch {
                    print("Error createBatchDetail(): \(error)")
                }
                
                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('\(schema).table_\(tbl.table())','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error createBatchDetail(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr2 = try? config.sqlRows(thesql, params: ["\(schema).view_\(tbl.table())_deleted_yes"])
        if tr2.isNotNil, let tr = tr2 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != tablelevel {
                    // update to the new installation
                    self.update(currentlevel: testval!, schema)
                }
            } else {
                // add the deleted views
                do {
                    try tbl.sqlRows(CCXDBTables.sharedInstance.addDeletedViewsYes(tbl.table(), schema), params: [])
                } catch {
                    print("Error createBatchDetail(): \(error)")
                }
                
                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('\(schema).view_\(tbl.table())_deleted_yes','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error createBatchDetail(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr3 = try? config.sqlRows(thesql, params: ["\(schema).view_\(tbl.table())_deleted_no"])
        if tr3.isNotNil, let tr = tr3 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != tablelevel {
                    // update to the new installation
                    self.update(currentlevel: testval!, schema)
                }
            } else {
                do {
                    try tbl.sqlRows(CCXDBTables.sharedInstance.addDeletedViewsNo(tbl.table(), schema), params: [])
                } catch {
                    print("Error createBatchDetail(): \(error)")
                }
                
                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('\(schema).view_\(tbl.table())_deleted_no','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error createBatchDetail(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr = try! config.sqlRows(thesql, params: ["\(schema).function_getretailerevents"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != tablelevel {
                // update to the new installation
                self.update(currentlevel: testval!, schema)
            }
        } else {
            do {
                let _ = try tbl.sqlRows(PRJDBTables.sharedInstance.addRetailerEventFunction(schema), params: [])
                // new one - set the default 1.00
                thesql = "INSERT INTO config(name,val) VALUES('\(schema).function_getretailerevents','1.00')"
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
        createsql.append("retailer_id int default 0, ")
        createsql.append("event_name text COLLATE pg_catalog.default, ")
        createsql.append("event_message text COLLATE pg_catalog.default, ")
        createsql.append("start_date int default 0, ")
        createsql.append("end_date int default 0, ")
        
        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}


