//
//  BadgeTable.swift
//

import Foundation
import PostgresStORM

final class NotificationTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = NotificationTable()
    let tbl = Notification()

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
                    // update to the new table
                    self.update(currentlevel: testval!)
                }
            } else {
            
                let sequencesql = RMDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table())
        
                do {
                    // create the sequence
                    try tbl.sqlRows(sequencesql, params: [])
                } catch {
                    print("Error in NotificationTable.create(): \(error)")
                }

                do {
                    try tbl.sqlRows(self.table(), params: [])
                } catch {
                    print("Error in NotificationTable.create(): \(error)")
                }

                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('table_\(tbl.table())','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in NotificationTable.create(): \(error)")
                }

            }
        }
    }

    private func update(currentlevel: Double) {
    
        // PERFORM THE UPDATE ACCORDING TO REQUIREMENTS
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
        createsql.append("devicetype text COLLATE pg_catalog.default, ")
        createsql.append("devicetoken text COLLATE pg_catalog.default, ")
        createsql.append("identifierforvendor text COLLATE pg_catalog.default, ")
        createsql.append("timezone text COLLATE pg_catalog.default, ")

        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}
