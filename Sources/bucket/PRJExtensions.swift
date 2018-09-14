import PerfectHTTP
import Foundation
import PerfectLocalAuthentication

extension String {
    
    var intValue : Int? {
        return Int(self)
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
