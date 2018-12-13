
import Foundation
import PerfectLib
import JSONConfigEnhanced

enum ServerEnvironment : String {
    case production = "PROD", development = "DEV", staging = "STAGE"
}

final class EnvironmentVariables {
    
    private init() {

        // try the environment variables first
        self.readEnvironment()
        
        // then try the JSON config files
        self.readJSONConfiguration()
        
        // set the defaults if they were not set
        self.setDefaults()

    }
    
    static let sharedInstance = EnvironmentVariables()

    //MARK: --
    //MARK: Environment configuration processing
    private func readEnvironment() {

        // pull in the system variables for the file locations
        let env_variables = ProcessInfo.processInfo.environment
        
        self.AWSfileURL = env_variables["AWS_FILE_URL"].stringValue
        if self.AWSfileURL != nil {
            self.AWSfileURLProfilePics = "\(self.AWSfileURL!)/profilepics/"
            self.AWSfileURLCompanyPics = "\(self.AWSfileURL!)/companypics/"
        }
        
        self.filesDirectory = env_variables["LOCAL_FILE_PATH"].stringValue
        if self.filesDirectory != nil {
            self.filesDirectoryProfilePics = "\(self.filesDirectory!)/profilepics"
            self.configDirectory = "\(self.filesDirectory!)/config"
        }

        self.filesDirectoryLogs = env_variables["LOCAL_FILE_PATH_LOGS"].stringValue

        self.DB_HOSTNAME = env_variables["DB_HOSTNAME"].stringValue
        self.DB_USERNAME = env_variables["DB_USERNAME"].stringValue
        self.DB_PASSWORD = env_variables["DB_PASSWORD"].stringValue
        self.DB_DATABASE = env_variables["DB_DATABASE"].stringValue
        self.DB_PORT     = env_variables["DB_PORT"].intValue
        
        self.URL_PROTOCOL = env_variables["URL_PROTOCOL"].stringValue
        self.URL_PORT     = env_variables["URL_PORT"].intValue
        self.URL_DOMAIN   = env_variables["URL_DOMAIN"].stringValue

        self.LISTENING_URL_PORT     = env_variables["LISTENING_URL_PORT"].intValue
        self.LISTENING_URL_DOMAIN   = env_variables["LISTENING_URL_DOMAIN"].stringValue

        self.API_DOMAIN       = env_variables["API_DOMAIN"].stringValue
        self.API_PATH         = env_variables["API_PATH"].stringValue
        self.API_URL_PORT     = env_variables["API_URL_PORT"].intValue
        self.API_URL_PROTOCOL = env_variables["API_URL_PROTOCOL"].stringValue

        self.EMAIL_SERVER            = env_variables["EMAIL_SERVER"].stringValue
        self.EMAIL_USERNAME          = env_variables["EMAIL_USERNAME"].stringValue
        self.EMAIL_PASSWORD          = env_variables["EMAIL_PASSWORD"].stringValue
        self.EMAIL_FROM_ADDRESS      = env_variables["EMAIL_FROM_ADDRESS"].stringValue
        self.EMAIL_FROM_DISPLAY_NAME = env_variables["EMAIL_FROM_DISPLAY_NAME"].stringValue

        self.StORMdebug           = env_variables["STORM_DEBUG"].boolValue
        if let serverString = env_variables["SERVER_ENVIRONMENT"].stringValue, let server = ServerEnvironment(rawValue: serverString) {
            self.Server    = server
        }
        self.SessionName          = env_variables["SESSION_NAME"].stringValue
        self.HTTP_DOCUMENT_ROOT   = env_variables["HTTP_DOCUMENT_ROOT"].stringValue

        self.CheckOnStart_Server1 = env_variables["SERVER_1_ON_START"].boolValue
        self.CheckOnStart_Server2 = env_variables["SERVER_2_ON_START"].boolValue
        
//        let public_url = env_variables["SERVER_PUBLIC_URL"].stringValue
//        if !public_url.isEmptyOrNil {
//
//            self.PublicServerApiURL = URL(string: public_url!)
//
//        } else {
//            self.PublicServerApiURL = nil
//        }

    }
    
