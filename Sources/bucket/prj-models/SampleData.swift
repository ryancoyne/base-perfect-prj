//
//  SampleData.swift
//  bucket
//
//  Created by Mike Silvers on 8/8/18.
//

import Foundation
import PostgresStORM
import PerfectLocalAuthentication

final class SampleData {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let createdby  = "AUTO_CREATED_USER"
    static let modifiedby = "AUTO_MODIFIED_USER"
    static let deletedby  = "AUTO_DELETED_USER"

    static let sharedInstance = SampleData()
    
    func addUserData() {
        let tbl = Account()
        
        let createdtime = Int(Date().timeIntervalSince1970)
        
        var checkuser = "SELECT id FROM account WHERE id = 'AUTO_CREATED_USER'; "
        var tr = try? tbl.sqlRows(checkuser, params: [])
        if let thecount = tr?.count, thecount == 0 {
            // it does not exist - add it
            checkuser = "INSERT INTO account "
            checkuser.append("(id,username,email,usertype, source, detail) VALUES(" )
            checkuser.append("'AUTO_CREATED_USER',")
            checkuser.append("'AUTO_CREATED_USER',")
            checkuser.append("'testing@buckettechnologies.com',")
            checkuser.append("'standard',")
            checkuser.append("'local',")
            checkuser.append("'{\"created\":\(createdtime)}')")
            print("Adding user: \(checkuser)")
            _ = try? tbl.sqlRows(checkuser, params: [])
        }
        
        checkuser = "SELECT id FROM account WHERE id = 'AUTO_MODIFIED_USER'; "
        tr = try? tbl.sqlRows(checkuser, params: [])
        if let thecount = tr?.count, thecount == 0 {
            // it does not exist - add it
            checkuser = "INSERT INTO account "
            checkuser.append("(id,username,email,usertype, source, detail) VALUES(" )
            checkuser.append("'AUTO_MODIFIED_USER',")
            checkuser.append("'AUTO_MODIFIED_USER',")
            checkuser.append("'testing@buckettechnologies.com',")
            checkuser.append("'standard',")
            checkuser.append("'local',")
            checkuser.append("'{\"created\":\(createdtime)}')")
            print("Adding user: \(checkuser)")
            _ = try? tbl.sqlRows(checkuser, params: [])
        }

        checkuser = "SELECT id FROM account WHERE id = 'AUTO_DELETED_USER'; "
        tr = try? tbl.sqlRows(checkuser, params: [])
        if let thecount = tr?.count, thecount == 0 {
            // it does not exist - add it
            checkuser = "INSERT INTO account "
            checkuser.append("(id,username,email,usertype,source, detail) VALUES(" )
            checkuser.append("'AUTO_DELETED_USER',")
            checkuser.append("'AUTO_DELETED_USER',")
            checkuser.append("'testing@buckettechnologies.com',")
            checkuser.append("'standard',")
            checkuser.append("'local',")
            checkuser.append("'{\"created\":\(createdtime)}')")
            print("Adding user: \(checkuser)")
            _ = try? tbl.sqlRows(checkuser, params: [])
        }

    }
    
    func addAddressData() {
        let tbl = Address()
        
        
    }

}
