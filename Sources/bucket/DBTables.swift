//
//  DBTables.swift
//
//
//  Created by Mike Silvers on 10/22/17.
//
//

//MARK: -
//MARK: Creating the database
//CREATE DATABASE dbname
//WITH
//OWNER = dbuser
//ENCODING = 'UTF8'
//LC_COLLATE = 'en_US.UTF-8'
//LC_CTYPE = 'en_US.UTF-8'
//TABLESPACE = pg_default
//CONNECTION LIMIT = -1;
//MARK: -

import Foundation

import StORM
import PerfectLib
import PostgresStORM
import PerfectLogger
import PerfectLocalAuthentication

struct PRJPictureLocations {
    static let AWSfileURL            = "https://s3.amazonaws.com/<~default dir~>/"
    static let AWSfileURLCapsulePics = "https://s3.amazonaws.com/~default dir~>/capsulepics/"
    static let filesDirectoryPics: String = {
        
        #if os(macOS)
            return "./fileslocal/<~default dir~>"
        #elseif os(Linux)
            return "./files/<~default dir~>"
        #endif
        
    }()
    
    static let filesDirectoryDeletedPics: String = {
        
        #if os(macOS)
            return "./fileslocal/<~default dir~>/deleted"
        #elseif os(Linux)
            return "./files/<~default dir~>/deleted"
        #endif
        
    }()

}

struct PRJDefaults {
}

struct PRJTableLevels {
    static let sampletable = 1.00
}

struct PRJDBTableDefaults {
    static let title       = "Bucket Technologies"
    static let subTitle    = "Goodbye Coins, Hello Change"
    static let logo        = "/assets/images/no-logo.png"
    static let logoSet     = "/assets/images/no-logo.png 1x, /assets/images/no-logo.svg 2x"
    static let sysinit     = "1"
//    static let sampledata  = "1"
    static let sampledata  = "0"
    static let defaultdata = "1"
}

struct PRJSampleData {
    static let admin = "DFD117EA-8878-4335-8F26-05B2F0BE843F"
}

final class PRJDBTables {

    //MARK:-
    //MARK: Create the Singleton
    private init() {
        
    }
    
    static let sharedInstance = PRJDBTables()

    //MARK: - File Support Functions:
    static func getFilenamePRJ()->String {
        
        // name the new file
        var newfilename = UUID().uuidString
        // since we are using the UUID function there is a ~~very~~ slim chance of duplicates
        // if it is a duplicate, select another UUID.
        if PRJDBTables.doesFileExistPRJPics(filename: newfilename) {
            newfilename = UUID().uuidString
        }
        
        return newfilename
    }
    
    static func doesFileExistPRJPics(filename: String) -> Bool {
        
        var filefound = false
        
        // does it exist?
        var context = ["files":[[String:String]]()]
        let d = Dir(PRJPictureLocations.filesDirectoryPics)
        
        // if the directory does not exist, create it....
        CCXServiceClass.doesDirectoryExist(d)
        
        // and look for the filename
        do{
            try d.forEachEntry(closure: {
                f in
                
                if f.lowercased() == filename.lowercased() {
                    filefound = true
                    return
                }
                
                context["files"]?.append(["name":f])
            })
        } catch {
            print("Checking directory for file error: \(error.localizedDescription)")
        }
        
        // we didn't see the file, or maybe we did?
        return filefound
        
    }

    
    //MARK:-
    //MARK: Core DB creation processes
    public func createTables() {
        
        // do the config file
        var conf = Config()
        try? conf.setup()
        
        do {
            
            try conf.find([("name", "title")])
            if conf.name == "" {
                conf.name = "title"
                conf.val = PRJDBTableDefaults.title
                try conf.create()
            }
            
            conf = Config()
            
            try conf.find([("name", "subtitle")])
            if conf.name == "" {
                conf.name = "subtitle"
                conf.val = PRJDBTableDefaults.subTitle
                try conf.create()
            }
            
            conf = Config()
            
            try conf.find([("name", "logo")])
            if conf.name == "" {
                conf.name = "logo"
                conf.val = PRJDBTableDefaults.logo
                try conf.create()
            }
            
            conf = Config()
           
            try conf.find([("name", "logosrcset")])
            if conf.name == "" {
                conf.name = "logosrcset"
                conf.val = PRJDBTableDefaults.logoSet
                try conf.create()
            }
                        
        } catch {
            print(error)
        }

        // tables not needing postgis
//        SampleTable.sharedInstance.create()

        // Bucket specific tables
        CountryTable.sharedInstance.create()
        CurrencyTable.sharedInstance.create()

        // make sure the tables exist.... if not - then create it
        let thereturn = CCXDBTables.sharedInstance.isPostGIS()
        if thereturn.postgis && thereturn.postgis_topo {
            // create the postgis tables here
            
            // finally - lets add sample data - controlled by the condif table entry for sampledata (0 = no, 1 = yes)

        } else {
            // postgis support not on
            print("ATTENTION: postgis is not activated for the database \(PostgresConnector.database).  Do this:")
            print("psql -d \(PostgresConnector.database) -c \"CREATE EXTENSION postgis;\"")
            print("psql -d \(PostgresConnector.database) -c \"CREATE EXTENSION postgis_topology;\"")
            
            let eid = LogFile.critical("ATTENTION: postgis is not activated for the database \(PostgresConnector.database).  Do this:")
            LogFile.critical("psql -d \(PostgresConnector.database) -c \"CREATE EXTENSION postgis;\"", eventid: eid)
            LogFile.critical("psql -d \(PostgresConnector.database) -c \"CREATE EXTENSION postgis_topology;\"", eventid: eid)

        }
    }
    
