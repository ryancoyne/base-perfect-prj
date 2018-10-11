import PerfectHTTP
import Foundation
import PerfectLocalAuthentication

extension String {
    
    enum s {
        static let c = [Character("a"), Character("b"), Character("c"), Character("d"), Character("e"), Character("f"), Character("g"), Character("h"), Character("i"), Character("j"), Character("k"), Character("l"), Character("m"), Character("n"), Character("o"), Character("p"), Character("q"), Character("r"), Character("s"), Character("t"), Character("u"), Character("v"), Character("w"), Character("x"), Character("y"), Character("z"), Character("1"), Character("2"), Character("3"), Character("4"), Character("5"), Character("6"), Character("7"), Character("8"), Character("9"), Character("0")]
        static let k = UInt32(c.count)
    }
    var intValue : Int? {
        return Int(self)
    }
    
    /// The count is defaulted to 8.
    static func referenceCode(_ count : Int?=8, forSchema : String) -> String {
        
        let isUnusedReferenceCode = false
        while !isUnusedReferenceCode {
            var result = [Character](repeating: "a", count: count!)
            
            for i in 0...count! {
                let r = Int(arc4random_uniform(s.k))
                result[i] = s.c[r]
            }
            
            let value = String(result)
            
            // Here we need to theck if the reference code is being used already:
            let query = BatchHeader()
            let sqlStatement = "SELECT * FROM \(forSchema).batch_header WHERE batch_identifier = '\(value)';"
            if let rows = try? query.sqlRows(sqlStatement, params: []) {
                if rows.isEmpty {
                    return value
                } else {
                    continue
                }
            }
        }
        
    }

}

extension Dictionary {
    
    static func == <K, V>(left: [K:V?], right: [K:V?]) -> Bool {
        guard let left = left as? [K: V], let right = right as? [K: V] else { return false }
        return NSDictionary(dictionary: left).isEqual(to: right)
    }
}

extension Country {
    static public func idWith(_ alphaCountryCode: String?) -> Int? {
        if alphaCountryCode.isNil { return nil }
        // Okay lets see:
        let country = Country()
        try? country.find(["code_alpha_2":alphaCountryCode!.uppercased()])
        return country.id
    }
    static public func exists(withId: String?) -> Bool {
        if withId.isNil { return false }
        // Okay lets see:
        let country = Country()
        try? country.get(withId!)
        return country.id.isNotNil
    }
}

extension Retailer {
    static public func exists(schema:String, withId: String?) -> Bool {
        if withId.isNil { return false }
        // Okay lets see:
        let retailer = Retailer()
        var sql = ""
        if let theId = withId, theId.isNumeric() {
            sql = "SELECT id FROM \(schema).retailer WHERE id = \(theId.intValue!)"
        } else if let theId = withId, !theId.isNumeric()  {
            sql = "SELECT id FROM \(schema).retailer WHERE retailer_code = '\(theId.lowercased())'"
        } else {
            return false
        }
        let res = try? retailer.sqlRows(sql, params: [])
        if res.isNotNil, let r = res?.first {
            retailer.to(r)
        }
        return retailer.id.isNotNil
    }

}

enum BucketAPIError: Error {
    case unparceableJSON(String)
}

extension Account {
    // this function returns the boolean to determine if the user is a sample user or not
    func isSample()->Bool {
        
        switch self.id {
        case SampleUser.user1, SampleUser.user2:
            return true
        default:
            return false
        }
    }
    
    // this function will check to see if the account is permitted to access this retailer
    func bounceRetailerAdmin(_ schema: String, _ retailer_id:Int)->Bool {
        
        // lets see if this user is permitted to access this retailr
        // the retailer array is in the detail section
        // { "retailers": { "us":[123,456] } }
        if let retailers:[String:Any] = self.detail["retailer"] as? [String : Any],
            let retailer_array:[Int] = retailers["\(schema)"] as? [Int] {
            
            // so if we are here, they do have some retailer permissions for this retailer
            for i in retailer_array {
                if i == retailer_id { return false }
            }
        }
        
        return true
    }
    
    func addRetailerAdmin(_ schema: String, _ retailer_id:Int) {

        // lets see if this user is permitted to access this retailr
        // the retailer array is in the detail section
        // { "retailers": { "us":[123,456] } }
        
        if let retailers:[String:Any] = self.detail["retailers"] as? [String : Any],
            var retailer_array:[Int] = retailers["\(schema)"] as? [Int] {
            
            // so if we are here, they do have some retailer permissions for this retailer
            var alreadyin = false
            
            for i in retailer_array {
                if i == retailer_id { alreadyin = true }
            }
            
            if !alreadyin {
                // add it and update
                retailer_array.append(retailer_id)
                
                var new_detail = self.detail
                
                // add it to the detail:
                var new_retailers:[String:Any] = [:]
                new_retailers["\(schema)"] = retailer_array
                
                // no set them in the dictionary
                new_detail["retailers"] = new_retailers
                
                // update the account
                self.detail = new_detail
                _ = try? self.saveWithCustomType()
            }
        } else {
            // there was no detail yet - frst one!
            var retailer_detail:[String:Any] = [:]
            var theretailers:[String:Any] = [:]
            theretailers["\(schema)"] = [retailer_id]
            retailer_detail["retailers"] = theretailers

            var new_detail = self.detail
            
            // add it to the detail:
            var new_retailers:[String:Any] = [:]
            new_retailers["\(schema)"] = [retailer_id]
            
            // no set them in the dictionary
            new_detail["retailers"] = new_retailers
            
            // update the account
            self.detail = new_detail
            _ = try? self.saveWithCustomType()

        }
    }
    
