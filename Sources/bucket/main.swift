//
//  Created by Ryan Coyne on 2017-10-30.
//    Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2018 ClearCodeX Inc.
// Licensed under Apache License v2.0
//

//
// NOTE:
// To determine if PostGIS is installed:
//  SELECT * FROM pg_extension WHERE extname LIKE '%gis%';
//

// When installing on the cloud service:
// 1. Ubuntu 16.04 server
// 2. Postgresql database
// 3. PostGIS package
// Then....
// a. Create the database:  CREATE DATABASE bucket;
// b. Create the user: CREATE USER bucket WITH ENCRYPTED PASSWORD 'xHClEyTLxMV888QU';
// c. Add PostGIS: (command line as postgres user): psql -d bucket -c "CREATE EXTENSION postgis;"
// d. Add PostGIS Topo: (command line as postgres user): psql -d bucket -c "CREATE EXTENSION postgis_topology;"
// e. Grant permission to the user: GRANT ALL PRIVILEGES ON DATABASE bucket TO bucket;
// Then....
// i. Upload the program to the server
// ii. Copy the config/main.json file and adjust the settings
//
// Create the bucketbackup user:
// a. Create the bucketbackup superuser: CREATE USER bucketbackup WITH ENCRYPTED PASSWORD 'a3d9323ac9ec5a6935fb8096';
// b. Set the role to superuser: ALTER ROLE bucketbackup superuser;
// Now you are ready to start the bucket service!

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import PostgresStORM
import PerfectLogger
import PerfectRequestLogger

import PerfectSession
import PerfectSessionPostgreSQL
import PerfectCrypto
import PerfectLocalAuthentication

import PerfectNotifications

import OAuth2

import Foundation

let _ = PerfectCrypto.isInitialized

var isProduction = false
switch EnvironmentVariables.sharedInstance.Server {
    case .production?:
        isProduction = true
    default:
        isProduction = false
}

// make sure the log directory exists
var logfilelocation = "/"
let logFileName = "default.txt"
let requestFileName = "requests.txt"
let stormFileName = "storm.txt"

if let logfile = EnvironmentVariables.sharedInstance.filesDirectoryLogs {
    logfilelocation = logfile
    
    var itexists = false
    
    // make sure it exists...
    let logDir = Dir(logfilelocation)
    if logDir.exists {
        itexists = true
    } else {
        // create the directory
        if let _ = try? logDir.create() {
            itexists = true
        }
    }
    
    
    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
    let currentdatetime = formatter.string(from: Date())
    
    
    if itexists {
        // check for the files
        let defaultlogFile = File(logDir.path + logFileName)
        let requestlogFile = File(logDir.path + requestFileName)
        let stormlogFile = File(logDir.path + stormFileName)
        
        if let _ = try? defaultlogFile.open(.readWrite, permissions: .rwUserGroup) {
            let _ = try? defaultlogFile.write(string: "LOGGING START: \(currentdatetime)")
            defaultlogFile.close()
        }
        
        if let _ = try? requestlogFile.open(.readWrite, permissions: .rwUserGroup) {
            let _ = try? requestlogFile.write(string: "LOGGING START: \(currentdatetime)")
            requestlogFile.close()
        }
        
        if let _ = try? stormlogFile.open(.readWrite, permissions: .rwUserGroup) {
            let _ = try? stormlogFile.write(string: "LOGGING START: \(currentdatetime)")
            stormlogFile.close()
        }

    }
}

// setup the logging
RequestLogFile.location = logfilelocation + "/" + requestFileName
LogFile.location        = logfilelocation + "/" + logFileName

Log.logger = SysLogger()

// if the notifications directory exists, lets set it up
let notesettings = NotificationSettings()
if CCXServiceClass.doesDirectoryExist(Dir("ccx/installations"), create: false) {
    notesettings.IOS_APNS_KEY_IDENTIFIER       = InstallationVariables.sharedInstance.IOS_APNS_KEY_IDENTIFIER!
    notesettings.IOS_APNS_PRIVATE_KEY_FILEPATH = InstallationVariables.sharedInstance.IOS_APNS_PRIVATE_KEY_FILEPATH!
    notesettings.IOS_APNS_TEAM_IDENTIFIER      = InstallationVariables.sharedInstance.IOS_APNS_TEAM_IDENTIFIER!
    notesettings.IOS_APPID                     = InstallationVariables.sharedInstance.IOS_APPID!
}

// print out the system environment variables
//let env_variables = ProcessInfo.processInfo.environment
//print("\n== Environment Variable List START ==")
//for (key, value) in env_variables {
//    print("    Process Info: key: \(key), value: \(value)")
//}
//print("== Environment Variable List END ==\n")


