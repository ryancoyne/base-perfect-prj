import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession

class ServiceServer {
    
    var note                : String?
    var name                : String?
    var username            : String?
    var password            : String?
    var server_url          : String?
    var location_service_id : Int?

    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.note.isNotNil {
            dictionary.service.note = self.note
        }
        if self.name.isNotNil {
            dictionary.service.name = self.name
        }
        if self.username.isNotNil {
            dictionary.service.username = self.username
        }
        if self.password.isNotNil {
            dictionary.service.password = self.password
        }
        if self.server_url.isNotNil {
            dictionary.service.server_url = self.server_url
        }
        if self.location_service_id.isNotNil {
            dictionary.service.location_service_id = self.location_service_id
        }

        return dictionary
    }

    //MARK:-
    //MARK: Functions to list friends
    static func getFriends(_ id : String,  _ session: PerfectSession) -> [[String:Any]] {
        
        let requestinguser = Account()
        try? requestinguser.get(session.userid)
        
        // make sure we have the current user
        if requestinguser.id == "" {
            return []
        }

        // check to see if they are already friends
//        let r = try? requestinguser.sqlRows("SELECT * FROM friends_true('\(requestinguser.id)','\(id)')", params: [])
        let r = try? requestinguser.sqlRows("SELECT * FROM friends_true_all('\(requestinguser.id)')", params: [])

        // loop thru to get the list of friends (they will all be in the third return)
        if r.isNil || (r.isNotNil && r!.count == 0) {
            // poor guy has no friends
            return []
        }

        var retaccts: [[String:Any]] = []
        var idsin = ""

        // run thru the friends that were returned
        for a in r! {
            // see which one we should returned
            if let fid = a.data["friend_id"].stringValue {
                if fid == requestinguser.id {
                    idsin.append("'\(a.data["user_id"]!)',")
                } else {
                    idsin.append("'\(a.data["friend_id"]!)',")
                }
            }
        }

        // remove the last comma
        if idsin.count > 0 {
            idsin.removeLast()
        }
        
        // lets get our list of accounts now
        idsin = "SELECT acc.id FROM account AS acc WHERE id IN(\(idsin))"

        let targets = try? requestinguser.sqlRows(idsin, params: [])
        for tgt in targets! {
            do {
                let tmpa = Account()
                try tmpa.get(tgt.data["id"] as! String)
                retaccts.append(tmpa.asDictionary)
            } catch {
                print(error)
                // do nothgin == just keep going
            }
        }
        
        return retaccts
        
    }

    static func getPending(_ id : String,  _ session: PerfectSession) -> [[String:Any]] {
        
        let requestinguser = Account()
        try? requestinguser.get(session.userid)
        
        // make sure we have the current user
        if requestinguser.id == "" {
            return []
        }
        
        // check to see if they are already friends
        let r = try? requestinguser.sqlRows("SELECT * FROM friends_pending_all('\(requestinguser.id)')", params: [])
        
        // loop thru to get the list of friends (they will all be in the third return)
        if r.isNil || (r.isNotNil && r!.count == 0) {
            // poor guy has no friends
            return []
        }
        
        var retaccts: [[String:Any]] = []
        var idsin = ""
        
        // run thru the friends that were returned
        for a in r! {
            // lets see if we should send back friend or the other user_id
            if let test_the_id = a.data["friend_id"].stringValue, test_the_id == requestinguser.id {
                idsin.append("'\(a.data["user_id"]!)',")
            } else {
                idsin.append("'\(a.data["friend_id"]!)',")
            }
        }
        
        // remove the last comma
        if idsin.count > 0 {
            idsin.removeLast()
        }
        
        // lets get our list of accounts now
        idsin = "SELECT acc.id FROM account AS acc WHERE acc.id IN(\(idsin))"
        
        let targets = try? requestinguser.sqlRows(idsin, params: [])
        for tgt in targets! {
            do {
                let tmpa = Account()
                try tmpa.get(tgt.data["id"] as! String)
                retaccts.append(tmpa.asDictionary)
            } catch {
                print(error)
                // do nothgin == just keep going
            }
        }
        
        return retaccts
        
    }
    static func getMatches(_ emails : [String],  _ session: PerfectSession) -> [[String:Any]] {
        
        let requestinguser = Account()
        try? requestinguser.get(session.userid)
        
        // make sure we have the current user
        if requestinguser.id == "" {
            return []
        }
        
        // setup the email list
        var emaillist = ""
        
        // run thru the sent in email
        for em in emails {
            emaillist.append("'\(em)',")
        }
        
        if emaillist.isEmpty {
            return []
        }
        
        var retaccts: [[String:Any]] = []
        
        // get rid of the last comma
        if emaillist.count > 0 {
            emaillist.removeLast()
        }
        
        // check to see if they are already friends
        var thesql = "SELECT acc.id FROM account AS acc "
        thesql.append("WHERE email IN(\(emaillist)) ")
        thesql.append("AND NOT friends_in_table(acc.id, '\(session.userid)') ")
        thesql.append("AND acc.id  != '\(session.userid)' ")
        print(thesql)
        let targets = try? requestinguser.sqlRows(thesql, params: [])
        for tgt in targets! {
            do {
                // grab the account and convert it in to a dict
                let tmpa = Account()
                try tmpa.get(tgt.data["id"] as! String)
                retaccts.append(tmpa.asDictionary)
            } catch {
                print(error)
                // do nothgin == just keep going
            }
        }
        
        return retaccts
        
    }

    //MARK:-
    //MARK: Functions to add friends
    static func addFriend(_ id : String,  _ session: PerfectSession) -> [String:Any] {
        
        let friend = Friends()
        let requestinguser = Account()
        try? requestinguser.get(session.userid)

        // make sure we have the current user
        if requestinguser.id == "" {
            return FriendStatusReturn.friendsRequestError
        }
        
        // check to see if they are already friends
        var r = try? friend.sqlRows("SELECT * FROM friends_true('\(requestinguser.id)', '\(id)')", params: [])

        if r.isNotNil, r!.count > 0 {
            // this means that there is a record -- they are friends
            return FriendStatusReturn.friendsAlready
        }

        r = try? friend.sqlRows("SELECT * FROM friends_rejected('\(requestinguser.id)', '\(id)')", params: [])

        if r.isNotNil, r!.count > 0 {
            // this means that there is a record -- and they are ~~REJECTED~~
            return FriendStatusReturn.friendsRejected
        }

        r = try? friend.sqlRows("SELECT * FROM friends_pending('\(id)', '\(requestinguser.id)')", params: [])
        
        if r.isNotNil, r!.count > 0 {
            // this means that there is a record -- they are friends (although pending)
            // accept the friend request
            var frnd = Friends()
            for rs in r! {
                frnd = Friends(rs)
                // if I requested, send nada.
                if frnd.user_id == requestinguser.id {
                    // I requested it - don't show it....
                    return FriendStatusReturn.friendsPending
                } else {
                    frnd.accepted = CCXServiceClass.sharedInstance.getNow()
                    // ok - if we are here the record is not mine
                    do {
                        try frnd.saveWithGIS()
                        return FriendStatusReturn.friendsConnected
                    } catch {
                        // do nothing
                    }

                }
            }

            return FriendStatusReturn.friendsRequestAdded
        }

        
        // they passed all of the points, then create the new found friendship
        let now = CCXServiceClass.sharedInstance.getNow()
        friend.created = now
        friend.invited = now
        friend.createdby = session.userid
        friend.user_id = session.userid
        friend.friend_id = id
        if (try? friend.saveWithGIS(session.userid)).isNotNil {
            return FriendStatusReturn.friendsRequestAdded
        } else {
            return FriendStatusReturn.friendsRequestError
        }

    }
    
