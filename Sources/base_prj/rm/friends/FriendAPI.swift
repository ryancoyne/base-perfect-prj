//
//  UserAPI.swift
//
//  Created by Ryan Coyne on 10/30/17.
//

import PostgresStORM
import PerfectHTTP
import PerfectLib

//MARK: - Friend API
/// This FriendAPI structure supports all the normal endpoints for a user based login application.
struct FriendAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [["method":"post",   "uri":"/api/v1/friend", "handler":getFriend],
                    ["method":"put",    "uri":"/api/v1/friend", "handler":addFriend],
                    ["method":"delete", "uri":"/api/v1/friend", "handler":deleteFriend],
            ]
        }
        //MARK:-
        //MARK: - Friend Functions:
        public static func getFriend(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in

                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                // Check if the user is logged in.
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }

                var returnd:[String:Any] = [:]
                var matched:[[String:Any]] = []
                var emaillist:[String] = []
                var onlymatchesglobal = false

                // lets get the list of the friends...
                if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    
                    if let em = json?["emails"] as? [String] {
                        emaillist = em
                    }
                    
                    // we first check to see if only matches is set to true (it is optional, remember)
                    if let onlymatches = json?["onlyMatches"].boolValue, onlymatches == true {

                        // lets set this for th stuff in the end
                        onlymatchesglobal = onlymatches

                        // only process if there is a list of emails
                        if !emaillist.isEmpty {
                            matched = Friends.getMatches(emaillist, session)
                        } else {
                            // ERROR: they did the only matches and NO emails
                            try? response.setBody(json: ["error":"You requested matchesOnly, but you did not give us anything to match."])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .custom(code: 420, message: "Chill dude...... The required parameters were not passed."))
                            return
                        }
                        
                    }

                }
                
                // this is here because no parameters is a valid condition not to have any paramaters passed in
                // process the rest of the stuff
                if !onlymatchesglobal {
                    
                    // get friends
                    let friends = Friends.getFriends(session.userid, session)
                    
                    // get pending
                    let pending = Friends.getPending(session.userid, session)
                    
                    // did they send in a list of emails?
                    if !emaillist.isEmpty {
                        matched = Friends.getMatches(emaillist, session)
                    }
                    
                    // put together the return
                    if !friends.isEmpty {
                        returnd["friends"] = friends
                    }
                    
                    if !pending.isEmpty {
                        returnd["invites"] = pending
                    }
                    
                }
                
                if !matched.isEmpty {
                    returnd["matches"] = matched
                }
                
                try? response.setBody(json: returnd)
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .ok)
                return
            }
        }

        public static func addFriend(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                // Check if the user is logged in.
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
                
                // Okay lets add the friends.
                if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    if let id = json?["id"].stringValue {
                        try? response.setBody(json: Friends.addFriend(id, session))
                                                .setHeader(.contentType, value: "application/json")
                                                .completed(status: .ok)
                        return
                    } else {
                        // Return bad request - no post body:
                        try? response.setBody(json: ["error":"Please give an id or an array of ids in post body."])
                                                .setHeader(.contentType, value: "application/json")
                                                .completed(status: .badRequest)
                        return
                    }
                }
            }
        }
        public static func deleteFriend(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.securityCheck() else { response.badSecurityToken; return }

                // Check if the user is logged in.
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
                
                // Okay lets delete the friends:
                if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    
                    var retDict:[String:Any] = [:]
                    
                    if let id = json?["id"].stringValue {
                        if let _ = json?["rejected"].boolValue {
                            // they are rejecting this friend
                            let success = Friends.deleteFriend(id, session, true)
                            if success {
                                retDict = ["result":"success"]
                            } else {
                                retDict = ["result":"failure"]
                            }
                        } else {
                            // deleting the friend outright
                            let success = Friends.deleteFriend(id, session, false)
                            if success {
                                retDict = ["result":"success"]
                            } else {
                                retDict = ["result":"failure"]
                            }
                        }
                    } else {
                        try? response.setBody(json: ["error":"Please give an id or an array of ids in post body."])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .badRequest)
                        return
                    }
                    
                    // return the ok response (didn't get caught by the bad request)
                    try? response.setBody(json: retDict)
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)
                    return
                }
            }
        }
    }
}
