import PerfectHTTP
import Foundation

extension String {
    
    var intValue : Int? {
        return Int(self)
    }
}

extension Country {
    static public func idWith(isoNumericCode: String?) -> Int? {
        if isoNumericCode.isNil { return nil }
        // Okay lets see:
        let country = Country()
        try? country.find(["code_alpha_2":isoNumericCode!.uppercased()])
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

extension HTTPRequest {
    func postBodyJSON() throws -> [String:Any]? {
        if let json = try? self.postBodyString?.jsonDecode() as? [String:Any], json.isNotNil {
            return json
        } else if let str = self.postBodyString {
            throw BucketAPIError.unparceableJSON(str)
        } else {
            return nil
        }
    }
    
    //MARK: - Country will be used across both API's:
    var countryCode : String? {
        
        // they may pass in either the code or the number
        if let countryCode = self.urlVariables["countryCode"] {
            
            if countryCode.isAlpha(), Country.idWith(isoNumericCode: countryCode.uppercased()).isNotNil {
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
        let sentCountryId = self.header(.custom(name: "countryId")) ?? self.urlVariables["countryId"]
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
            return Country.idWith(isoNumericCode: sentCountryId?.uppercased())
        }
    }
    
}

extension HTTPResponse {
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
}
