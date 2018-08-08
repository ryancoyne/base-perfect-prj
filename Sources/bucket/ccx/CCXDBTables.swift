//
//  CCXDBTables.swift
//  findapride
//
//  Created by Mike Silvers on 10/22/17.
//
//

import Foundation
import StORM
import PostgresStORM
import PerfectLogger
import PerfectLocalAuthentication

struct CCXTableLevels {
    static let userlocation    = 1.00
}

struct CCXDBTableDefaults {
    static let sysinit    = "1"
    static let sampledata = "0"
}

struct CCXSystemData {
    static let admin = "DFD117EA-8878-4335-8F26-05B2F0BE843F"
}

struct CCXSampleData {
    static let user1 = "B33F0845-33DE-4C80-B430-8ABB2EB874C3"
    static let user2 = "5AEA600A-11CF-4664-A49B-CB4DF8125E52"
    static let user3 = "4671115D-C296-4CFE-855A-7C59AD9A9183"
    static let user4 = "145E3B19-F49C-4A60-85E4-770D8B2EA055"
    static let user5 = "CA5DA361-9259-4132-A117-EA5F26E0B89B"
}

final class CCXDBTables {

    //MARK:-
    //MARK: Create the Singleton
    private init() {
        
    }
    
    static let sharedInstance = CCXDBTables()

    //MARK:-
    //MARK: Sample data
    var useradminsql : String {
        get {
            var u1 = "INSERT INTO account (id,username,email,source,usertype,detail) VALUES("
            u1.append("'\(CCXSystemData.admin)',")
            u1.append("'mike',")
            u1.append("'mike@clearcodex.com',")
            u1.append("'local',")
            u1.append("'admin',")
            u1.append("'{ \"lastname\":\"Silvers\",\"firstname\":\"Mike\",\"created\":1509930276 }') ")
            u1.append("RETURNING id")
            print("Sample user SQL: \(u1)")
            return u1
        }
    }
    
    var user1sql : String {
        get {
            var u1 = "INSERT INTO account (id,username,email,source,usertype,detail) VALUES("
            u1.append("'\(CCXSampleData.user1)',")
            u1.append("'user1',")
            u1.append("'user1@clearcodex.com',")
            u1.append("'local',")
            u1.append("'standard',")
            u1.append("'{ \"lastname\":\"One\",\"firstname\":\"User\",\"created\":1509930276 }') ")
            u1.append("RETURNING id")
            print("Sample user SQL: \(u1)")
            return u1
        }
    }
    
    var user2sql : String {
        get {
            var u1 = "INSERT INTO account (id,username,email,source,usertype,detail) VALUES("
            u1.append("'\(CCXSampleData.user2)',")
            u1.append("'user2',")
            u1.append("'user2@clearcodex.com',")
            u1.append("'local',")
            u1.append("'standard',")
            u1.append("'{ \"lastname\":\"Two\",\"firstname\":\"User\",\"created\":1509930276 }') ")
            u1.append("RETURNING id")
            print("Sample user SQL: \(u1)")
            return u1
        }
    }
    
    var user3sql : String {
        get {
            var u1 = "INSERT INTO account (id,username,email,source,usertype,detail) VALUES("
            u1.append("'\(CCXSampleData.user3)',")
            u1.append("'user3',")
            u1.append("'user3@clearcodex.com',")
            u1.append("'local',")
            u1.append("'standard',")
            u1.append("'{ \"lastname\":\"Three\",\"firstname\":\"User\",\"created\":1509930276 }') ")
            u1.append("RETURNING id")
            print("Sample user SQL: \(u1)")
            return u1
        }
    }
    
    var user4sql : String {
        get {
            var u1 = "INSERT INTO account (id,username,email,source,usertype,detail) VALUES("
            u1.append("'\(CCXSampleData.user4)',")
            u1.append("'user4',")
            u1.append("'user4@clearcodex.com',")
            u1.append("'local',")
            u1.append("'standard',")
            u1.append("'{ \"lastname\":\"Four\",\"firstname\":\"User\",\"created\":1509930276 }') ")
            u1.append("RETURNING id")
            print("Sample user SQL: \(u1)")
            return u1
        }
    }
    
    var user5sql : String {
        get {
            var u1 = "INSERT INTO account (id,username,email,source,usertype,detail) VALUES("
            u1.append("'\(CCXSampleData.user5)',")
            u1.append("'user5',")
            u1.append("'user5@clearcodex.com',")
            u1.append("'local',")
            u1.append("'standard',")
            u1.append("'{ \"lastname\":\"Five\",\"firstname\":\"User\",\"created\":1509930276 }') ")
            u1.append("RETURNING id")
            print("Sample user SQL: \(u1)")
            return u1
        }
    }
    
