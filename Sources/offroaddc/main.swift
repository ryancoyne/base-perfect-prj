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

// Messaging:  https://github.com/flightonary/Moscapsule (iOS side)

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
switch EnvironmentVariables.sharedInstance.ServerEnvironment!.uppercased() {
    case "PROD":
        isProduction = true
    default:
        isProduction = false
}

// if the notifications directory exists, lets set it up
let notesettings = NotificationSettings()
if CCXServiceClass.doesDirectoryExist(Dir("ccx/installations"), create: false) {
    notesettings.IOS_APNS_KEY_IDENTIFIER       = InstallationVariables.sharedInstance.IOS_APNS_KEY_IDENTIFIER!
    notesettings.IOS_APNS_PRIVATE_KEY_FILEPATH = InstallationVariables.sharedInstance.IOS_APNS_PRIVATE_KEY_FILEPATH!
    notesettings.IOS_APNS_TEAM_IDENTIFIER      = InstallationVariables.sharedInstance.IOS_APNS_TEAM_IDENTIFIER!
    notesettings.IOS_APPID                     = InstallationVariables.sharedInstance.IOS_APPID!
}

// var notonlocal = true

RequestLogFile.location = EnvironmentVariables.sharedInstance.httpRequestLog!
LogFile.location = EnvironmentVariables.sharedInstance.mainLog!

// print out the system environment variables
let env_variables = ProcessInfo.processInfo.environment
for (key, value) in env_variables {
    print("Process Info: key: \(key), value: \(value)")
}


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

var baseURL = ""

if EnvironmentVariables.sharedInstance.API_URL_PORT != 80, EnvironmentVariables.sharedInstance.API_URL_PORT != 443 {
    var burl = EnvironmentVariables.sharedInstance.URL_PROTOCOL!
    burl.append("://")
    burl.append(EnvironmentVariables.sharedInstance.URL_DOMAIN!)
    burl.append(":")
    burl.append("\(EnvironmentVariables.sharedInstance.URL_PORT!)")
    burl.append("/")
    AuthenticationVariables.baseURL =  burl

    burl = EnvironmentVariables.sharedInstance.API_URL_PROTOCOL!
    burl.append("://")
    burl.append(EnvironmentVariables.sharedInstance.API_DOMAIN!)
    burl.append(":")
    burl.append("\(EnvironmentVariables.sharedInstance.API_URL_PORT!)")
    burl.append("/")
    baseURL                         = burl
    
} else {
    var burl = EnvironmentVariables.sharedInstance.URL_PROTOCOL!
    burl.append("://")
    burl.append(EnvironmentVariables.sharedInstance.URL_DOMAIN!)
    AuthenticationVariables.baseURL = burl
    
    burl = EnvironmentVariables.sharedInstance.API_URL_PROTOCOL!
    burl.append("://")
    burl.append(EnvironmentVariables.sharedInstance.API_DOMAIN!)
    burl.append("/")
    baseURL                         = burl
    
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
for service in EnvironmentVariables.sharedInstance.ConnectionServices! {
    
    if let srv_id = service.service_id {
        switch srv_id {
        case 1:
            StagesConnecter.sharedInstance.services = service
            StagesConnecter.sharedInstance.login()
            
            // GET USERS
            StagesConnecter.sharedInstance.retrieveUsers()
            
        default:
            // not really doing anything here as this should not occur
            print("This should not occur, but it did.  service_id: \(srv_id)")
        }
    }
}

//MARK:-
//MARK: Server configuration
var confData: [String:[[String:Any]]] = [
    "servers": [
        [
            "name":EnvironmentVariables.sharedInstance.URL_DOMAIN!,
            "port":EnvironmentVariables.sharedInstance.URL_PORT!,
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

