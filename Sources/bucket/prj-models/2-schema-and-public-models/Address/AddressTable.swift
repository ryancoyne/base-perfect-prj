//
//  AddressTable.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PostgresStORM

final class AddressTable {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = AddressTable()
    let tbl = Address()
    
    let tablelevel = 1.00
    
    //MARK:-
    //MARK: address table
    func create() {
        
        for i in PRJCountries.list  {
            createAddress((i.uppercased()))
        }
        
        // here is the public schema creation
        createAddress()
    }

    //MARK:-
    //MARK: Addresses table
    private func createAddress(_ schemaId:String? = "public") {
        
        let schema = schemaId!.lowercased()
        
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
    
    private func update(currentlevel: Double, _ schemaId:String? = "public") {
        
        let schema = schemaId!.lowercased()
        
        // PERFORM THE UPDATE ACCORFING TO REQUIREMENTS
        print("UPDATE \(schema).\(tbl.table().capitalized).  Current Level \(currentlevel), Required Level: \(tablelevel)")
        
    }
    
    private func table(_ schemaId:String? = "public")-> String {
        
        let schema = schemaId!.lowercased()
        
        var createsql = "CREATE TABLE IF NOT EXISTS "
        createsql.append("\(schema).\(tbl.table()) ")
        
        // common
        createsql.append("( ")
        createsql.append("id integer NOT NULL DEFAULT nextval('\(schema).\(tbl.table())_id_seq'::regclass), ")
        
        createsql.append(CCXDBTables.sharedInstance.addCommonFields())
        
        // table specific fields
        createsql.append("country_id int NOT NULL DEFAULT 0, ")
        createsql.append("retailer_id int NOT NULL DEFAULT 0, ")
        createsql.append("retailer_contact_id int NOT NULL DEFAULT 0, ")
        createsql.append("address1 text COLLATE pg_catalog.default, ")
        createsql.append("address2 text COLLATE pg_catalog.default, ")
        createsql.append("address3 text COLLATE pg_catalog.default, ")
        createsql.append("state text COLLATE pg_catalog.default, ")
        createsql.append("postal_code text COLLATE pg_catalog.default, ")
        createsql.append("city text COLLATE pg_catalog.default, ")
        createsql.append("ach_transfer_minimum numeric(10,5) DEFAULT 0.0, ")
        createsql.append("geopoint geography(Point,4326), ")

        // ending fields
        createsql.append("CONSTRAINT \(tbl.table())_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}