    func deleteRetailerAdmin(_ schema: String, _ retailer_id:Int) {

        if let retailers:[String:Any] = self.detail["retailers"] as? [String : Any],
            let retailer_array:[Int] = retailers["\(schema)"] as? [Int] {
            
            // so if we are here, they do have some retailer permissions for this retailer
            var alreadyin = false
            var new_retailer_list:[Int] = []
            
            for i in retailer_array {
                if i == retailer_id {
                    alreadyin = true
                } else {
                    new_retailer_list.append(i)
                }
            }
            
            var new_retailers:[String:Any] = [:]
            
            if alreadyin {
                
                if new_retailer_list.count > 0 {
                    // there is at least one in the array
                    new_retailers["\(schema)"] = new_retailer_list
                }
                
                var new_detail = self.detail
                
                if new_retailers.count > 0 {
                    new_detail["retailers"] = new_retailers
                } else {
                    var nr:[String:Any] = new_detail["retailers"] as! [String : Any]
                    nr.removeValue(forKey: "\(schema)")
                    if nr.count > 0 {
                        // there is one or more left
                        new_detail["retailers"] = nr
                    } else {
                        // none left
                        new_detail.removeValue(forKey: "retailers")
                    }
                }
                
                // update the account
                self.detail = new_detail
                _ = try? self.saveWithCustomType()
            }
//        } else {
//            // there was no detail yet - frst one!
//            var retailer_detail:[String:Any] = [:]
//            var theretailers:[String:Any] = [:]
//            theretailers["\(schema)"] = [retailer_id]
//            retailer_detail["retailers"] = theretailers
//            
//            var new_detail = self.detail
//            
//            // add it to the detail:
//            var new_retailers:[String:Any] = [:]
//            new_retailers["\(schema)"] = [retailer_id]
//            
//            // no set them in the dictionary
//            new_detail["retailers"] = new_retailers
//            
//            // update the account
//            self.detail = new_detail
//            _ = try? self.saveWithCustomType()
//            
        }

    }

}

extension HTTPRequest {
    var account : Account? {
        guard let userid = session?.userid else { return nil }
        let acount = Account()
        try? acount.get(userid)
        return acount
    }
    
    func postBodyJSON() throws -> [String:Any]? {
        if let json = try? self.postBodyString?.jsonDecode() as? [String:Any], json.isNotNil {
            return json
        } else if let str = self.postBodyString {
            throw BucketAPIError.unparceableJSON(str)
        } else {
            return nil
        }
    }
    
    func SecurityCheck() -> Bool {
        
        var passedCheck = false
        
        // check for the header value from the CloudFront instance
        
        // the header field "check" should have one of the following values:
        // PROD:    P-A5B26A04-45FE-4C48-B111-84F0A07BB5A3
        // STAGING: S-792B9A88-26E1-4502-AD04-E0D89E63822D
        // DEV:     D-4B2E93B2-C844-4F18-A1AE-C13EA1F7D12F
        
        let checkvalue = self.header(.custom(name: "check")) ?? "nope"
        let env = EnvironmentVariables.sharedInstance.Server!
        
        switch env {
        case .production:
            if checkvalue == "P-A5B26A04-45FE-4C48-B111-84F0A07BB5A3" { passedCheck = true }
            break
        case .staging:
            if checkvalue == "S-792B9A88-26E1-4502-AD04-E0D89E63822D" { passedCheck = true }
            break
        case .development:
            if checkvalue == "D-4B2E93B2-C844-4F18-A1AE-C13EA1F7D12F" { passedCheck = true }
            break
        }
        
        if !passedCheck {
            
            var audit:[String:Any] = [:]
            
            audit["remote_host"] = self.remoteAddress.host
            audit["remote_port"] = self.remoteAddress.port

            // put the headers in the audit
            for (key,value) in self.headers {
                audit["\(key)"] = value
            }
            
            // put the sessions in the audit
            for (key,value) in (self.session?.data)! {
                audit["\(key)"] = value
            }
            
            AuditRecordActions.securityFailure(schema: nil,
                                               session_id: self.session?.token ??  "NO TOKEN",
                                               user: self.session?.userid ?? "NO USER",
                                               row_data: audit,
                                               description: "Security Check Failed.")
            
        }
        
        // let them know if you pass the security check
        return passedCheck
    }
    
