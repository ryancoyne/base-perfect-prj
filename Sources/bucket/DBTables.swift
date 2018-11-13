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
    static let logo        = "/assets/images/Logo-Refresh-RGB_vertical.png"
    static let logoSet     = "/assets/images/Logo-Refresh-RGB_vertical.png 1x, /assets/images/Logo-Refresh-RGB_vertical.png 2x"
    static let sysinit     = "1"
    static let sampledata  = "1"
//    static let sampledata  = "0"
    static let defaultdata = "1"
//    static let defaultdata = "0"
    static let database_user = "bucket"
    static let database_schema_processing = "processing"
}

//MARK: -
//MARK: List of valid countries - all countries supported are here.
struct PRJCountries {
    // NOTE: Add new countries here
    static let list = ["US","SG"]
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
    //MARK: Add schema
    public func addSchema(_ schemaName: String, _ userName: String? = PRJDBTableDefaults.database_user) -> String {
        
        let sql = "CREATE SCHEMA IF NOT EXISTS \(schemaName.lowercased()) AUTHORIZATION \(userName!)"
        
        return sql
        
    }
    
    //MARK:-
    //MARK: Core DB Table Views
    public func addCodeTransactionNotRedeemedView(_ tablename: String, _ schemaIn:String? = "public")-> String {
    
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        var viewsql = "CREATE VIEW \(schema).\(tablename)_view_not_redeemed AS "
        viewsql.append("SELECT * FROM \(schema).\(tablename) WHERE redeemed = 0; ")
        
        return viewsql
    
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

            try conf.find([("name", "defaultdata-prj")])
            if conf.name == "" {
                conf.name = "defaultdata-prj"
                conf.val = PRJDBTableDefaults.defaultdata
                try conf.create()
            }

            // do the config file
            let conf = Config()
            try? conf.setup()
            
        } catch {
            print(error)
        }

        // tables not needing postgis
//        SampleTable.sharedInstance.create()

        // Bucket specific tables
        print("Setting up CountryTable")
        CountryTable.sharedInstance.create()
        print("Completed CountryTable")
        print("Setting up POSTable")
        POSTable.sharedInstance.create()
        print("Completed POSTable")
        print("Setting up TerminalTable")
        TerminalTable.sharedInstance.create()
        print("Completed TerminalTable")
        print("Setting up RetailerTable")
        RetailerTable.sharedInstance.create()
        print("Completed RetailerTable")
        print("Setting up RetailerUserTable")
        RetailerUserTable.sharedInstance.create()
        print("Completed RetailerUserTable")
        print("Setting up RetailerContactsTable")
        RetailerContactsTable.sharedInstance.create()
        print("Completed RetailerContactsTable")
        print("Setting up ContactTypeTable")
        ContactTypeTable.sharedInstance.create()
        print("Completed ContactTypeTable")
        print("Setting up FormTable")
        FormTable.sharedInstance.create()
        print("Completed FormTable")
        print("Setting up FormFieldTable")
        FormFieldTable.sharedInstance.create()
        print("Completed FormFieldTable")
        print("Setting up FormFieldsTable")
        FormFieldsTable.sharedInstance.create()
        print("Completed FormFieldsTable")
        print("Setting up FormFieldTypeTabl")
        FormFieldTypeTable.sharedInstance.create()
        print("Completed FormFieldTypeTabl")
        print("Setting up CashoutSourceTable")
        CashoutSourceTable.sharedInstance.create()
        print("Completed CashoutSourceTable")
        print("Setting up CashoutGroupTable")
        CashoutGroupTable.sharedInstance.create()
        print("Completed CashoutGroupTable")
        print("Setting up CashoutOptionTable")
        CashoutOptionTable.sharedInstance.create()
        print("Completed CashoutOptionTable")
        print("Setting up CompletedFormsHeaderTable")
        CompletedFormsHeaderTable.sharedInstance.create()
        print("Completed CompletedFormsHeaderTable")
        print("Setting up CompletedFormsDetailTable")
        CompletedFormsDetailTable.sharedInstance.create()
        print("Completed CompletedFormsDetailTable")

        print("Setting up CodeTransactionTable")
        CodeTransactionTable.sharedInstance.create()
        print("Completed CodeTransactionTable")
        print("Setting up CodeTransactionHistoryTable")
        CodeTransactionHistoryTable.sharedInstance.create()
        print("Completed CodeTransactionHistoryTable")

        print("Setting up LedgerTable")
        LedgerTable.sharedInstance.create()
        print("Completed LedgerTable")
        print("Setting up LedgerAccountTable")
        LedgerAccountTable.sharedInstance.create()
        print("Completed LedgerAccountTable")
        print("Setting up LedgerAccountTypeTable")
        LedgerAccountTypeTable.sharedInstance.create()
        print("Completed LedgerAccountTypeTable")
        print("Setting up LedgerTypeTable")
        LedgerTypeTable.sharedInstance.create()
        print("Completed LedgerTypeTable")

        print("Setting up UserTotalTable")
        UserTotalTable.sharedInstance.create()
        print("Completed UserTotalTable")

        print("Setting up BatchHeaderTable")
        BatchHeaderTable.sharedInstance.create()
        print("Completed BatchHeaderTable")
        print("Setting up BatchDetailTable")
        BatchDetailTable.sharedInstance.create()
        print("Completed BatchDetailTable")

