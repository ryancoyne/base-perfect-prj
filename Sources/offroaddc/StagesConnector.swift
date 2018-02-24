//
//  StagesConnector.swift
//  offroaddcPackageDescription
//
//  Created by Mike Silvers on 2/21/18.
//

import Foundation
import PerfectCURL

class StagesConnecter {

    struct endpoints {
        static let auth = "/auth/{id}"
    }
    
    // Singleton configuration
    static let sharedInstance = StagesConnecter()
    
    private init() {
        
    }

    var services:Service?
    private var _authToken:[String:Any] = [:]
    
    @discardableResult
    func bearerToken(location:String, token: String? = nil)->String? {
        // if you send in a token, the token is set.  If ysou send in nil, the token is returned
        if token == nil, let returntoken = self._authToken[location] {
            // setup the token for the proper return in format for the header
            var thereturn = "Bearer: "
            thereturn.append((returntoken as! String))

            return thereturn
            
        } else if token != nil {
            // set the token
            self._authToken[location] = token!
        } else {
            return nil
        }
        return nil
    }
    
    // This will allow us to internally manage the service itself
    private var _service_id:Int = 0
    public var service_id:Int {
        get {
            return self._service_id
        }
        set {
            self._service_id = newValue
        }
    }
    
    // This function will check to see if we are logged in to a location
    // If not it will attempt to login to the location
    @discardableResult
    func login(location: String? = nil)->Bool  {
        
        // nil is sent in - so login to everything
        if location == nil {
            return self.remoteLogin()
        }
        
        if self._authToken[location!] != nil {
            return true
        } else {
            // do the login process and make sure the location was successful
            if self.remoteLogin(), self._authToken[location!] != nil {
                return true
            }
        }

        // all else failed
        return false
        
    }
    
    fileprivate func remoteLogin()->Bool {
        
        // make sure there are valid servers
        if StagesConnecter.sharedInstance.services == nil || StagesConnecter.sharedInstance.services?.servers == nil {
            // there are no services listed - we can not make the call
            return false
        }
        
        // make sure there are valid username and passwords
        if StagesConnecter.sharedInstance.services?.username == nil ||
            StagesConnecter.sharedInstance.services?.password == nil {
            return false
        }
        
        // this will indicate if we had a successful login for any location
        var returnsuccess = false
        
        // there is at least one service in the pack here (we checked before getting here)
        for serv in StagesConnecter.sharedInstance.services!.servers! {
            // lets get each ID token
            var urltouse = serv.server_url!
            urltouse.append(endpoints.auth)
            
            urltouse = urltouse.stringByReplacing(string: "{id}", withString: serv.location_service_id!)

            // lets get the token
            let requestJSON:[String:Any] = ["ClientId":self.services!.username!,"ClientSecret":self.services!.password!]
            
            do {
                
                let jsonRequest = try requestJSON.jsonEncodedString()

                // do the sync request for the authentication process
                let response = try CURLRequest(urltouse, .failOnError,
                                               .addHeader(.contentType, "application/json"),
                                               .postString(jsonRequest)
                    ).perform()
                
                self.bearerToken(location: serv.location_service_id!, token: response.bodyString)
                print("Location: \(serv.location_service_id!) Token: \(response.bodyString)")
                returnsuccess = true
                
            } catch {
                print("Error during the curl process: \(error.localizedDescription)")
            }
        }
        
        // true if one of the login processes was successful
        return returnsuccess
        
    }

    static func retrieveClasses(location: String) {
        
    }

    static func retrieveUsers(location: String) {
        
    }

    static func retrieveBikeAssignments(location: String) {
        
    }

}