    //MARK: --
    //MARK: JSON configuration file processing
    private func readJSONConfiguration() {
        
        // lets see the PWD
        print("PWD: \(Dir.workingDir.path)")

        //MARK: --
        //MARK: config file: main.json
        // here is where we look to see if there is a JSON file with settings
        if self.configDirectory.isNotNil {
            JSONConfigEnhanced.shared.source = "\(self.configDirectory!)/main.json"
        } else {
            JSONConfigEnhanced.shared.source = "\(Dir.workingDir.path)config/main.json"
        }
        if JSONConfigEnhanced.shared.doesSourceFileExist() {
            
            // the first thing we are going to do is to parse out the servers and services for API connections
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "services") {
            if let value = JSONConfigEnhanced.shared.json(forKey: "services") {

                // Load the entire document and pull out the services section to process
                let file = File(JSONConfigEnhanced.shared.source!)

                do {
                    try file.open()
                    defer {
                        file.close()
                    }
                
                    var thedata:String?
                    try thedata = file.readString()

//                    print(thedata)
                    // this section will parse out the servers and add them to the service
                    var json:[String:Any]?
                    if thedata.isNotNil {
                        json = try? JSONSerialization.jsonObject(with: thedata!.data(using: String.Encoding.utf16)!, options: .allowFragments) as! [String:Any]
//                        var servers:[String:Any]?
//                        if let s = json?["services"] {
//                            let ss = s as! [String:Any]
//                            servers = ss
//                        }
                        
//                        if servers.isNotNil {
//                            // process the servers individually
//                            var tmpConnectionServices:[Service] = []
//                            for (_,value) in servers! {
//                                if let _value = value as? [String:Any] {
//                                    if let tmpsrv = Service(json: _value) {
//                                        // this is where we are adding the connection services to the mix
//                                        tmpConnectionServices.append(tmpsrv)
//                                    }
//                                }
//                            }
//                            // if we parsed services, then save them
//                            if tmpConnectionServices.count > 0 {
//                                self.ConnectionServices = tmpConnectionServices
//                            } else {
//                                self.ConnectionServices = nil
//                            }
//                        }
                        
                    }
                } catch {
                    print("There was a problem with the conversion of the servers.")
                }
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "aws.AWS_FILE_URL") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "aws")?["AWS_FILE_URL"] as? String {
                self.AWSfileURL = value
            }

//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "localfiles.LOCAL_FILE_PATH") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "localfiles")?["LOCAL_FILE_PATH"] as? String {
                self.filesDirectory = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "localfiles.LOCAL_FILE_PATH_LOGS") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "localfiles")?["LOCAL_FILE_PATH_LOGS"] as? String {
                self.filesDirectoryLogs = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "database.DB_HOSTNAME") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "database")?["DB_HOSTNAME"] as? String {
                self.DB_HOSTNAME = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "database.DB_USERNAME") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "database")?["DB_USERNAME"] as? String {
                self.DB_USERNAME = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "database.DB_PASSWORD") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "database")?["DB_PASSWORD"] as? String {
                self.DB_PASSWORD = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "database.DB_DATABASE") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "database")?["DB_DATABASE"] as? String {
                self.DB_DATABASE = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "database.DB_PORT") as? Int {
            if let value = JSONConfigEnhanced.shared.json(forKey: "database")?["DB_PORT"] as? Int {
                self.DB_PORT = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "url.URL_PROTOCOL") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "url")?["URL_PROTOCOL"] as? String {
                self.URL_PROTOCOL = value
            }
            
            if let value = JSONConfigEnhanced.shared.json(forKey: "url")?["URL_DOMAIN"] as? String {
                self.URL_DOMAIN = value
            }
            
            if let value = JSONConfigEnhanced.shared.json(forKey: "url")?["URL_PORT"] as? Int {
                self.URL_PORT = value
            }
            
            if let value = JSONConfigEnhanced.shared.json(forKey: "url")?["LISTENING_URL_DOMAIN"] as? String {
                self.LISTENING_URL_DOMAIN = value
            }
            
            if let value = JSONConfigEnhanced.shared.json(forKey: "url")?["LISTENING_URL_PORT"] as? Int {
                self.LISTENING_URL_PORT = value
            }
            
            if let value = JSONConfigEnhanced.shared.json(forKey: "security")?["CHECK"] as? String {
                self.CHECK = value
            }

//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "api.API_DOMAIN") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "api")?["API_DOMAIN"] as? String {
                self.API_DOMAIN = value
            }

            if let value = JSONConfigEnhanced.shared.json(forKey: "api")?["API_PATH"] as? String {
                self.API_PATH = value
            }

