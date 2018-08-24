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
    
    func addCashoutSource() {
        let tbl = CashoutSource()

        let created_time = CCXServiceClass.sharedInstance.getNow()

        var sqlstatement = "INSERT INTO \(tbl.table()) "
        
        sqlstatement.append("(created, createdby, name, description) ")
        sqlstatement.append(" VALUES ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','OmniCard', 'Closed Loop Cards'), ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','Open Loop', 'Open Loop Provider'), ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','Donations', 'Donations provider') ")
        
        print("Adding cashout sources: \(sqlstatement)")
        let _ = try? tbl.sqlRows(sqlstatement, params: [])

        
    }
    
    
    func addUserData() {
        let tbl = Account()
        
        let createdtime = CCXServiceClass.sharedInstance.getNow()
        
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
        
        let created_time = CCXServiceClass.sharedInstance.getNow()
        
        var sqlstatement = "INSERT INTO \(tbl.table()) "
        
        sqlstatement.append("(created, createdby, name, is_verified, retailer_code) ")
        sqlstatement.append(" VALUES ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','Bucket Coffee Shop', TRUE, 'BCKT-1'), ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','Ryans Bike Shop', TRUE, 'BCKT-2'), ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','M&R Corner Market', TRUE, 'BCKT-3') ")

        print("Adding retailers: \(sqlstatement)")
        let _ = try? tbl.sqlRows(sqlstatement, params: [])
        
        // add the addresses for the office locations
        let usa = Country()
        try? usa.find(["code_alpha_2":"US"])

        let singapore = Country()
        try? singapore.find(["code_alpha_2":"SG"])

        let retrows = try? tbl.sqlRows("SELECT * FROM retailer", params: [])
        var ctr = 0
        for i in retrows! {
            
            let a = Address()
            
            switch ctr {
            
            case 0:
                a.retailer_id = i.data.id
                a.address1 = "1343 Florida Ave NW"
                a.country_id = usa.id
                a.city = "Washington"
                a.state = "DC"
                a.postal_code = "20009"
                let _ = try? a.saveWithCustomType()
                
            case 1:
                a.retailer_id = i.data.id
                a.address1 = "2400 14th St NW"
                a.country_id = usa.id
                a.city = "Washington"
                a.state = "DC"
                a.postal_code = "20009"
                let _ = try? a.saveWithCustomType()

            case 2:
                a.retailer_id = i.data.id
                a.address1 = "4 Everton Park"
                a.address2 = "#01-40"
                a.country_id = singapore.id
                a.state = "Singapore"
                a.postal_code = "080004"
                let _ = try? a.saveWithCustomType()

            default:
                a.retailer_id = i.data.id
                a.address1 = "2303 14th St NW"
                a.country_id = usa.id
                a.city = "Washington"
                a.state = "DC"
                a.postal_code = "20009"
                let _ = try? a.saveWithCustomType()
                
            }
            
            ctr += 1
        }
    }
    
    func addRetailerUsers() {
        
        let tbl = Account()
        
        let created_time = CCXServiceClass.sharedInstance.getNow()

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
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'The Bucket','bucket1@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
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
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'Ryan Coyne','bucket2@buckettechnologies.com','4102026292', \(retailerid)) RETURNING id ")
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
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'Mike Silvers','bucket3@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
        results = try? tbl.sqlRows(checkuser, params: [])

    }
    

}