// the DB user should be a superuser
//CREATE USER dbuser WITH
//  LOGIN
//  SUPERUSER
//  INHERIT
//  CREATEDB
//  CREATEROLE
//  NOREPLICATION;

// ALTER ROLE dbuser WITH PASSWORD 'dbpassword';

// CREATE DATABASE dbname OWNER dbuser

if notesettings.IOS_APPID != nil {
    NotificationPusher.addConfigurationAPNS(
        name: notesettings.IOS_APPID!,
        production: isProduction, // should be false when running pre-release app in debugger
        keyId: notesettings.IOS_APNS_KEY_IDENTIFIER!,
        teamId: notesettings.IOS_APNS_TEAM_IDENTIFIER!,
        privateKeyPath: notesettings.IOS_APNS_PRIVATE_KEY_FILEPATH!)
}

PostgresConnector.port     = EnvironmentVariables.sharedInstance.DB_PORT!
PostgresConnector.host     = EnvironmentVariables.sharedInstance.DB_HOSTNAME!
PostgresConnector.database = EnvironmentVariables.sharedInstance.DB_USERNAME!
PostgresConnector.username = EnvironmentVariables.sharedInstance.DB_USERNAME!
PostgresConnector.password = EnvironmentVariables.sharedInstance.DB_PASSWORD!

if EnvironmentVariables.sharedInstance.URL_PORT != 80 || EnvironmentVariables.sharedInstance.URL_PORT != 443 {
    // non standard port
    var burl = EnvironmentVariables.sharedInstance.URL_PROTOCOL!
    burl.append("://")
    burl.append(EnvironmentVariables.sharedInstance.URL_DOMAIN!)
    burl.append(":")
    burl.append("\(EnvironmentVariables.sharedInstance.URL_PORT!)")
    burl.append("/")
    AuthenticationVariables.baseURL =  burl
} else {
    // standard ports
    var burl = EnvironmentVariables.sharedInstance.URL_PROTOCOL!
    burl.append("://")
    burl.append(EnvironmentVariables.sharedInstance.URL_DOMAIN!)
    AuthenticationVariables.baseURL = burl
}

//var baseApiURL = ""

//if EnvironmentVariables.sharedInstance.API_URL_PORT != 80 || EnvironmentVariables.sharedInstance.API_URL_PORT != 443 {
//
//    var burl = EnvironmentVariables.sharedInstance.API_URL_PROTOCOL!
//    burl.append("://")
//    burl.append(EnvironmentVariables.sharedInstance.API_DOMAIN!)
//    burl.append(":")
//    burl.append("\(EnvironmentVariables.sharedInstance.API_URL_PORT!)")
//    burl.append("/")
//    baseApiURL                         = burl
//
//} else {
//    var burl = EnvironmentVariables.sharedInstance.API_URL_PROTOCOL!
//    burl.append("://")
//    burl.append(EnvironmentVariables.sharedInstance.API_DOMAIN!)
//    burl.append("/")
//    baseApiURL                         = burl
//
//}

//MARK: EMAIL CONFIGURATION
if EnvironmentVariables.sharedInstance.EMAIL_SERVER != nil {
//    SMTPConfig.mailserver         = "smtps://smtp.gmail.com"
    SMTPConfig.mailserver         = EnvironmentVariables.sharedInstance.EMAIL_SERVER!
    SMTPConfig.mailuser           = EnvironmentVariables.sharedInstance.EMAIL_USERNAME!
    SMTPConfig.mailpass           = EnvironmentVariables.sharedInstance.EMAIL_PASSWORD!
    SMTPConfig.mailfromaddress    = EnvironmentVariables.sharedInstance.EMAIL_FROM_ADDRESS!
    SMTPConfig.mailfromname       = EnvironmentVariables.sharedInstance.EMAIL_FROM_DISPLAY_NAME!
}

//MARK:-

// Create HTTP server.
let server = HTTPServer()

// Used in email communications
// The Base link to your system, such as http://www.example.com/

// Configuration of Session
SessionConfig.name = EnvironmentVariables.sharedInstance.SessionName!
// SessionConfig.idle = 86400
// set the timeout for a year.
SessionConfig.idle = 31622400
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = true
SessionConfig.CORS.enabled = true
SessionConfig.cookieSameSite = .lax
SessionConfig.cookieDomain = EnvironmentVariables.sharedInstance.SessionName!

// Setup logging
let myLogger = RequestLogger()

PostgresSessionConnector.host = PostgresConnector.host
PostgresSessionConnector.port = PostgresConnector.port
PostgresSessionConnector.username = PostgresConnector.username
PostgresSessionConnector.password = PostgresConnector.password
PostgresSessionConnector.database = PostgresConnector.database
PostgresSessionConnector.table = "sessions"

let sessionDriver = SessionPostgresDriver()

Config.runSetup()

