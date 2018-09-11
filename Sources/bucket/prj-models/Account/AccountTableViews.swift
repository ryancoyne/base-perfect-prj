//
//  CustomViews.swift
//  bucket
//
//  Created by Mike Silvers on 9/10/18.
//

import Foundation
import PostgresStORM
import PerfectLocalAuthentication

final class AccountTableViews {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = AccountTableViews()
    let tbl = Account()
    
    let retailerView1 = 1.00
    
    //MARK:-
    //MARK: account views
    func create() {
        
        // make sure the table level is correct
        let config = Config()
        var thesql = "SELECT val, name FROM config WHERE name = $1"
        var tr = try! config.sqlRows(thesql, params: ["view_retailer_\(tbl.table())_1"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != retailerView1 {
                // update to the new installation
                self.updateRetailerAccountView1(currentlevel: retailerView1)
            }
        } else {
            
            // create the view
            let _ = try? tbl.sqlRows(self.view_retailer_account_1(), params: [])
            
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('view_retailer_\(tbl.table())_1','1.00')"
            let _ = try! config.sqlRows(thesql, params: [])
        }

        //MARK: --
        //MARK: Add next one here ;)
        
    }
    
    private func updateRetailerAccountView1(currentlevel: Double) {
        
        // PERFORM THE UPDATE ACCORFING TO REQUIREMENTS
        print("UPDATE \(tbl.table().capitalized).  Current Level \(currentlevel), Required Level: \(retailerView1)")
        
    }
    
    private func view_retailer_account_1()-> String {
        
        var createsql = "CREATE OR REPLACE VIEW public.retailer_accounts AS "
        createsql.append("SELECT *, ")
        createsql.append("CAST (detail->'retailer'->'country'->>'id' AS INTEGER) AS country_id, ")
        createsql.append("CAST (detail->'retailer'->'country'->>'retailers' AS INTEGER[]) AS retailer_ids ")
        createsql.append("FROM public.account ")
        createsql.append("WHERE detail->'retailer' NOTNULL ")
        createsql.append("ORDER BY detail -> 'retailer' -> 'country' ")
        
        print(createsql)
        
        return createsql
    }
}
