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

        var sqlstatement = "INSERT INTO us.\(tbl.table()) "
        
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
        
        var checkuser = "SELECT id FROM public.account WHERE id = 'AUTO_CREATED_USER'; "
        var tr = try? tbl.sqlRows(checkuser, params: [])
        if let thecount = tr?.count, thecount == 0 {
            // it does not exist - add it
            checkuser = "INSERT INTO public.account "
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
        
        checkuser = "SELECT id FROM public.account WHERE id = 'AUTO_MODIFIED_USER'; "
        tr = try? tbl.sqlRows(checkuser, params: [])
        if let thecount = tr?.count, thecount == 0 {
            // it does not exist - add it
            checkuser = "INSERT INTO public.account "
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

        checkuser = "SELECT id FROM public.account WHERE id = 'AUTO_DELETED_USER'; "
        tr = try? tbl.sqlRows(checkuser, params: [])
        if let thecount = tr?.count, thecount == 0 {
            // it does not exist - add it
            checkuser = "INSERT INTO public.account "
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
        
        var sqlstatement = "INSERT INTO us.\(tbl.table()) "
        
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

        sqlstatement = "INSERT INTO \(singapore.code_alpha_2!.lowercased()).\(tbl.table()) "
        
        sqlstatement.append("(created, createdby, name, is_verified, retailer_code) ")
        sqlstatement.append(" VALUES ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','Bucket Coffee Shop', TRUE, 'BCKT-1'), ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','Ryans Bike Shop', TRUE, 'BCKT-2'), ")
        sqlstatement.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)','M&R Corner Market', TRUE, 'BCKT-3') ")
        
        print("Adding retailers: \(sqlstatement)")
        let _ = try? tbl.sqlRows(sqlstatement, params: [])

        // We add the retailer 1 in the production initialization of data
        var retrows = try? tbl.sqlRows("SELECT * FROM us.retailer WHERE id != 1", params: [])
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
                a.geopoint = CCXGeographyPoint(latitude: 38.920441, longitude: -77.031007)
                let _ = try? a.saveWithCustomType(schemaIn: "us")
                
            case 1:
                a.retailer_id = i.data.id
                a.address1 = "2400 14th St NW"
                a.country_id = usa.id
                a.city = "Washington"
                a.state = "DC"
                a.postal_code = "20009"
                a.geopoint = CCXGeographyPoint(latitude: 38.920757, longitude: -77.032072)
                let _ = try? a.saveWithCustomType(schemaIn: "us")

//            case 2:
//                a.retailer_id = i.data.id
//                a.address1 = "4 Everton Park"
//                a.address2 = "#01-40"
//                a.country_id = singapore.id
//                a.state = "Singapore"
//                a.postal_code = "080004"
//                a.geopoint = CCXGeographyPointlatitude: 1.277129, longitude: 103.839368)
//                let _ = try? a.saveWithCustomType()

            default:
                a.retailer_id = i.data.id
                a.address1 = "2303 14th St NW"
                a.country_id = usa.id
                a.city = "Washington"
                a.state = "DC"
                a.postal_code = "20009"
                a.geopoint = CCXGeographyPoint(latitude: 38.920172, longitude: -77.031801)
                let _ = try? a.saveWithCustomType(schemaIn: "us")

            }
            
            ctr += 1
        }
        
        
        
        retrows = try? tbl.sqlRows("SELECT * FROM \(singapore.code_alpha_2!.lowercased()).retailer", params: [])
        ctr = 0
        for i in retrows! {
            
            let a = Address()
            
            switch ctr {
                
            case 0:
                a.retailer_id = i.data.id
                a.address1 = "2 Everton Park"
                a.address2 = "#01-40"
                a.country_id = singapore.id
                a.state = "Singapore"
                a.postal_code = "080004"
                a.geopoint = CCXGeographyPoint(latitude: 1.277129, longitude: 103.839368)
                let _ = try? a.saveWithCustomType(schemaIn: singapore.code_alpha_2!.lowercased())

            case 1:
                a.retailer_id = i.data.id
                a.address1 = "4 Everton Park"
                a.address2 = "#01-40"
                a.country_id = singapore.id
                a.state = "Singapore"
                a.postal_code = "080004"
                a.geopoint = CCXGeographyPoint(latitude: 1.277129, longitude: 103.839368)
                let _ = try? a.saveWithCustomType(schemaIn: singapore.code_alpha_2!.lowercased())

            case 2:
                a.retailer_id = i.data.id
                a.address1 = "8 Everton Park"
                a.address2 = "#01-40"
                a.country_id = singapore.id
                a.state = "Singapore"
                a.postal_code = "080004"
                a.geopoint = CCXGeographyPoint(latitude: 1.277129, longitude: 103.839368)
                let _ = try? a.saveWithCustomType(schemaIn: singapore.code_alpha_2!.lowercased())
                
            default:
                a.retailer_id = i.data.id
                a.address1 = "100 Everton Park"
                a.address2 = "#01-40"
                a.country_id = singapore.id
                a.state = "Singapore"
                a.postal_code = "080004"
                a.geopoint = CCXGeographyPoint(latitude: 1.277129, longitude: 103.839368)
                let _ = try? a.saveWithCustomType(schemaIn: singapore.code_alpha_2!.lowercased())

            }
            
            ctr += 1
        }

    }
    
    func addRetailerUsers() {
        
        let tbl = Account()
        
        let created_time = CCXServiceClass.sharedInstance.getNow()

        var userid = UUID().uuidString
        var checkuser = "INSERT INTO public.account "
        checkuser.append("(id,username,email,usertype,source, detail) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(userid)','bucketme1','bucket1@buckettechnologies.com','standard','local','{\"created\":\(created_time)}')")

        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

        // update the retailer with the new userid
        var retailerid = 1

        // add the retailer user
        checkuser = "INSERT INTO us.retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'The Bucket','bucket1@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
        let _ = try? tbl.sqlRows(checkuser, params: [])

        checkuser = "INSERT INTO sg.retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'The Bucket','bucket1@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
        let _ = try? tbl.sqlRows(checkuser, params: [])

        // new one
        userid = UUID().uuidString
        checkuser = "INSERT INTO public.account "
        checkuser.append("(id,username,email,usertype,source, detail) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(userid)','bucketme2','bucket2@buckettechnologies.com','standard','local','{\"created\":\(created_time)}')")
        
        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

        // update the retailer with the new userid
        retailerid = 2

        // add the retailer user
        checkuser = "INSERT INTO us.retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'Ryan Coyne','bucket2@buckettechnologies.com','4102026292', \(retailerid)) RETURNING id ")
        let _ = try? tbl.sqlRows(checkuser, params: [])

        // add the retailer user
        checkuser = "INSERT INTO sg.retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'Ryan Coyne','bucket2@buckettechnologies.com','4102026292', \(retailerid)) RETURNING id ")
        let _ = try? tbl.sqlRows(checkuser, params: [])

        // new one
        userid = UUID().uuidString
        checkuser = "INSERT INTO public.account "
        checkuser.append("(id,username,email,usertype,source, detail) ")
        checkuser.append(" VALUES ")
        checkuser.append(" ('\(userid)','bucketme3','bucket3@buckettechnologies.com','standard','local','{\"created\":\(created_time)}')")

        print("Adding user: \(checkuser)")
        _ = try? tbl.sqlRows(checkuser, params: [])

        // update the retailer with the new userid
        retailerid = 3

        // add the retailer user
        checkuser = "INSERT INTO us.retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'Mike Silvers','bucket3@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
        let _ = try? tbl.sqlRows(checkuser, params: [])
        
        // add the retailer user
        checkuser = "INSERT INTO sg.retailer_contacts "
        checkuser.append(" (created, createdby,user_id,name,email_address, phone_number, retailer_id) VALUES ")
        checkuser.append(" (\(created_time), '\(CCXDefaultUserValues.user_server)', '\(userid)', 'Mike Silvers','bucket3@buckettechnologies.com','4104224503', \(retailerid)) RETURNING id ")
        let _ = try? tbl.sqlRows(checkuser, params: [])


        
    }
    

}
