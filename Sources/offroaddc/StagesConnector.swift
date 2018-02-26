//
//  StagesConnector.swift
//  offroaddcPackageDescription
//
//  Created by Mike Silvers on 2/21/18.
//

import StORM
import Foundation
import PerfectCURL
import PostgresStORM
import JSONConfigEnhanced

class StagesConnecter {

    struct endpoints {
        static let auth = "/auth/{id}"
        static let users = "/users"
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
            var rt = returntoken as! String
            rt = rt.replacingOccurrences(of: "\"", with: "")
            let thereturn = "Bearer \(rt)"

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
                let response = try CURLRequest(urltouse,
//                                               .failOnError,
                                               .httpMethod(.post),
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

    func retrieveClasses(location: String) {
        
    }

    func retrieveUsers(location: String? = nil) {
        
        // if we do not have the servers definition - get outta here
        if self.services!.servers == nil {
            return
        }
        
        
//        "Phone": 12022463657,
//        "NickName": ShutUpLegs,
//        "FirstName": Tammar,
//        "Weight": 60.78137758,
//        "Gender": Female,
//        "LastName": Berger,
//        "Email": tammar.berger@gmail.com,
//        "Id": 8640
        
        // the API is the same for all - the token is what makes it work for the location
        
        // lets process all users from all locations
        for serv in self.services!.servers! {
            
            if location != nil && serv.location_service_id?.hashValue != location?.hashValue {
                continue
            }
            
            // grab the users from the location
            var urltouse = serv.server_url!
            urltouse.append(endpoints.users)
            
            // grab the token string
            if let tokenString = self.bearerToken(location: serv.location_service_id!) {
                do {
                    
                    // run thru the list of users
                    var start = 0
                    var total = 0
                    let increment = 50
                    var wearedone = false
                    
                    while !wearedone {

                        var thequery = urltouse
                        thequery.append("/?take=")
                        thequery.append(String(increment))

                        if total > 0 {
                            thequery.append("&skip=")
                            thequery.append(String(total))
                        }

                        print("The users query: \(thequery)")
                        
                        do {
                            let curlrequest = CURLRequest(thequery,
                                                          .httpMethod(.get),
                                                          .addHeaders([(CURLRequest.Header.Name.custom(name: "Content-Type"), "application/json"),
                                                                   (CURLRequest.Header.Name.custom(name: "Authorization"), tokenString)])
                            )

                            // do the sync request for the authentication process
                            let response = try curlrequest.perform().bodyString
                        
//                            let resp = try response.jsonDecode()
//                            print("Users Response: \(resp)")
                            
                            let userarray:[[String:Any]] = try! JSONSerialization.jsonObject(with: response.data(using: String.Encoding.utf16)!, options: .allowFragments) as! [[String:Any]]

                            var updateduserarray:[[String:Any]] = []

                            // update the dictionary to use our common key values
                            for d in userarray {

                                var tmpd:[String:Any] = [:]
                                
                                print("Phone: \(d["Phone"])")
                                
                                
                                
                                if let value = d["Phone"] as? String {
                                    tmpd["phone"] = value
                                }

                                if let value = d["Weight"] as? Float {
                                    tmpd["weight"] = value
                                }

                                if let value = d["NickName"] as? String {
                                    tmpd["nickname"] = value
                                }

                                if let value = d["FirstName"] as? String {
                                    tmpd["name_first"] = value
                                }
                                
                                if let value = d["LastName"] as? String {
                                    tmpd["name_last"] = value
                                }
                                
                                if let value = d["Email"] as? String {
                                    tmpd["email"] = value
                                }
                                
                                if let value = d["NickName"] as? String {
                                    tmpd["nickname"] = value
                                }
                                
                                tmpd["source"] = "stages"
                                
                                updateduserarray.append(tmpd)

                            }
                            
                            // process the user array
                            self.processUserArray(userarray: updateduserarray)

                            total = total + userarray.count
                            
                            if userarray.count < increment || userarray.count == 0 {
                                print("Total records: \(total)")
                                wearedone = true
                            }

                        } catch {
                            print("Error during the curl process: \(error.localizedDescription)")
                            wearedone = true
                        }
                    }

                    }
            }
        }
    }
    
    func processUserArray(userarray:[[String:Any]]) {
        
        // spin theu the array and process each user.
        for user in userarray {
            
            print("User: \(user)")
            
            let thisuser = UsersRaw()
            thisuser.fromDictionary(sourceDictionary: user)
            
            var sql:String?
            
            // first check to see if there is a user in the raw table
            if let useremail = user["email"].stringValue {
                sql = "SELECT id FROM users_raw WHERE email = '"
                sql!.append(useremail)
                sql!.append("'")
            } else if  let userphone = user["phone"].intValue {
                sql = "SELECT id FROM users_raw WHERE phone = "
                sql!.append(String(userphone))
            }

            if sql.isNotNil {
                
                let raw = UsersRaw()
                
                do {
                    
                    let raw_results = try raw.sqlRows(sql!, params: [])

                    if raw_results.count == 0 {
                        try? thisuser.save()
                    }
                    
// ************ // IN THE FUTURE: MAKE CHANGES ID THEY DIFFER
                    
//                    for rr in raw_results {
//                        // lets check to see if there are any differences in the objects
//                        let userraw_data = UsersRaw()
//                        userraw_data.to(rr)
//
//                        // now lets compare:
//                        if !userraw_data.compare(targetItem: thisuser) {
//                            // SAVE THE CHANGED DATA
//                        }
//
//                    }
                    
                } catch {
                    print("SQL update user raw error: \(error.localizedDescription)")
                }
            }
            
            
            
            
        }
        
        
    }

    static func retrieveBikeAssignments(location: String) {
        
    }

}