//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "api.API_URL_PROTOCOL") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "api")?["API_URL_PROTOCOL"] as? String {
                self.API_URL_PROTOCOL = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "api.API_URL_PORT") as? Int {
            if let value = JSONConfigEnhanced.shared.json(forKey: "api")?["API_URL_PORT"] as? Int {
                self.API_URL_PORT = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "email.EMAIL_SERVER") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "email")?["EMAIL_SERVER"] as? String {
                self.EMAIL_SERVER = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "email.EMAIL_USERNAME") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "email")?["EMAIL_USERNAME"] as? String {
                self.EMAIL_USERNAME = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "email.EMAIL_PASSWORD") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "email")?["EMAIL_PASSWORD"] as? String {
                self.EMAIL_PASSWORD = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "email.EMAIL_FROM_ADDRESS") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "email")?["EMAIL_FROM_ADDRESS"] as? String {
                self.EMAIL_FROM_ADDRESS = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "email.EMAIL_FROM_DISPLAY_NAME") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "email")?["EMAIL_FROM_DISPLAY_NAME"] as? String {
                self.EMAIL_FROM_DISPLAY_NAME = value
            }

            if let value = JSONConfigEnhanced.shared.json(forKey: "email")?["RECOMMEND_RETAILER_EMAIL"] as? String {
                self.RECOMMEND_RETAILER_EMAIL = value
            }

            if let value = JSONConfigEnhanced.shared.json(forKey: "email")?["RECOMMEND_RETAILER_SUBJECT"] as? String {
                self.RECOMMEND_RETAILER_SUBJECT = value
            }

            if let value = JSONConfigEnhanced.shared.json(forKey: "email")?["RECOMMEND_RETAILER_DISPLAY_NAME"] as? String {
                self.RECOMMEND_RETAILER_DISPLAY_NAME = value
            }

//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "misc.STORM_DEBUG") as? Bool {
            if let value = JSONConfigEnhanced.shared.json(forKey: "misc")?["STORM_DEBUG"] as? Bool {
                self.StORMdebug = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "misc.SERVER_ENVIRONMENT") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "misc")?["SERVER_ENVIRONMENT"] as? String, let server = ServerEnvironment(rawValue: value) {
                self.Server = server
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "misc.SESSION_NAME") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "misc")?["SESSION_NAME"] as? String {
                self.SessionName = value
            }
            