    //MARK:-
    //MARK: Insert sample data
    private func insertSampleData() {
        
        var createsample = false
        
        do {
            let conf = Config()
        
            try conf.find([("name", "sampledata-prj")])
            if conf.name == "" {
                conf.name = "sampledata-prj"
                conf.val = PRJDBTableDefaults.sampledata
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
            
            // This is where we are adding the sample data

        } catch {
            print(error)
        }

        // set the sample data to NO - so no more is added
        do {
            let conf = Config()
            
            try conf.find([("name", "sampledata-prj")])
            conf.val = "0"
            try conf.saveWithGIS()
            
        } catch {
            print(error)
        }
        
    }

    //MARK:-
    //MARK: Insert default data
    private func insertDefaultData() {
        
        var createsample = false
        
        do {
            let conf = Config()
            
            try conf.find([("name", "defaultdata-prj")])
            if conf.name == "" {
                conf.name = "defaultdata-prj"
                conf.val = PRJDBTableDefaults.defaultdata
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
            
            // This is where we are adding the sample data

        } catch {
            print(error)
        }
        
        // set the sample data to NO - so no more is added
        do {
            let conf = Config()
            
            try conf.find([("name", "defaultdata-prj")])
            conf.val = "0"
            try conf.saveWithGIS()
            
        } catch {
            print(error)
        }
        
    }

    //MARK:-
    //MARK: creating table template
    private func createTable() {
        
        let tbl = SampleTable.sharedInstance.tbl
        
        // make sure the table level is correct
        let config = Config()
        var thesql = "SELECT val, name FROM config WHERE name = $1"
        var tr = try! config.sqlRows(thesql, params: ["table_\(tbl.table())"])
        if tr.count > 0 {
            let testval = Double(tr[0].data["val"] as! String)
            if testval != PRJTableLevels.sampletable {
                // update to the new installation
                self.updateSample(currentlevel: testval!)
            }
        } else {
            
            // add the sequence number for auto sequences
            try! tbl.sqlRows(CCXDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table()), params: [])

            try! tbl.sqlRows(self.tableSample(tablename: tbl.table()), params: [])
            
            // new one - set the default 1.00
            thesql = "INSERT INTO config(name,val) VALUES('table_\(tbl.table())','1.00')"
            try! config.sqlRows(thesql, params: [])
        }
        
    }
    
    private func updateSample(currentlevel: Double) {
        
        let tbl = SampleTable.sharedInstance.tbl
        
        // PERFORM THE UPDATE ACCORFING TO REQUIREMENTS
        print("UPDATE \(tbl.table().uppercased()).  Current Level \(currentlevel), Required Level: \(PRJTableLevels.sampletable)")
        
    }
    
    private func tableSample(tablename: String)-> String {
        
        var createsql = "CREATE TABLE IF NOT EXISTS "
        createsql.append("public.\(tablename) ")
        
        // common
        createsql.append("( ")
        createsql.append("id integer NOT NULL DEFAULT nextval('\(tablename)_id_seq'::regclass), ")
        
        createsql.append(CCXDBTables.sharedInstance.addCommonFields())
        
        // table specific fields
        createsql.append("geopoint geometry, ")
        createsql.append("geopointtime integer NOT NULL DEFAULT 0, ")

        // ending fields
        createsql.append("CONSTRAINT \(tablename)_pkey PRIMARY KEY (id) ")
        createsql.append("); ")
        
        print(createsql)
        
        return createsql
    }
}