    //MARK:-
    //MARK: Core DB creation processes
    public func createTables() {
        
        // do the config file
        var conf = Config()
        try? conf.setup()
        
        do {
            
            conf = Config()
            
            try conf.find([("name", "sysinit-ccx")])
            if conf.name == "" {
                conf.name = "sysinit-ccx"
                conf.val = CCXDBTableDefaults.sysinit
                try conf.create()
            }
            
        } catch {
            print(error)
        }

        
        // tables not needing postgis
        InstallationTable.sharedInstance.create()
        NotificationTable.sharedInstance.create()
        FriendsTable.sharedInstance.create()
        FriendsTableViews.sharedInstance.create()
        
        // Badge tables
        BadgeTable.sharedInstance.create()
        BadgeUserTable.sharedInstance.create()
        BadgeUserProgressTable.sharedInstance.create()
        
        self.insertSystemData()

        // make sure the tables exist.... if not - then create it
        let thereturn = self.isPostGIS()
        if thereturn.postgis && thereturn.postgis_topo {
            // create the postgis tables here
            UserLocationTable.sharedInstance.create()
            BreadcrumbTable.sharedInstance.create()
        } else {
            // postgis support not on
            print("ATTENTION: postgis is not activated for the database \(PostgresConnector.database).  Do this:")
            print("psql -d \(PostgresConnector.database) -c \"CREATE EXTENSION postgis;\"")
            print("psql -d \(PostgresConnector.database) -c \"CREATE EXTENSION postgis_topology;\"")
            
            let eid = LogFile.critical("ATTENTION: postgis is not activated for the database \(PostgresConnector.database).  Do this:")
            LogFile.critical("psql -d \(PostgresConnector.database) -c \"CREATE EXTENSION postgis;\"", eventid: eid)
            LogFile.critical("psql -d \(PostgresConnector.database) -c \"CREATE EXTENSION postgis_topology;\"", eventid: eid)

        }
        
        // finally - lets add sample data - controlled by the condif table entry for sampledata (0 = no, 1 = yes)
        self.insertSampleData()
        
    }
    
    public func isPostGIS()-> (postgis: Bool, postgis_topo: Bool) {
        
        // we want the extensions postgis and postgis_topology (the field extname)
        
        let checkpostgis = "SELECT extname FROM pg_extension WHERE extname = 'postgis'; "

        let checkpostgis_topo = "SELECT extname FROM pg_extension WHERE extname = 'postgis_topology'; "

        let conf = Config()
        
        var gis = false
        var topo = false
        
        // core postgis
        var therows = try? conf.sqlRows(checkpostgis, params: [])
        var cntgis = therows?.count ?? 0
        if cntgis == 0 {
            do {
                // turn on postgis
//                let _ = try? conf.sqlRows("CREATE EXTENSION postgis CASCADE;", params: [])
                let _ = try? conf.sqlRows("CREATE EXTENSION postgis;", params: [])
                gis = true
            }
        } else if therows != nil {
            // it is already turned on
            gis = true
        }

        // postgis_topo
        therows = try? conf.sqlRows(checkpostgis_topo, params: [])
        cntgis = therows?.count ?? 0
        if cntgis == 0 {
            do {
                // turn on postgis topo
//                let _ = try? conf.sqlRows("CREATE EXTENSION postgis_topology CASCADE;", params: [])
                let _ = try? conf.sqlRows("CREATE EXTENSION postgis_topology;", params: [])
                topo = true
            }
        } else if therows != nil {
            // it is already turned on
            topo = true
        }

        return (gis, topo)
    }

    public func addCommonFields()->String {

        var createsql = ""
        
        createsql.append("created integer NOT NULL DEFAULT 0, ")
        createsql.append("createdby text COLLATE pg_catalog.default, ")
        createsql.append("modified integer NOT NULL DEFAULT 0, ")
        createsql.append("modifiedby text COLLATE pg_catalog.default, ")
        createsql.append("deleted integer NOT NULL DEFAULT 0, ")
        createsql.append("deletedby text COLLATE pg_catalog.default, ")

        return createsql
    }
    
    public func addDeletedViewsYes(_ tablename: String)-> String {
        
        var deleteviewsql = "CREATE VIEW public.\(tablename)_view_deleted_yes AS "
        deleteviewsql.append("SELECT * FROM \(tablename) WHERE deleted > 0; ")

        return deleteviewsql
    }
    
    public func addDeletedViewsNo(_ tablename: String)-> String {
        
        var deleteviewsql = "CREATE VIEW public.\(tablename)_view_deleted_no AS "
        deleteviewsql.append("SELECT * FROM \(tablename) WHERE deleted = 0; ")
        
        return deleteviewsql
    }
    
    public func addSequenceSQL(tablename: String)-> String {
    
        var addsequence = "CREATE SEQUENCE public.\(tablename)_id_seq "
        addsequence.append("INCREMENT 1 ")
        addsequence.append("START 1 ")
        addsequence.append("MINVALUE 1 ")
        addsequence.append("MAXVALUE 9223372036854775807 ")
        addsequence.append("CACHE 1;")

        return addsequence
    }
    
