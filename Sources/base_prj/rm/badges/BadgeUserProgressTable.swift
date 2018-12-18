//
//  BadgeTable.swift
//

import Foundation
import PostgresStORM

final class BadgeUserProgressTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = BadgeUserProgressTable()
    let tbl = BadgeUserProgress()

    let tablelevel = 1.00

    //MARK:-
    //MARK: badges table
    func create() {
    
        // make sure the table level is correct
        let config = RMConfig()
        var thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr1 = try? config.sqlRows(thesql, params: ["table_\(tbl.table())"])
        if tr1.isNotNil, let tr = tr1 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != tablelevel {
                    // update to the new installation
                    self.update(currentlevel: testval!)
                }
            } else {
            
                let sequencesql = RMDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table())
        
                // create the sequence
                do {
                    try tbl.sqlRows(sequencesql, params: [])
                } catch {
                    print("Error in BadgeUserProgressTable.create(): \(error)")
                }

                do {
                    try tbl.sqlRows(self.table(), params: [])
                } catch {
                    print("Error in BadgeUserProgressTable.create(): \(error)")
                }

                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('table_\(tbl.table())','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in BadgeUserProgressTable.create(): \(error)")
                }
            }
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
    
        createsql.append(RMDBTables.sharedInstance.addCommonFields())
    
        // table specific fields
        createsql.append("user_id text COLLATE pg_catalog.default, ")
        createsql.append("badge_id integer NOT NULL DEFAULT 0, ")
        createsql.append("badge_progress_added integer NOT NULL, ")
        createsql.append("badge_progress_note text COLLATE pg_catalog.default, ")

        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}