    //MARK: - Country will be used across both API's:
    var countryCode : String? {
        
        // they may pass in either the code or the number
        if let countryCode = self.urlVariables["countryCode"] {
            
            if countryCode.isAlpha(), Country.idWith(countryCode).isNotNil {
                return countryCode
            } else if countryCode.isNumeric() {
                // get the country code alpha
                let cc = Country()
                let _ = try? cc.get(countryCode.intValue!)
                if cc.code_alpha_2.isNotNil {
                    return cc.code_alpha_2!
                }
            } else {
                // incorrect format passed in
                return nil
            }
        
        }
        
        // if they did not pass the country code variable, see if there is a country id and process it
        if let cid = self.countryId  {
            return Country.getSchema(cid)
        }
        
        // was not passed in correctly
        return nil
        
    }
    var countryId : Int? {
        let sentCountryId = self.header(.custom(name: "countryId")) ?? self.urlVariables["countryId"] ?? self.urlVariables["countryCode"]
        // We need to
        if sentCountryId?.isNumeric() == true {
            // It is an integer, lets return the integer value:
            if Country.exists(withId: sentCountryId!) {
                return sentCountryId.intValue
            } else {
                return nil
            }
        } else {
            // It is US, or SG here. We need to go and query for the integer id value:
            return Country.idWith(sentCountryId)
        }
    }

    func getRetailerCode()->String? {
        
        var schema = ""
        if let country_id = self.countryId {
            schema = Country.getSchema(country_id)
        } else {
            return nil
        }
        
        if let retcode = self.header(.custom(name: "retailerId")) ?? self.header(.custom(name: "retailerCode")) {
            let sql = "SELECT id FROM \(schema).retailer WHERE retailer_code = '\(retcode.lowercased())'"
            let r = Retailer()
            let r_ret = try? r.sqlRows(sql, params: [])
            if r_ret.isNotNil, (r_ret?.count)! > 0 {
                return retcode
            }
        }
        
        return nil
        
    }
    
    var retailerId : Int? {
        let sentRetailerId = self.header(.custom(name: "retailerId")) ?? self.urlVariables["retailerId"]
        
        let schema = self.countryCode
        if schema.isEmptyOrNil { return nil }
        
        // We need to
        if sentRetailerId?.isNumeric() == true {
            // It is an integer, lets return the integer value:
            if let sr = sentRetailerId, sr.isNumeric(), Retailer.exists(schema: schema!, withId: sr) {
                return sentRetailerId.intValue
            } else {
                return nil
            }
        } else if let sr = sentRetailerId.stringValue {
            // they did not send in the numeric code
            // so check the ID itself
            let retailer = Retailer()
            let sql = "SELECT * FROM \(schema!).retailer WHERE retailer_code = '\(sr.lowercased())'"
            let rtlr = try? retailer.sqlRows(sql, params: [])
            if rtlr.isNotNil, let t = rtlr?.first {
                retailer.to(t)
                return retailer.id!
            }
            return nil
        }
        return nil
    }

}

extension HTTPResponse {
    var unableToGetUser : Void {
        return try! self
            .setBody(json: ["errorCode":"UserError", "message":"There was a problem retrieving the user account"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 455, message: "Unable to access the user account"))
    }
    var sampleCodeRedeemError : Void {
        return try! self
            .setBody(json: ["errorCode":"SampleCodeRedeem", "message":"There was a problem redeeming the sample code"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 456, message: "Sample Codes are only allowed to be redeemed by sample accounts"))
    }
    var badSecurityToken : Void {
        return try! self
            .setBody(json: ["errorCode":"SecurityError", "message":"There was a problem with a security token"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .unauthorized)
    }
    var badSecurityTokenWeb: String {
        return "<div class='error'>There was a problem with a security token</div>"
    }

    func invalidRequest(_ invalidJsonString : String) {
        return try! self
            .setBody(json: ["errorCode":"InvalidRequest", "message":"Unable to parse JSON body: \(invalidJsonString)"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .badRequest)
    }
    var emptyJSONBody : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRequest", "message":"Empty JSON body sent."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .badRequest)
    }
    var invalidJSONFormat : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidJSON", "message":"Please check the required JSON format for this request."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .badRequest)
    }
    var invalidCountryCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidCountryCode", "message": "No such country code found"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 409, message: "Invalid Country"))
    }
    var invalidRetailerCode : Void {
        return try! self.setBody(json: ["errorCode":"InvalidRetailerCode", "message": "No such retailer found"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 412, message: "Invalid Retailer"))
    }
    var unsupportedCountry : Void {
        try! self.setBody(json: ["errorCode": "UnsupportedCountry", "message": "We currently are not in this country yet.  Please try again later."]).setHeader(.contentType, value: "application/json; charset=UTF-8").completed(status: .custom(code: 411, message: "Unsupported Country"))
    }
    var accountPermissionsBounce : Void {
        try! self.setBody(json: ["errorCode": "UnsupportedUser", "message": "You do not have the correct permissions to access this page"]).setHeader(.contentType, value: "application/json; charset=UTF-8").completed(status: .custom(code: 401, message: "Incorrect Permissions"))
    }
    var functionNotOn : Void {
        try! self.setBody(json: ["errorCode":"FunctionOff", "message":"This function is not on."]).setHeader(.contentType, value: "application/json; charset=UTF-8").completed(status: .custom(code: 500, message: "Endpoint Off"))
    }
}