        print("Setting up USAccountCodeStatusTabl")
        USAccountCodeStatusTable.sharedInstance.create()
        print("Completed USAccountCodeStatusTabl")
        print("Setting up USAccountCodeDetailTable")
        USAccountCodeDetailTable.sharedInstance.create()
        print("Completed USAccountCodeDetailTable")
        print("Setting up USBucketAccountStatusTable")
        USBucketAccountStatusTable.sharedInstance.create()
        print("Completed USBucketAccountStatusTable")
        print("Setting up USBucketAccountDetailTable")
        USBucketAccountDetailTable.sharedInstance.create()
        print("Completed USBucketAccountDetailTable")

        print("Setting up AccountTableViews")
        AccountTableViews.sharedInstance.create()
        print("Completed AccountTableViews")

        print("Setting up RecommendRetailerTable")
        RecommendRetailerTable.sharedInstance.create()
        print("Completed RecommendRetailerTable")

        print("Setting up AuditRecordTable")
        AuditRecordTable.sharedInstance.create()
        print("Completed AuditRecordTable")

        // make sure the tables exist.... if not - then create it
        let thereturn = CCXDBTables.sharedInstance.isPostGIS()
        if thereturn.postgis && thereturn.postgis_topo {
            // create the postgis tables here

            print("Setting up AddressTable")
            AddressTable.sharedInstance.create()
            print("Completed AddressTable")

            // add the default data
            print("Setting up insertDefaultData")
            self.insertDefaultData()
            print("Completed insertDefaultData")

            // finally - lets add sample data - controlled by the config and the server environment table entry for sampledata (0 = no, 1 = yes)
            if EnvironmentVariables.sharedInstance.Server != ServerEnvironment.production {
                print("Setting up insertSampleData")
                self.insertSampleData()
                print("Completed insertSampleData")
            }

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
        
        // set the flag to allow sample data to be added:
        // UPDATE config SET val=1 WHERE name='sampledata-prj'
            
        // This is where we are adding the sample data
        SampleData.sharedInstance.addUserData()
        SampleData.sharedInstance.addRetailerData()
        SampleData.sharedInstance.addRetailerUsers()

        // set the sample data to NO - so no more is added
        do {
            let conf = Config()
            
            try conf.find([("name", "sampledata-prj")])
            conf.val = "0"
            try conf.saveWithCustomType()
            
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
        
        // This is where we are adding the default data
        print("Inserting addCountryCodes")
        InitializeData.sharedInstance.addCountryCodes()
        print("Done inserting addCountryCodes")
        print("Inserting addContactTypes")
        InitializeData.sharedInstance.addContactTypes()
        print("Done inserting addContactTypes")
        print("Inserting addPOS")
        InitializeData.sharedInstance.addPOS()
        print("Done inserting addPOS")
        print("Inserting addFormFieldType")
        InitializeData.sharedInstance.addFormFieldType()
        print("Done inserting addFormFieldType")
        print("Inserting addFormField")
        InitializeData.sharedInstance.addFormField()
        print("Done inserting addFormField")
        print("Inserting addForms")
        InitializeData.sharedInstance.addForms()
        print("Done inserting addForms")
        print("Inserting addFormFields")
        InitializeData.sharedInstance.addFormFields()
        print("Done inserting addFormFields")

        print("Inserting addLedgerTypes")
        InitializeData.sharedInstance.addLedgerTypes()
        print("Done inserting addLedgerTypes")
        print("Inserting addLedgerAccountTypes")
        InitializeData.sharedInstance.addLedgerAccountTypes()
        print("Done inserting addLedgerAccountTypes")
        print("Inserting addLedgerAccounts")
        InitializeData.sharedInstance.addLedgerAccounts()
        print("Done inserting addLedgerAccounts")

        print("Inserting addCashoutGroup")
        InitializeData.sharedInstance.addCashoutGroup()
        print("Done inserting addCashoutGroup")
        print("Inserting addCashoutOption")
        InitializeData.sharedInstance.addCashoutOption()
        print("Done inserting addCashoutOption")

        print("Inserting addSampleUsers")
        InitializeData.sharedInstance.addSampleUsers()
        print("Done inserting addSampleUsers")

        print("Inserting addBucketUSRetailer")
        InitializeData.sharedInstance.addBucketUSRetailer()
        print("Done inserting addBucketUSRetailer")

        // set the sample data to NO - so no more is added
        do {
            let conf = Config()
            
            try conf.find([("name", "defaultdata-prj")])
            conf.val = "0"
            try conf.saveWithCustomType()
            
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
        let tr1 = try? config.sqlRows(thesql, params: ["table_\(tbl.table())"])
        if tr1.isNotNil, let tr = tr1 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != PRJTableLevels.sampletable {
                    // update to the new installation
                    self.updateSample(currentlevel: testval!)
                }
            } else {
            
                // add the sequence number for auto sequences
                do {
                    try tbl.sqlRows(CCXDBTables.sharedInstance.addSequenceSQL(tablename: tbl.table()), params: [])
                } catch {
                    print("Error in createTable(): \(error)")
                }
                
                do {
                    try tbl.sqlRows(self.tableSample(tablename: tbl.table()), params: [])
                } catch {
                    print("Error in createTable(): \(error)")
                }

                // new one - set the default 1.00
                thesql = "INSERT INTO config(name,val) VALUES('table_\(tbl.table())','1.00')"
                do {
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in createTable(): \(error)")
                }
            }
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

