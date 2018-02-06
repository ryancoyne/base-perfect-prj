//
//  NotificationSettings.swift
//  mobile-template
//
//  Created by Mike Silvers on 2/1/18.
//

class NotificationSettings {
    
    static let sharedInstance = NotificationSettings()
    
    private var _IOS_APPID: String?
    var IOS_APPID : String? {
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

    private var _IOS_APNS_KEY_IDENTIFIER: String?
    var IOS_APNS_KEY_IDENTIFIER : String? {
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

    private var _IOS_APNS_TEAM_IDENTIFIER: String?
    var IOS_APNS_TEAM_IDENTIFIER : String? {
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

    private var _IOS_APNS_PRIVATE_KEY_FILEPATH: String?
    var IOS_APNS_PRIVATE_KEY_FILEPATH : String? {
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
    
}