//    static func addFriends(_ ids: [String], _ session: PerfectSession) -> CCXMultipleFriendsResponse {
//        var failedIds : [String]? = nil
//        var failed = false
//        for id in ids {
//            let friend = Friends()
//            let now = CCXServiceClass.sharedInstance.getNow()
//            friend.created = now
//            friend.invited = now
//            friend.createdby = session.userid
//            friend.user_id = session.userid
//            friend.friend_id = id
//            if (try? friend.saveWithGIS()).isNil {
//                // If we havent failed yet,set the return to true:
//                if !failed { failed = true }
//                // If we havent set any ids yet, initialize the array:
//                if failedIds.isNil {
//                    failedIds = []
//                    failedIds?.append(id)
//                } else {
//                    failedIds?.append(id)
//                }
//            }
//        }
//        return (failed, failedIds)
//    }
    
    //MARK:-
    //MARK: Functions to remove friends
    static func deleteFriend(_ id : String,  _ session : PerfectSession, _ rejected: Bool = false)  -> Bool  {
        let friend = Friends()
//        let sqlStatement = "SELECT id FROM friends WHERE (user_id = $1 AND friend_id = $2) OR (user_id = $2 AND friend_id = $1)"
//        let sqlStatement = "SELECT id FROM friends_in_table('\(id)', '\(session.userid)')"
        let sqlStatement = "SELECT id FROM friends_true('\(id)', '\(session.userid)')"
//        let result = try? friend.sqlRows(sqlStatement, params: [id, session.userid])
        let result = try? friend.sqlRows(sqlStatement, params: [])
        if result.isNotNil {
            if result!.count > 0 && !rejected  {
                // this is a friend who is deleted deleted -- not just rejected
                if let id = result!.first?.data["id"].intValue, (try? friend.delete(id)).isNil {
                    return false
                } else {
                    return true
                }
            } else if result!.count > 0 && rejected {
                // this is a friend who was rejected
                if let id = result!.first?.data["id"].intValue {
                    friend.id = id
                    friend.rejected = CCXServiceClass.sharedInstance.getNow()
                    if let yup = try? friend.saveWithGIS(session.userid), !yup.isEmpty {
                        return true
                    } else {
                        return false
                    }
                }
            } else {
                return false
            }
        } else {
            return false
        }
        
        // default -- should not get here
        return false
    }
    
//    static func deleteFriends(_ ids : [String],  _ session : PerfectSession)  -> CCXMultipleFriendsResponse  {
//        var failedIds : [String] = []
//        for id in ids {
//            let friend = Friends()
//            let sqlStatement = "SELECT id FROM friends WHERE (user_id = $1 AND friend_id = $2) OR (user_id = $2 AND friend_id = $1)"
//            let result = try? friend.sqlRows(sqlStatement, params: [id, session.userid])
//            if result.isNotNil {
//                if result!.count > 0  {
//                    if let theid = result!.first?.data["id"].intValue, (try? friend.delete(theid)).isNil {
//                        failedIds.append(id)
//                    }
//                } else {
//                    failedIds.append(id)
//                }
//            } else {
//                failedIds.append(id)
//            }
//        }
//        if failedIds.isEmpty {
//            return (true, nil)
//        } else {
//            return (false, failedIds)
//        }
//    }
    
}

