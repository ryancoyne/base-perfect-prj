import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession

struct FriendStatusReturn {
    static let friendsRequestAdded = ["result":"request_added"]
    static let friendsPending      = ["result":"request_pending"]
    static let friendsAlready      = ["result":"friends_already"]
    static let friendsRejected     = ["result":"friends_rejected"]
    static let friendsConnected    = ["result":"friends_added"]
    static let friendsRequestError = ["result":"friends_request_error"]
}

class Friends: PostgresStORM {
    //MARK: - Inherited fields:
    var id         : Int?
    var created    : Int?
    var createdby  : String?
    var modified   : Int?
    var modifiedby : String?
    
    //MARK: - Fields
    var user_id   : String?
    var friend_id : String?
    var invited   : Int?
    var accepted  : Int?
    var rejected  : Int?
    
    //MARK: Table name
    override public func table() -> String { return "friend" }

    typealias CCXMultipleFriendsResponse = (success: Bool, failedIds: [String]?)
    
    //MARK: Init Functions
    
    //MARK -
    //MARK: initializers
    required init() {
        super.init()
    }
    
    init(_ stormrow: StORMRow) {
        
        // common fields
        if let data = stormrow.data["id"].intValue {
            self.id = data
        }
        
        if let data = stormrow.data["created"].intValue {
            self.created = data
        }
        
        if let data = stormrow.data["modified"].intValue {
            self.modified = data
        }
        
        if let data = stormrow.data["createdby"].stringValue, !data.isEmpty {
            self.createdby = data
        }
        
        if let data = stormrow.data["modifiedby"].stringValue, !data.isEmpty {
            self.modifiedby = data
        }
        
        if let data = stormrow.data["user_id"].stringValue {
            self.user_id = data
        }
        
        if let data = stormrow.data["friend_id"].stringValue {
            self.friend_id = data
        }
    }

    
    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        if let data = this.data.id {
            id = data
        }
        
        if let data = this.data.created.intValue {
            created = data
        }
        
        if let data = this.data.modified.intValue {
            modified = data
        }
        
        if let data = this.data.createdBy {
            createdby           = data
        }
        
        if let data = this.data.modifiedBy {
            modifiedby          = data
        }
        
        if let data = this.data.friend.invited.intValue {
            invited = data
        }
        
        if let data = this.data.friend.accepted.intValue {
            accepted = data
        }
        
        if let data = this.data.friend.rejected.intValue {
            rejected = data
        }

    }
    
    func rows() -> [Friends] {
        var rows = [Friends]()
        for i in 0..<self.results.rows.count {
            let row = Friends()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.id.isNotNil {
            dictionary.id = self.id
        }
        // audit fields
        if self.created.isNotNil {
            dictionary.created = self.created
        }
        if self.createdby.isNotNil {
            dictionary.createdBy = self.createdby
        }
        
        if self.modified.isNotNil {
            dictionary.modified   = self.modified
        }
        if self.modifiedby.isNotNil {
            dictionary.modifiedBy = self.modifiedby
        }

        if self.invited.isNotNil {
            dictionary.friend.invited = self.invited
        }

        if self.accepted.isNotNil {
            dictionary.friend.accepted = self.accepted
        }

        if self.rejected.isNotNil {
            dictionary.friend.rejected = self.rejected
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
                    frnd.accepted = RMServiceClass.getNow()
                    // ok - if we are here the record is not mine
                    do {
                        try frnd.saveWithCustomType()
                        return FriendStatusReturn.friendsConnected
                    } catch {
                        // do nothing
                    }

                }
            }

            return FriendStatusReturn.friendsRequestAdded
        }

        
        // they passed all of the points, then create the new found friendship
        let now = RMServiceClass.getNow()
        friend.created = now
        friend.invited = now
        friend.createdby = session.userid
        friend.user_id = session.userid
        friend.friend_id = id
        if (try? friend.saveWithCustomType(schemaIn: "public", session.userid)).isNotNil {
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
//            let now = RMServiceClass.getNow()
//            friend.created = now
//            friend.invited = now
//            friend.createdby = session.userid
//            friend.user_id = session.userid
//            friend.friend_id = id
//            if (try? friend.saveWithCustomType()).isNil {
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
                    friend.rejected = RMServiceClass.getNow()
                    if let yup = try? friend.saveWithCustomType(schemaIn: "public",session.userid), !yup.isEmpty {
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