    //MARK:-
    //MARK: Insert Default Data
    private func insertSystemData() {

        let conf = Config()

        do {
            
            try conf.find([("name", "sysinit-ccx")])
            
            // do not create system data if we are not supposed to do so
            let createsystem:Bool = conf.val.toBool() ?? true
            if !createsystem {
                return
            }
            
            try conf.find([("name", "sysinit-ccx")])
            conf.val = "0"
            try conf.saveWithGIS()

            
        } catch {
            print(error)
        }

        do {
            
            // make sure the account table was created....
            try Account().setupTable()

            // Add the admin user
            let user = Account()
            var ra = try user.sqlRows(self.useradminsql, params: [])
            if !ra.isEmpty {
                // it was successful - update with the password
                let a = Account()
                try a.find(["id":"\(ra[0].data["id"].stringValue!)"])
                a.makePassword("mike")
                try a.saveWithGIS(CCXSystemData.admin)
            }

        } catch {
            
        }
    }
    
    //MARK:-
    //MARK: Insert sample data
    private func insertSampleData() {
        
        var createsample = false
        
        do {
            let conf = Config()
        
            try conf.find([("name", "sampledata-ccx")])
            if conf.name == "" {
                conf.name = "sampledata-ccx"
                conf.val = CCXDBTableDefaults.sampledata
                try conf.create()
            }

            createsample = conf.val.toBool()!

        } catch {
            print(error)
        }

        if !createsample {
            return
        }
        
        do {

            // make sure the account table was created....
            try Account().setupTable()
            
        } catch {
            // noneeed to do anything
        }
        
        do {
            
            let user = Account()

            // Add the sample user 1
            var ra = try user.sqlRows(self.user1sql, params: [])
            if !ra.isEmpty {
                // it was successful - update with the password
                let a = Account()
                try a.find(["id":"\(ra[0].data["id"].stringValue!)"])
                a.makePassword("user1")
                try a.saveWithGIS(CCXSampleData.user1)
            }

            // Add the sample user 2
            ra = try user.sqlRows(self.user2sql, params: [])
            if !ra.isEmpty {
                // it was successful - update with the password
                let a = Account()
                try a.find(["id":"\(ra[0].data["id"].stringValue!)"])
                a.makePassword("user2")
                try a.saveWithGIS(CCXSampleData.user2)
            }

            // Add the sample user 3
            ra = try user.sqlRows(self.user3sql, params: [])
            if !ra.isEmpty {
                // it was successful - update with the password
                let a = Account()
                try a.find(["id":"\(ra[0].data["id"].stringValue!)"])
                a.makePassword("user3")
                try a.saveWithGIS(CCXSampleData.user3)
            }

            // Add the sample user 4
            ra = try user.sqlRows(self.user4sql, params: [])
            if !ra.isEmpty {
                // it was successful - update with the password
                let a = Account()
                try a.find(["id":"\(ra[0].data["id"].stringValue!)"])
                a.makePassword("user4")
                try a.saveWithGIS(CCXSampleData.user4)
            }

            // Add the sample user 5
            ra = try user.sqlRows(self.user5sql, params: [])
            if !ra.isEmpty {
                // it was successful - update with the password
                let a = Account()
                try a.find(["id":"\(ra[0].data["id"].stringValue!)"])
                a.makePassword("user5")
                try a.saveWithGIS(CCXSampleData.user5)
            }

            // add a friend
            let f1 = Friends()
            f1.created    = 1509932034
            f1.createdby  = CCXSampleData.user2
            f1.modified   = 1509935634
            f1.modifiedby = CCXSampleData.user1
            f1.friend_id  = CCXSampleData.user1
            f1.user_id    = CCXSampleData.user2
            f1.invited    = 1509932034
            f1.accepted   = 1509935634
            try f1.saveWithGIS()
            
            // add a pending friend
            let f2 = Friends()
            f2.created    = 1509932034
            f2.createdby  = CCXSampleData.user5
            f2.modified   = 1509935634
            f2.modifiedby = CCXSampleData.user3
            f2.friend_id  = CCXSampleData.user3
            f2.user_id    = CCXSampleData.user5
            f2.invited    = 1509932034
            try f2.saveWithGIS()
            
            // add a rejected friend
            let f3 = Friends()
            f3.created    = 1509932034
            f3.createdby  = CCXSampleData.user3
            f3.modified   = 1509935634
            f3.modifiedby = CCXSampleData.user2
            f3.friend_id  = CCXSampleData.user2
            f3.user_id    = CCXSampleData.user3
            f3.invited    = 1509932034
            f3.rejected   = 1509935634
            try f3.saveWithGIS()

            // another firiendship
            let f4 = Friends()
            f4.created    = 1509932034
            f4.createdby  = CCXSampleData.user2
            f4.modified   = 1509935634
            f4.modifiedby = CCXSampleData.user4
            f4.friend_id  = CCXSampleData.user4
            f4.user_id    = CCXSampleData.user2
            f4.invited    = 1509932034
            f4.accepted   = 1509935634
            try f4.saveWithGIS()

        } catch {
            print(error)
        }
        
        // set the sample data to NO - so no more is added
        do {
            let conf = Config()
            
            try conf.find([("name", "sampledata-ccx")])
            conf.val = "0"
            try conf.saveWithGIS()
            
        } catch {
            print(error)
        }
    }
}

