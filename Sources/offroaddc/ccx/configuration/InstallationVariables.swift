
import Foundation
import JSONConfigEnhanced

final class InstallationVariables {

    private init() {

        // try the environment variables first
        self.readEnvironment()
        
        // then try the JSON config files
        self.readJSONConfiguration()
        
        // set the defaults if they were not set
        self.setDefaults()

    }
    
    static let sharedInstance = InstallationVariables()

    //MARK: --
    //MARK: Environment configuration processing
    private func readEnvironment() {

        // pull in the system variables for the file locations
        let env_variables = ProcessInfo.processInfo.environment
        
        self.IOS_APNS_KEY_IDENTIFIER       = env_variables["IOS_APNS_KEY_IDENTIFIER"].stringValue
        self.IOS_APNS_PRIVATE_KEY_FILEPATH = env_variables["IOS_APNS_PRIVATE_KEY_FILEPATH"].stringValue
        self.IOS_APNS_TEAM_IDENTIFIER      = env_variables["IOS_APNS_TEAM_IDENTIFIER"].stringValue
        self.IOS_APPID                     = env_variables["IOS_APPID"].stringValue

    }
    
    //MARK: --
    //MARK: JSON configuration file processing
    private func readJSONConfiguration() {
        
        //MARK: --
        //MARK: config file: installation.json
        JSONConfigEnhanced.shared.source = "./config/installation.json"
        if JSONConfigEnhanced.shared.doesSourceFileExist() {
            
            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "ios.IOS_APNS_KEY_IDENTIFIER") as? String {
                self.IOS_APNS_KEY_IDENTIFIER = value
            }
            
            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "ios.IOS_APNS_PRIVATE_KEY_FILEPATH") as? String {
                self.IOS_APNS_PRIVATE_KEY_FILEPATH = value
            }
            
            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "ios.IOS_APNS_TEAM_IDENTIFIER") as? String {
                self.IOS_APNS_TEAM_IDENTIFIER = value
            }
            
            if let value = JSONConfigEnhanced.shared.value(forKeyPath: "ios.IOS_APPID") as? String {
                self.IOS_APPID = value
            }
        }
    }

    //MARK: --
    //MARK: set the defaults for variables
    private func setDefaults() {
        
        // database defaults
        if self.IOS_APNS_KEY_IDENTIFIER == nil {
            self.IOS_APNS_KEY_IDENTIFIER = ""
        }

        if self.IOS_APNS_PRIVATE_KEY_FILEPATH == nil {
            self.IOS_APNS_PRIVATE_KEY_FILEPATH = ""
        }

        if self.IOS_APNS_TEAM_IDENTIFIER == nil {
            self.IOS_APNS_TEAM_IDENTIFIER = ""
        }

        if self.IOS_APPID == nil {
            self.IOS_APPID = ""
        }

    }

    //MARK: --
    //MARK: iOS Notification Variable definitions
    private var _IOS_APNS_KEY_IDENTIFIER: String?
    public var IOS_APNS_KEY_IDENTIFIER: String? {
        get {
            return _IOS_APNS_KEY_IDENTIFIER
        }
        set {
            if newValue != nil {
                _IOS_APNS_KEY_IDENTIFIER = newValue!
            } else {
                _IOS_APNS_KEY_IDENTIFIER = nil
            }
        }
    }

    private var _IOS_APNS_PRIVATE_KEY_FILEPATH: String?
    public var IOS_APNS_PRIVATE_KEY_FILEPATH: String? {
        get {
            return _IOS_APNS_PRIVATE_KEY_FILEPATH
        }
        set {
            if newValue != nil {
                _IOS_APNS_PRIVATE_KEY_FILEPATH = newValue!
            } else {
                _IOS_APNS_PRIVATE_KEY_FILEPATH = nil
            }
        }
    }
    
    private var _IOS_APNS_TEAM_IDENTIFIER: String?
    public var IOS_APNS_TEAM_IDENTIFIER: String? {
        get {
            return _IOS_APNS_TEAM_IDENTIFIER
        }
        set {
            if newValue != nil {
                _IOS_APNS_TEAM_IDENTIFIER = newValue!
            } else {
                _IOS_APNS_TEAM_IDENTIFIER = nil
            }
        }
    }
    
    private var _IOS_APPID: String?
    public var IOS_APPID: String? {
        get {
            return _IOS_APPID
        }
        set {
            if newValue != nil {
                _IOS_APPID = newValue!
            } else {
                _IOS_APPID = nil
            }
        }
    }
    
}
