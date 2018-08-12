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
    
    func addRetailerData() {

        let tbl = Retailer()
        
        let created_time = Int(Date().timeIntervalSince1970)
        
        var sqlstatement = "INSERT INTO \(tbl.table()) "
        
        sqlstatement.append("(created, createdby, name, is_verified, retailer_code) ")
        sqlstatement.append(" VALUES ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.server_user)','Bucket Coffee Shop', TRUE, 'BCKT-1'), ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.server_user)','Ryans Bike Shop', TRUE, 'BCKT-2'), ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.server_user)','M&R Corner Market', TRUE, 'BCKT-3') ")

        print("Adding user: \(sqlstatement)")
        _ = try? tbl.sqlRows(sqlstatement, params: [])

    }
    
    func addRetailerUsers() {
        
        let tbl = Account()
        
        let created_time = Int(Date().timeIntervalSince1970)

        var userid = UUID().uuidString
        var checkuser = "INSERT INTO account "
        checkuser.append("(id,username,email,usertype,source, detail) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(userid)','bucketme1','bucket1@buckettechnologies.com','standard','local','{\"created\":\(created_time)}')")

        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

        // update the retailer with the new userid
        var retailerid = 1

        // add the retailer user
        checkuser = "INSERT INTO retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.server_user)', '\(userid)', 'The Bucket','bucket1@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
        var results = try? tbl.sqlRows(checkuser, params: [])

        // new one
        userid = UUID().uuidString
        checkuser = "INSERT INTO account "
        checkuser.append("(id,username,email,usertype,source, detail) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(userid)','bucketme2','bucket2@buckettechnologies.com','standard','local','{\"created\":\(created_time)}')")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

        // update the retailer with the new userid
        retailerid = 2

        // add the retailer user
        checkuser = "INSERT INTO retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.server_user)', '\(userid)', 'Ryan Coyne','bucket2@buckettechnologies.com','4102026292', \(retailerid)) RETURNING id ")
        results = try? tbl.sqlRows(checkuser, params: [])

        // new one
        userid = UUID().uuidString
        checkuser = "INSERT INTO account "
        checkuser.append("(id,username,email,usertype,source, detail) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(userid)','bucketme3','bucket3@buckettechnologies.com','standard','local','{\"created\":\(created_time)}')")

        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

        // update the retailer with the new userid
        retailerid = 3

        // add the retailer user
        checkuser = "INSERT INTO retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.server_user)', '\(userid)', 'Mike Silvers','bucket3@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
        results = try? tbl.sqlRows(checkuser, params: [])

    }
    

}
