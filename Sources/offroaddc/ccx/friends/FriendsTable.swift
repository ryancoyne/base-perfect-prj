//
//  BadgeTable.swift
//

import Foundation
import PostgresStORM

final class FriendsTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }

    static let sharedInstance = FriendsTable()
    let tbl = Friends()

    let tablelevel = 1.00

    //MARK:-
    //MARK: create the table
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
            let _ = try! tbl.sqlRows(sequencesql, params: [])
            
            let _ = try! tbl.sqlRows(self.table(), params: [])
            
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('table_\(tbl.table())','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }
    }

    private func update(currentlevel: Double) {
    
        // PERFORM THE UPDATE ACCORFING TO REQUIREMENTS
        print("UPDATE \(tbl.table().capitalize()).  Current Level \(currentlevel), Required Level: \(tablelevel)")
    
    }

    private func table()-> String {
    
        var createsql = "CREATE TABLE IF NOT EXISTS "
        createsql.append("public.\(tbl.table()) ")
    
        // common
        createsql.append("( ")
        createsql.append("id integer NOT NULL DEFAULT nextval('\(tbl.table())_id_seq'::regclass), ")
    
        createsql.append(CCXDBTables.sharedInstance.addCommonFields())
    
        // table specific fields
        createsql.append("accepted integer NOT NULL DEFAULT 0, ")
        createsql.append("rejected integer NOT NULL DEFAULT 0, ")
        createsql.append("invited integer NOT NULL DEFAULT 0, ")
        createsql.append("user_id text COLLATE pg_catalog.default, ")
        createsql.append("friend_id text COLLATE pg_catalog.default, ")

        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}
