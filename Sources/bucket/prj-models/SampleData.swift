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
        
        sqlstatement.append("(created, createdby, name, is_verified) ")
        sqlstatement.append(" VALUES ")
        sqlstatement.append(" (\(created_time), 'ADMIN_USER','Bucket Coffee Shop', TRUE), ")
        sqlstatement.append(" (\(created_time), 'ADMIN_USER','Ryans Bike Shop', TRUE), ")
        sqlstatement.append(" (\(created_time), 'ADMIN_USER','M&R Corner Market', TRUE) ")

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
        checkuser = "SELECT id FROM retailer WHERE contact_id = 0 LIMIT 1"
        var theid = try? tbl.sqlRows(checkuser, params: [])
        var retailerid = 0
        if theid.isNotNil, let usemeid = theid![0].data["id"].intValue , usemeid > 0 {
            retailerid = usemeid
        }

        // add the retailer user
        checkuser = "INSERT INTO retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), 'ADMIN_USER', '\(userid)', 'The Bucket','bucket1@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
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
        checkuser = "SELECT id FROM retailer WHERE contact_id = 0 LIMIT 1"
        theid = try? tbl.sqlRows(checkuser, params: [])
        retailerid = 0
        if theid.isNotNil, let usemeid = theid![0].data["id"].intValue , usemeid > 0 {
            retailerid = usemeid
        }

        // add the retailer user
        checkuser = "INSERT INTO retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), 'ADMIN_USER', '\(userid)', 'Ryan Coyne','bucket2@buckettechnologies.com','4102026292', \(retailerid)) RETURNING id ")
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
        checkuser = "SELECT id FROM retailer WHERE contact_id = 0 LIMIT 1"
        theid = try? tbl.sqlRows(checkuser, params: [])
        retailerid = 0
        if theid.isNotNil, let usemeid = theid![0].data["id"].intValue , usemeid > 0 {
            retailerid = usemeid
        }

        // add the retailer user
        checkuser = "INSERT INTO retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), 'ADMIN_USER', '\(userid)', 'Mike Silvers','bucket3@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
        results = try? tbl.sqlRows(checkuser, params: [])

    }

}