// =======================================================================
// Defaults
// =======================================================================
var configTitle = CCXServiceClass.sharedInstance.displayTitle
var configSubTitle = CCXServiceClass.sharedInstance.displaySubTitle
var configLogo = CCXServiceClass.sharedInstance.displayLogo
var configLogoSrcSet = CCXServiceClass.sharedInstance.displayLogoSrcSet

let systemInit = CCXServiceClass.sharedInstance.systemInit

// Make sure the tables exist
CCXDBTables.sharedInstance.createTables()

// project specific tables
PRJDBTables.sharedInstance.createTables()

// Add the routes to the server.
var routes: [[String: Any]] = [[String: Any]]()

routes = routes + UserAPI.json.routes
routes = routes + UserAPI.web.routes
routes = routes + InstallationsV1Controller.json.routes
routes = routes + CCXStatisticsV1Controller.json.routes
routes = routes + FriendAPI.json.routes
routes.append(contentsOf: RetailerAPI.json.routes)
routes.append(contentsOf: RetailerWEB.web.routes)
routes.append(contentsOf: ConsumerAPI.json.routes)
routes.append(contentsOf: ConsumerWEB.web.routes)

// only if we are not in production
if EnvironmentVariables.sharedInstance.Server.stringValue != "PROD" {
    routes.append(contentsOf: TestingAPI.json.routes)
}

//MARK:-
//MARK: Initilization functions - only when we move to a new server that has not been initilized
if systemInit {
    routes.append(["method":"get", "uri":"/initialize", "handler":Handlers.initialize])
    routes.append(["method":"post", "uri":"/setup", "handler":Handlers.initializeSave])
}

//MARK:-
//MARK: HEALTH CHECK
routes.append(["method":"get", "uri":"/healthcheck", "handler":Handlers.healthcheck])


//MARK:-
//MARK: STATIC FILES AND DEFAULT ROUTE
routes.append(["method":"get", "uri":"/", "handler":Handlers.main])
routes.append(["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
               "documentRoot":EnvironmentVariables.sharedInstance.HTTP_DOCUMENT_ROOT!,
               "allowResponseFilters":true])

// put together the filters (nothing special... just filters)
func filters() -> [[String: Any]] {
    
    var filters: [[String: Any]] = [[String: Any]]()
    filters.append(["type":"response","priority":"high","name":PerfectHTTPServer.HTTPFilter.contentCompression])
    filters.append(["type":"request","priority":"high","name":RequestLogger.filterAPIRequest])
    filters.append(["type":"response","priority":"low","name":RequestLogger.filterAPIResponse])
    
    // added for sessions
    filters.append(["type":"request","priority":"high","name":SessionPostgresFilter.filterAPIRequest])
    filters.append(["type":"response","priority":"high","name":SessionPostgresFilter.filterAPIResponse])
    
    return filters
}

//MARK: -
//MARK: External API Call configuration - this is where you set the service_id to process the correct service.
//if let servicelist = EnvironmentVariables.sharedInstance.ConnectionServices {
//    for service in servicelist {
//        
//        if let srv_id = service.service_id {
//            switch srv_id {
//            case 1:
//                
//                // we want to connect even if we are not using it right away
//                StagesConnecter.sharedInstance.services = service
//                StagesConnecter.sharedInstance.login()
//
//                // check to see if you should run the entire process on startup
//                if let chk = EnvironmentVariables.sharedInstance.CheckOnStart_Server1, chk {
//                
//                    // GET USERS and associate
//                    ExternalServicesConnecter.sharedInstance.server1SyncUsers()
//                }
//                
//            case 2:
//                if let chk = EnvironmentVariables.sharedInstance.CheckOnStart_Server2, chk {
//
//                    // MINDBODY CONNECTOR
//                    ExternalServicesConnecter.sharedInstance.server2SyncUsers()
//
//                }
//
//            default:
//                // not really doing anything here as this should not occur
//                print("This should not occur, but it did.  service_id: \(srv_id)")
//            }
//        }
//    }
//}

//MARK:-
//MARK: Server configuration
var confData: [String:[[String:Any]]] = [
    "servers": [
        [
            "name":EnvironmentVariables.sharedInstance.LISTENING_URL_DOMAIN!,
            "port":EnvironmentVariables.sharedInstance.LISTENING_URL_PORT!,
            // "address":serverIP,
            "routes":routes,
            "filters":filters()
        ]
    ]
]

// Where to serve static files from
server.documentRoot = EnvironmentVariables.sharedInstance.HTTP_DOCUMENT_ROOT!

// =======================================================================
// Server start
// =======================================================================
do {
    // Launch the servers based on the configuration data.
    try HTTPServer.launch(configurationData: confData)
} catch {
    // fatal error launching one of the servers
    fatalError("\(error)")
}

