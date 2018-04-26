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
import PerfectLocalAuthentication

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
        // Removed because the username and password are set at the server level, not the services level.
//        if StagesConnecter.sharedInstance.services?.username == nil ||
//            StagesConnecter.sharedInstance.services?.password == nil {
//            return false
//        }
        
        // this will indicate if we had a successful login for any location
        var returnsuccess = false
        
        // there is at least one service in the pack here (we checked before getting here)
        for serv in StagesConnecter.sharedInstance.services!.servers! {
            // lets get each ID token
            var urltouse = serv.server_url!
            urltouse.append(endpoints.auth)
            
            urltouse = urltouse.stringByReplacing(string: "{id}", withString: serv.location_service_id!)

            // lets get the token
//            let requestJSON:[String:Any] = ["ClientId":self.services!.username!,"ClientSecret":self.services!.password!]
            let requestJSON:[String:Any] = ["ClientId":serv.username!,"ClientSecret":serv.password!]

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

    /**
    *   The sourceID is required and is
    *
    **/
    @discardableResult
    func associateUsers(_ targetUser:Account? = nil) -> [String:Any] {

        var returnDict:[String:Any] = [:]
        
        var emailRet:[String:Any] = [:]
        var phoneRet:[String:Any] = [:]
        var associatedUsersDict:[String:Any] = [:]
        var grandtotalemail = 0
        var grandtotalphone = 0

        // we are associating local users with the source records in the raw data
        // only the users without stages
        
        var sql = "SELECT id, email, detail->>'phone' AS phone, detail FROM account WHERE detail->>'stages' IS NULL"
        if targetUser.isNotNil, let tgtId = targetUser?.id {
             sql.append(" AND id = '\(tgtId)'")
        }
        
        let user_list = Account()
        
        do {

            // we are going to go thru the entire list of users_raw to make sure they are
            if let user_target = try? user_list.sqlRows(sql, params: []) {
                for ur in user_target {
                    
                    var foundit = false
                    var getusers_sql = ""

                    let therawuser = UsersRaw()
                    
                    let thetarget = Account()
                    try? thetarget.get(ur.data["id"].stringValue!)
                    
                    // check for the email first (if it has been found, don't look further)
                    if let theemail = ur.data.users_raw.email {
                        getusers_sql = "SELECT id FROM users_raw WHERE source = 'stages' AND email = '\(theemail)'"

                        let rawuserlist = try? therawuser.sqlRows(getusers_sql, params: [])
                        
                        // lets see if there is only one - or... more than one
                        if rawuserlist.isNotNil, rawuserlist.arrayDicValue.count > 1 {
                            // this is where we have multiple accounts - what to do???
                            
                        } else if rawuserlist.isNotNil, rawuserlist.arrayDicValue.count == 1 {
                            // we have one account matching - so... this works
                            foundit = true
                            
                            // grab the raw user entry
                            let rawuserid = rawuserlist![0].data["id"].intValue ?? 0
                            try? therawuser.get(rawuserid)

                            // now update both the rawuser and the account
                            therawuser.account_id = thetarget.id
                            if (try? therawuser.saveWithGIS()) != nil {
                                // successsssssssssss
                            }
                            
                            // grab the stages id:
                            let stages_id = therawuser.source_id ?? "ERROR"
                            
                            // if there is a phone number, lets add it
                            var yourphone = ""
                            if let raw_phone = therawuser.phone {
                                
                                // make sure the raw_phone is not the same characters
                                var notrepeating = true
                                var repeatcount = 0
                                var testchar:Character?
                                
                                if raw_phone.length > 9 {
                                    // take the second character (I am not sure what they are doing with the country code)
                                    testchar = raw_phone[1]
                                
                                    for c in raw_phone {
                                    
                                        if c == testchar {
                                            repeatcount += 1
                                        }
                                    
                                    }
                                
                                    // here is the decision point to see if numbers are repeating in the phone number
                                    if repeatcount >= 9 {
                                        notrepeating = false
                                    }
                                }
                                
                                // look at the length...
                                if notrepeating, raw_phone.length == 11 {
                                    yourphone = raw_phone
                                } else if notrepeating, raw_phone.length == 10 {
                                    yourphone.append("1")
                                    yourphone.append(raw_phone)
                                }
                            }
                            
                            // update the account now
                            var detail = thetarget.detail
                            
                            if let _ = detail["phone"].stringValue {
                                // it exists - DO NOTHING
                            } else if yourphone.length > 10 {
                                // does not exist....
                                detail["phone"] = yourphone
                            }
                            detail["stages"] = stages_id
                            detail["stages_match"] = "email"
                            thetarget.detail = detail
                            
                            // update the user account
                            let _ = try? thetarget.saveWithGIS()
                            
                            // save the return...
                            grandtotalemail += 1
                            // if there is more than one, we are not sending back the type of match
                            if grandtotalemail > 1 {
                                emailRet.removeValue(forKey: "stages")
                                emailRet.removeValue(forKey: "stages_match")
                            } else {
                                emailRet["stages"] = stages_id
                                emailRet["stages_match"] = "email"
                            }

                        } else {
                            // there were no records matching the email address
                        }
                    }
                    
                    // the stages phone numbers are in various formats.  Over 1/2 are 14105551212.  Another major chunk are 4105551212
                    // So we will try these formats for now and deal with internationalization later
                    // check for the phone number if the email was not found
                    if  !foundit, let thephone12 = thetarget.detail["phone"].stringValue {
                        
                        // lets format the phone number (11 numbers ie: 14105551212)
                        var thephone11 = thephone12
                        thephone11.removeFirst()
                            
                        getusers_sql = "SELECT id FROM account WHERE (detail @> '{\"phone\": \"\(thephone12)\"}') OR (detail @> '{\"phone\": \"\(thephone11)\"}')"

                        
                        let rawuserlist = try? therawuser.sqlRows(getusers_sql, params: [])
                        
                        // lets see if there is only one - or... more than one
                        if rawuserlist.isNotNil, rawuserlist.arrayDicValue.count > 1 {
                            // this is where we have multiple accounts - what to do???
                            
                        } else if rawuserlist.isNotNil, rawuserlist.arrayDicValue.count == 1 {
                            // we have one account matching - so... this works
                            foundit = true
                            
                            // grab the raw user entry
                            let rawuserid = rawuserlist![0].data["id"].intValue ?? 0
                            try? therawuser.get(rawuserid)
                            
                            // now update both the rawuser and the account
                            therawuser.account_id = thetarget.id
                            if (try? therawuser.saveWithGIS()) != nil {
                                // successsssssssssss
                            }
                            
                            // grab the stages id:
                            let stages_id = therawuser.source_id ?? "ERROR"
                            
                            // update the account now
                            var detail = thetarget.detail
                            detail["stages"] = stages_id
                            detail["stages_match"] = "phone"
                            thetarget.detail = detail
                            
                            // update the user account
                            let _ = try? thetarget.saveWithGIS()

                            // save the return...
                            grandtotalphone += 1
                            if grandtotalphone > 1 {
                                phoneRet.removeValue(forKey: "stages")
                                phoneRet.removeValue(forKey: "stages_match")
                            } else {
                                phoneRet["stages"] = stages_id
                                phoneRet["stages_match"] = "phone"
                            }

                        } else {
                            // there were no records matching the email address
                        }
                    }
                }
            }
        }
    
        emailRet["total"] = grandtotalemail
        associatedUsersDict["email"] = emailRet
        
        phoneRet["total"] = grandtotalphone
        associatedUsersDict["phone"] = phoneRet

        returnDict["associateusers"] = associatedUsersDict
        
        return returnDict
    }

    @discardableResult
    func retrieveUsers(location: String? = nil) -> [String:Any] {
        
        // if we do not have the servers definition - get outta here
        if self.services!.servers == nil {
            return [:]
        }
        
//        "Phone": 12022463657,
//        "NickName": ShutUpLegs,
//        "FirstName": Tammar,
//        "Weight": 60.78137758,
//        "Gender": Female,
//        "LastName": Berger,
//        "Email": tammar.berger@gmail.com,
//        "Id": 8640
        
        var retarray:[String:Any] = [:]
        var syncUsersReturn:[String:Any] = [:]
        var grandtotal = 0
        
        // the API is the same for all - the token is what makes it work for the location
        
        // lets process all users from all locations
        for serv in self.services!.servers! {
            
            if location != nil && serv.location_service_id?.hashValue != location?.hashValue {
                continue
            }
            
            // first thing we do is set every user to updating, then update them
            let updating_sql = "SELECT id FROM users_raw WHERE source = 'stages' AND source_location_id = '\(serv.location_service_id!)'"
            let useme = UsersRaw()
            
            let updating_results = try? useme.sqlRows(updating_sql, params: [])
            if updating_results.isNotNil {
                for upd_row in updating_results! {
                    
                    // ok - now set all of these as deleted
                    let theid = upd_row.data["id"].intValue
                    if (try? useme.find(["id":"\(theid!)"])).isNotNil {
                        useme.status = "updating"
                        useme.modifiedby = "SYSTEM"
                        let _ = try? useme.saveWithGIS()
                    }
                    
                }
            }

            
            // grab the users from the location
            var urltouse = serv.server_url!
            urltouse.append(endpoints.users)
            
            // grab the token string
            if let tokenString = self.bearerToken(location: serv.location_service_id!) {
                do {
                    
                    // run thru the list of users
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
                                
                                if let value = d["Gender"] as? String {
                                    tmpd["gender"] = value.lowercased()
                                }
                                
                                if let value = d["Id"] as? Int {
                                    tmpd["source_id"] = "\(value)"
                                }
                                
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
                                    tmpd["email"] = value.lowercased()
                                }
                                
                                tmpd["source_location_id"] = serv.location_service_id!
                                
                                tmpd["source"] = "stages"
                                
                                updateduserarray.append(tmpd)

                            }
                            
                            // process the user array
                            self.processUserArray(userarray: updateduserarray)

                            total = total + userarray.count
                            
                            if userarray.count < increment || userarray.count == 0 {
                                
                                grandtotal = grandtotal + total
                                
                                var ra:[String:Any] = [:]
                                ra["total"] = total
                                ra["result"] = "success"
                                
                                syncUsersReturn[serv.location_service_id!] = ra
                                
                                print("Total records: \(total)")
                                wearedone = true
                            }

                        } catch {
                            
                            var ra:[String:Any] = [:]
                            ra["result"] = "failure"
                            
                            syncUsersReturn[serv.location_service_id!] = ra

                            print("Error during the curl process: \(error.localizedDescription)")
                            wearedone = true
                        }
                    }
                }
            }
            
            // now set the records that are updating to deleted
            // first thing we do is set every user to updating, then update them
            let delete_sql = "SELECT id FROM users_raw WHERE source = 'stages' AND status = 'updating' AND source_location_id = '\(serv.location_service_id!)'"
            let del_useme = UsersRaw()
            
            let delete_results = try? del_useme.sqlRows(delete_sql, params: [])
            if delete_results.isNotNil {
                for del_row in delete_results! {
                    // ok - now set all of these as deleted
                    let theid = del_row.data["id"].intValue
                    if (try? del_useme.find(["id":"\(theid!)"])).isNotNil {
                        del_useme.status = "deleted"
                        let _ = try? del_useme.saveWithGIS()
                    }
                }
            }
        }

        syncUsersReturn["total"] = grandtotal
        retarray["syncusers"] = syncUsersReturn

        return retarray
        
    }
    
    fileprivate func processUserArray(userarray:[[String:Any]]) {
        
        // spin theu the array and process each user.
        for user in userarray {
            
            print("User: \(user)")
            
            let thisuser = UsersRaw()
            thisuser.fromDictionary(sourceDictionary: user)
            
            var sql:String = ""
            var locid = ""
            
            if let loc = user["source"].stringValue {
                locid = "\(loc.lowercased())"
            }
            
            // first check to see if there is a user in the raw table
            if let useremail = user["email"].stringValue {
                sql = "SELECT id FROM users_raw WHERE email = '"
                sql.append(useremail.lowercased())
                sql.append("' AND ")
                sql.append("source = '\(locid)'")
                print("\(sql)")
            } else if  let userphone = user["phone"].stringValue {
                sql = "SELECT id FROM users_raw WHERE phone = "
                sql.append(String(userphone))
                sql.append(" AND ")
                sql.append("source = '\(locid)'")
                print("\(sql)")
            }

            if !sql.isEmpty {
                
                let raw = UsersRaw()
                
                do {
                    
                    let raw_results = try raw.sqlRows(sql, params: [])

                    if raw_results.count == 0 {
                        thisuser.status = "active"
                        thisuser.createdby = "SYSTEM"
                        let _ = try? thisuser.saveWithGIS()
                    } else {
                        for rr in raw_results {
                            
                            let us = UsersRaw()
                            let theid = rr.data["id"].intValue
                            try? us.find(["id":"\(theid!)"])
                            us.status = "active"
                            let _ = try? us.saveWithGIS()
                            
                        }
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

