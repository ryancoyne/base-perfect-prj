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

// seed the random number generator in Linux
// done here because of a known repeating number issue when used inside a function
// refer to: https://stackoverflow.com/questions/41035180/swift-arc4random-uniformmax-in-linux  
#if os(Linux)
    srandom(UInt32(time(nil)))
#endif

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
        
        if let _ = try? defaultlogFile.open(.append, permissions: .rwUserGroup) {
            let _ = try? defaultlogFile.write(string: "LOGGING START: \(currentdatetime)")
            defaultlogFile.close()
        }
        
        if let _ = try? requestlogFile.open(.append, permissions: .rwUserGroup) {
            let _ = try? requestlogFile.write(string: "LOGGING START: \(currentdatetime)")
            requestlogFile.close()
        }
        
        if let _ = try? stormlogFile.open(.append, permissions: .rwUserGroup) {
            let _ = try? stormlogFile.write(string: "LOGGING START: \(currentdatetime)")
            stormlogFile.close()
        }

    }
}

print("main.swift: Setting up logging")

// setup the logging
RequestLogFile.location = logfilelocation + "/" + requestFileName
LogFile.location        = logfilelocation + "/" + logFileName

Log.logger = SysLogger()

// if the notifications directory exists, lets set it up
let notesettings = NotificationSettings()
if RMServiceClass.doesDirectoryExist(Dir("ccx/installations"), create: false) {
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

print("main.swift: Setting up APNS")

if notesettings.IOS_APPID != nil {
    NotificationPusher.addConfigurationAPNS(
        name: notesettings.IOS_APPID!,
        production: isProduction, // should be false when running pre-release app in debugger
        keyId: notesettings.IOS_APNS_KEY_IDENTIFIER!,
        teamId: notesettings.IOS_APNS_TEAM_IDENTIFIER!,
        privateKeyPath: notesettings.IOS_APNS_PRIVATE_KEY_FILEPATH!)
}

print("main.swift: Setting up postgres")

PostgresConnector.port     = EnvironmentVariables.sharedInstance.DB_PORT!
PostgresConnector.host     = EnvironmentVariables.sharedInstance.DB_HOSTNAME!
PostgresConnector.database = EnvironmentVariables.sharedInstance.DB_DATABASE!
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
//SessionConfig.cookieDomain = EnvironmentVariables.sharedInstance.SessionName!
SessionConfig.cookieDomain = EnvironmentVariables.sharedInstance.URL_DOMAIN!

// Setup logging
let myLogger = RequestLogger()

PostgresSessionConnector.host = PostgresConnector.host
PostgresSessionConnector.port = PostgresConnector.port
PostgresSessionConnector.username = PostgresConnector.username
PostgresSessionConnector.password = PostgresConnector.password
PostgresSessionConnector.database = PostgresConnector.database
PostgresSessionConnector.table = "sessions"

let sessionDriver = SessionPostgresDriver()

print("main.swift: Running Config.runSetup()")

RMConfig.runSetup()

print("main.swift: Complete Config.runSetup()")

// =======================================================================
// Defaults
// =======================================================================
print("main.swift: Creating displayTitle")
var configTitle = RMConfig.getVal("title", "")
//var configTitle = RMServiceClass.sharedInstance.displayTitle
print("main.swift: Completed displayTitle")

print("main.swift: Creating displaySubTitle")
var configSubTitle = RMConfig.getVal("subtitle","")
print("main.swift: Completed displaySubTitle")

print("main.swift: Creating displayLogo")
var configLogo = RMConfig.getVal("logo","/assets/images/no-logo.png")
print("main.swift: Completed displayLogo")

print("main.swift: Creating displayLogoSrcSet")
var configLogoSrcSet = RMConfig.getVal("logosrcset","/assets/images/no-logo.png 1x, /assets/images/no-logo.svg 2x")
print("main.swift: Completed displayLogoSrcSet")

print("main.swift: Creating sysinit")
let si = RMConfig.getVal("sysinit", "0")
let systemInit = si.toBool() ?? false
print("main.swift: Complete sysinit")

// Make sure the tables exist

print("main.swift: Creating RM Tables")

RMDBTables.sharedInstance.createTables()

print("main.swift: Complete RM Tables")

// project specific tables
//print("main.swift: Creating Project Tables")
//
//PRJDBTables.sharedInstance.createTables()
//
//print("main.swift: Completed Project Tables")

// Add the routes to the server.
var routes: [[String: Any]] = [[String: Any]]()

routes = routes + UserAPI.json.routes
routes = routes + UserWEB.web.routes
routes = routes + InstallationsV1Controller.json.routes
routes = routes + RMStatisticsV1Controller.json.routes
routes = routes + FriendAPI.json.routes
//routes.append(contentsOf: RetailerAPI.json.routes)
//routes.append(contentsOf: ConsumerAPI.json.routes)
//routes.append(contentsOf: AdminAPI.json.routes)

// only if we are not in production
//if !isProduction {
//    routes.append(contentsOf: TestingAPI.json.routes)
//    routes.append(contentsOf: RetailerWEB.web.routes)
//    routes.append(contentsOf: ConsumerWEB.web.routes)
//    routes.append(contentsOf: AdminWEB.web.routes)
//}

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
routes.append(["method":"get", "uri":"/apple-app-site-association", "handler":Handlers.appleAppSiteAssociation])
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