//            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "misc.HTTP_DOCUMENT_ROOT") as? String {
            if let value = JSONConfigEnhanced.shared.json(forKey: "misc")?["HTTP_DOCUMENT_ROOT"] as? String {
                self.HTTP_DOCUMENT_ROOT = value
            }
            
            if let value = JSONConfigEnhanced.shared.json(forKey: "misc")?["SERVER_1_ON_START"] as? Bool {
                self.CheckOnStart_Server1 = value
            }

            if let value = JSONConfigEnhanced.shared.json(forKey: "misc")?["SERVER_2_ON_START"] as? Bool {
                self.CheckOnStart_Server2 = value
            }

            if let value = JSONConfigEnhanced.shared.json(forKey: "misc")?["IMAGE_BASE_URL"] as? String {
                self.ImageBaseURL = value
            }

        }
    }

    //MARK: --
    //MARK: set the defaults for variables
    private func setDefaults() {
        
        // AWS defaults
        if self.AWSfileURL == nil {
            self.AWSfileURL = ""
        }

        if self.AWSfileURLProfilePics == nil {
            self.AWSfileURLProfilePics = ""
        }

        if self.AWSfileURLCompanyPics == nil {
            self.AWSfileURLCompanyPics = ""
        }

        // file directory defaults
        if self.filesDirectory == nil {
            self.filesDirectory = "./files"
        }
        
        if self.filesDirectoryProfilePics == nil {
            self.filesDirectoryProfilePics = "/profilepics"
        }

        if self.filesDirectoryLogs == nil {
            self.filesDirectoryLogs = "./logs"
        }

        // database defaults
        if self.DB_HOSTNAME == nil {
            self.DB_HOSTNAME = "localhost"
        }

        if self.DB_USERNAME == nil {
            self.DB_USERNAME = "root"
        }

        if self.DB_PASSWORD == nil {
            self.DB_PASSWORD = ""
        }

        if self.DB_DATABASE == nil {
            self.DB_DATABASE = "test_db"
        }

        if self.DB_PORT == nil {
            self.DB_PORT = 5432
        }

        // email defaults
        if self.EMAIL_USERNAME == nil {
            self.EMAIL_USERNAME = "root"
        }
        
        if self.EMAIL_PASSWORD == nil {
            self.EMAIL_PASSWORD = ""
        }
        
        if self.EMAIL_FROM_ADDRESS == nil {
            self.EMAIL_FROM_ADDRESS = "server@test.com"
        }
        
        if self.EMAIL_FROM_DISPLAY_NAME == nil {
            self.EMAIL_FROM_DISPLAY_NAME = "Mobile Server Email"
        }

        // URL defaults
        if self.URL_PROTOCOL == nil {
            self.URL_PROTOCOL = "http"
        }

        if self.URL_PORT == nil {
            self.URL_PORT = 8080
        }

        if self.URL_DOMAIN == nil {
            self.URL_DOMAIN = "localhost"
        }

        // here is where we set the defaults of the initial is nil
        if self.API_DOMAIN == nil {
            self.API_DOMAIN = "localhost"
        }

        if self.API_PATH == nil {
            self.API_PATH = "/api"
        }

        if self.API_URL_PROTOCOL == nil {
            self.API_URL_PROTOCOL = "http"
        }

        if self.API_URL_PORT == nil {
            self.API_URL_PORT = 8080
        }
        
        // general environment variables
        if self.StORMdebug == nil {
            self.StORMdebug = false
        }
        
        if self.Server == nil {
            self.Server = ServerEnvironment.development
        }

        if self.SessionName == nil {
            self.SessionName = "PerfectSession"
        }

        if self.HTTP_DOCUMENT_ROOT == nil {
            self.HTTP_DOCUMENT_ROOT = "./webroot"
        }

        if self.httpRequestLog == nil {
            self.httpRequestLog = "\(self.filesDirectoryLogs!)/request.log"
        }

        if self.mainLog == nil {
            self.mainLog = "\(self.filesDirectoryLogs!)/main.log"
        }
        
        if self.CheckOnStart_Server1 == nil {
            self.CheckOnStart_Server1 = false
        }

        if self.CheckOnStart_Server2 == nil {
            self.CheckOnStart_Server2 = false
        }

    }

    //MARK: --
    //MARK: Database Variable definitions
    private var _DB_USERNAME: String?
    public var DB_USERNAME: String? {
        get {
            return _DB_USERNAME
        }
        set {
            if newValue != nil {
                _DB_USERNAME = newValue!
            } else {
                _DB_USERNAME = nil
            }
        }
    }

    private var _DB_HOSTNAME: String?
    public var DB_HOSTNAME: String? {
        get {
            return _DB_HOSTNAME
        }
        set {
            if newValue != nil {
                _DB_HOSTNAME = newValue!
            } else {
                _DB_HOSTNAME = nil
            }
        }
    }
    
    private var _DB_PASSWORD: String?
    public var DB_PASSWORD: String? {
        get {
            return _DB_PASSWORD
        }
        set {
            if newValue != nil {
                _DB_PASSWORD = newValue!
            } else {
                _DB_PASSWORD = nil
            }
        }
    }
    
    private var _DB_DATABASE: String?
    public var DB_DATABASE: String? {
        get {
            return _DB_DATABASE
        }
        set {
            if newValue != nil {
                _DB_DATABASE = newValue!
            } else {
                _DB_DATABASE = nil
            }
        }
    }
    
    private var _DB_PORT: Int?
    public var DB_PORT: Int? {
        get {
            return _DB_PORT
        }
        set {
            if newValue != nil {
                _DB_PORT = newValue!
            } else {
                _DB_PORT = nil
            }
        }
    }

    //MARK: --
    //MARK: Request retailer Email
    private var _RECOMMEND_RETAILER_EMAIL: String?
    public var RECOMMEND_RETAILER_EMAIL: String? {
        get {
            return _RECOMMEND_RETAILER_EMAIL
        }
        set {
            if newValue != nil {
                _RECOMMEND_RETAILER_EMAIL = newValue!
            } else {
                _RECOMMEND_RETAILER_EMAIL = nil
            }
        }
    }

    private var _RECOMMEND_RETAILER_SUBJECT: String?
    public var RECOMMEND_RETAILER_SUBJECT: String? {
        get {
            return _RECOMMEND_RETAILER_SUBJECT
        }
        set {
            if newValue != nil {
                _RECOMMEND_RETAILER_SUBJECT = newValue!
            } else {
                _RECOMMEND_RETAILER_SUBJECT = nil
            }
        }
    }
    
    private var _RECOMMEND_RETAILER_DISPLAY_NAME: String?
    public var RECOMMEND_RETAILER_DISPLAY_NAME: String? {
        get {
            return _RECOMMEND_RETAILER_DISPLAY_NAME
        }
        set {
            if newValue != nil {
                _RECOMMEND_RETAILER_DISPLAY_NAME = newValue!
            } else {
                _RECOMMEND_RETAILER_DISPLAY_NAME = nil
            }
        }
    }
    
    //MARK: --
    //MARK: Email Variable definitions
    private var _EMAIL_SERVER: String?
    public var EMAIL_SERVER: String? {
        get {
            return _EMAIL_SERVER
        }
        set {
            if newValue != nil {
                _EMAIL_SERVER = newValue!
            } else {
                _EMAIL_SERVER = nil
            }
        }
    }
    
    private var _EMAIL_USERNAME: String?
    public var EMAIL_USERNAME: String? {
        get {
            return _EMAIL_USERNAME
        }
        set {
            if newValue != nil {
                _EMAIL_USERNAME = newValue!
            } else {
                _EMAIL_USERNAME = nil
            }
        }
    }
    
    private var _EMAIL_PASSWORD: String?
    public var EMAIL_PASSWORD: String? {
        get {
            return _EMAIL_PASSWORD
        }
        set {
            if newValue != nil {
                _EMAIL_PASSWORD = newValue!
            } else {
                _EMAIL_PASSWORD = nil
            }
        }
    }
    
    private var _EMAIL_FROM_ADDRESS: String?
    public var EMAIL_FROM_ADDRESS: String? {
        get {
            return _EMAIL_FROM_ADDRESS
        }
        set {
            if newValue != nil {
                _EMAIL_FROM_ADDRESS = newValue!
            } else {
                _EMAIL_FROM_ADDRESS = nil
            }
        }
    }
    
    private var _EMAIL_FROM_DISPLAY_NAME: String?
    public var EMAIL_FROM_DISPLAY_NAME: String? {
        get {
            return _EMAIL_FROM_DISPLAY_NAME
        }
        set {
            if newValue != nil {
                _EMAIL_FROM_DISPLAY_NAME = newValue!
            } else {
                _EMAIL_FROM_DISPLAY_NAME = nil
            }
        }
    }
    
    //MARK: --
    //MARK: Security
    private var _CHECK: String?
    public var CHECK: String? {
        get {
            return _CHECK
        }
        set {
            if newValue != nil {
                _CHECK = newValue!
            } else {
                _CHECK = nil
            }
        }
    }

    //MARK: --
    //MARK: URL Variable definitions
    private var _URL_PROTOCOL: String?
    public var URL_PROTOCOL: String? {
        get {
            return _URL_PROTOCOL
        }
        set {
            if newValue != nil, newValue?.lowercased() == "http" || newValue?.lowercased() == "https" {
                _URL_PROTOCOL = newValue?.lowercased()
            } else {
                _URL_PROTOCOL = nil
            }
        }
    }
    
    private var _URL_PORT: Int?
    public var URL_PORT: Int? {
        get {
            return _URL_PORT
        }
        set {
            if newValue != nil {
                _URL_PORT = newValue!
            } else {
                _URL_PORT = nil
            }
        }
    }
    
    private var _URL_DOMAIN: String?
    public var URL_DOMAIN: String? {
        get {
            return _URL_DOMAIN
        }
        set {
            if newValue != nil {
                _URL_DOMAIN = newValue!
            } else {
                _URL_DOMAIN = nil
            }
        }
    }
    
    private var _Public_URL_Full_Domain:String?
    public var Public_URL_Full_Domain: String? {
        get {
            if _Public_URL_Full_Domain.isNil {
                if EnvironmentVariables.sharedInstance.URL_PORT == 80 || EnvironmentVariables.sharedInstance.URL_PORT == 443 {
                    
                    var burl = EnvironmentVariables.sharedInstance.URL_PROTOCOL!
                    burl.append("://")
                    burl.append(EnvironmentVariables.sharedInstance.URL_DOMAIN!)
                    _Public_URL_Full_Domain                         = burl
                    
                } else {
                    
                    var burl = EnvironmentVariables.sharedInstance.URL_PROTOCOL!
                    burl.append("://")
                    burl.append(EnvironmentVariables.sharedInstance.URL_DOMAIN!)
                    burl.append(":")
                    burl.append("\(EnvironmentVariables.sharedInstance.URL_PORT!)")
                    _Public_URL_Full_Domain                         = burl
                }
            }
            
            return _Public_URL_Full_Domain
        }
    }

    private var _LISTENING_URL_PORT: Int?
    public var LISTENING_URL_PORT: Int? {
        get {
            return _LISTENING_URL_PORT
        }
        set {
            if newValue != nil {
                _LISTENING_URL_PORT = newValue!
            } else {
                _LISTENING_URL_PORT = nil
            }
        }
    }
    
    private var _LISTENING_URL_DOMAIN: String?
    public var LISTENING_URL_DOMAIN: String? {
        get {
            return _LISTENING_URL_DOMAIN
        }
        set {
            if newValue != nil {
                _LISTENING_URL_DOMAIN = newValue!
            } else {
                _LISTENING_URL_DOMAIN = nil
            }
        }
    }

    private var _API_DOMAIN: String?
    public var API_DOMAIN: String? {
        get {
            return _API_DOMAIN
        }
        set {
            if newValue != nil {
                _API_DOMAIN = newValue!
            } else {
                _API_DOMAIN = nil
            }
        }
    }

    private var _API_PATH: String?
    public var API_PATH: String? {
        get {
            return _API_PATH
        }
        set {
            if newValue != nil {
                _API_PATH = newValue!
            } else {
                _API_PATH = nil
            }
        }
    }
    
    private var _API_URL_PORT: Int?
    public var API_URL_PORT: Int? {
        get {
            return _API_URL_PORT
        }
        set {
            if newValue != nil {
                _API_URL_PORT = newValue!
            } else {
                _API_URL_PORT = nil
            }
        }
    }

    private var _API_URL_PROTOCOL: String?
    public var API_URL_PROTOCOL: String? {
        get {
            return _API_URL_PROTOCOL
        }
        set {
            if newValue != nil, newValue?.lowercased() == "http" || newValue?.lowercased() == "https" {
                _API_URL_PROTOCOL = newValue?.lowercased()
            } else {
                _API_URL_PROTOCOL = nil
            }
        }
    }

    //MARK: --
    //MARK: AWS Variable definitions
    private var _AWSfileURL: String?
    public var AWSfileURL: String? {
        get {
            return _AWSfileURL
        }
        set {
            if newValue != nil {
                _AWSfileURL = newValue!
            } else {
                _AWSfileURL = nil
            }
        }
    }

    private var _AWSfileURLProfilePics: String?
    public var AWSfileURLProfilePics: String? {
        get {
            return _AWSfileURLProfilePics
        }
        set {
            if newValue != nil {
                _AWSfileURLProfilePics = newValue!
            } else {
                _AWSfileURLProfilePics = nil
            }
        }
    }

    private var _AWSfileURLCompanyPics: String?
    public var AWSfileURLCompanyPics: String? {
        get {
            return _AWSfileURLCompanyPics
        }
        set {
            if newValue != nil {
                _AWSfileURLCompanyPics = newValue!
            } else {
                _AWSfileURLCompanyPics = nil
            }
        }
    }

    //MARK: --
    //MARK: Local file access variable definitions
    private var _configDirectory: String?
    public var configDirectory: String? {
        get {
            return _configDirectory
        }
        set {
            if newValue != nil {
                _configDirectory = newValue!
            } else {
                _configDirectory = nil
            }
        }
    }

    private var _filesDirectory: String?
    public var filesDirectory: String? {
        get {
            return _filesDirectory
        }
        set {
            if newValue != nil {
                _filesDirectory = newValue!
            } else {
                _filesDirectory = nil
            }
        }
    }
    
    private var _filesDirectoryProfilePics: String?
    public var filesDirectoryProfilePics: String? {
        get {
            return _filesDirectoryProfilePics
        }
        set {
            if newValue != nil {
                _filesDirectoryProfilePics = newValue!
            } else {
                _filesDirectoryProfilePics = nil
            }
        }
    }

    private var _filesDirectoryLogs: String?
    public var filesDirectoryLogs: String? {
        get {
            return _filesDirectoryLogs
        }
        set {
            if newValue != nil {
                _filesDirectoryLogs = newValue!
            } else {
                _filesDirectoryLogs = nil
            }
        }
    }

    //MARK: --
    //MARK: misc variable definitions
    private var _CheckOnStart_Server1: Bool?
    public var CheckOnStart_Server1: Bool? {
        get {
            return _CheckOnStart_Server1
        }
        set {
            if newValue != nil {
                _CheckOnStart_Server1 = newValue!
            } else {
                _CheckOnStart_Server1 = nil
            }
        }
    }

    private var _CheckOnStart_Server2: Bool?
    public var CheckOnStart_Server2: Bool? {
        get {
            return _CheckOnStart_Server2
        }
        set {
            if newValue != nil {
                _CheckOnStart_Server2 = newValue!
            } else {
                _CheckOnStart_Server2 = nil
            }
        }
    }

    private var _StORMdebug: Bool?
    public var StORMdebug: Bool? {
        get {
            return _StORMdebug
        }
        set {
            if newValue != nil {
                _StORMdebug = newValue!
            } else {
                _StORMdebug = nil
            }
        }
    }
    
    private var _Server: String?
    public var Server: ServerEnvironment? {
        get {
            if _Server.isNotNil {
                return ServerEnvironment(rawValue: _Server!)
            } else {
                return nil
            }
        }
        set {
            _Server = newValue?.rawValue
        }
    }
    
    private var _SessionName: String?
    public var SessionName: String? {
        get {
            return _SessionName
        }
        set {
            if newValue != nil {
                _SessionName = newValue!
            } else {
                _SessionName = nil
            }
        }
    }
    
    private var _HTTP_DOCUMENT_ROOT: String?
    public var HTTP_DOCUMENT_ROOT: String? {
        get {
            return _HTTP_DOCUMENT_ROOT
        }
        set {
            if newValue != nil {
                _HTTP_DOCUMENT_ROOT = newValue!
            } else {
                _HTTP_DOCUMENT_ROOT = nil
            }
        }
    }

    private var _httpRequestLog: String?
    public var httpRequestLog: String? {
        get {
            return _httpRequestLog
        }
        set {
            if newValue != nil {
                _httpRequestLog = newValue!
            } else {
                _httpRequestLog = nil
            }
        }
    }

    private var _mainLog: String?
    public var mainLog: String? {
        get {
            return _mainLog
        }
        set {
            if newValue != nil {
                _mainLog = newValue!
            } else {
                _mainLog = nil
            }
        }
    }

    private var _PublicServerApiURL: URL?
    public var PublicServerApiURL: URL? {
        get {
            if _PublicServerApiURL.isNil {
                if EnvironmentVariables.sharedInstance.API_URL_PORT == 80 || EnvironmentVariables.sharedInstance.API_URL_PORT == 443 {
                    
                    var burl = EnvironmentVariables.sharedInstance.API_URL_PROTOCOL!
                    burl.append("://")
                    burl.append(EnvironmentVariables.sharedInstance.API_DOMAIN!)
                    burl.append("/")
                    burl.append(EnvironmentVariables.sharedInstance.API_PATH!)
                    burl.append("/")
                    _PublicServerApiURL                         = URL(string: burl)

                } else {
                    
                    var burl = EnvironmentVariables.sharedInstance.API_URL_PROTOCOL!
                    burl.append("://")
                    burl.append(EnvironmentVariables.sharedInstance.API_DOMAIN!)
                    burl.append(":")
                    burl.append("\(EnvironmentVariables.sharedInstance.API_URL_PORT!)")
                    burl.append("/")
                    burl.append(EnvironmentVariables.sharedInstance.API_PATH!)
                    burl.append("/")
                    _PublicServerApiURL                         = URL(string: burl)
                
                }
            }
            
            return _PublicServerApiURL
        }
//        set {
//            if newValue != nil {
//                _PublicServerApiURL = newValue!
//            } else {
//                _PublicServerApiURL = nil
//            }
//        }
    }

    private var _ImageBaseURL: String?
    public var ImageBaseURL: String? {
        get {
            return _ImageBaseURL
        }
        set {
            if newValue != nil {
                _ImageBaseURL = newValue!
            } else {
                _ImageBaseURL = nil
            }
        }
    }

//    private var _ConnectionServices: [Service]?
//    public var ConnectionServices: [Service]? {
//        get {
//            return _ConnectionServices
//        }
//        set {
//            if newValue != nil {
//                _ConnectionServices = newValue!
//            } else {
//                _ConnectionServices = nil
//            }
//        }
//    }


    
}
