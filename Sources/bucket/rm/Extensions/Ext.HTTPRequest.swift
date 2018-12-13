//
//  Ext.HTTPRequest.swift
//  COpenSSL
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation
import PerfectHTTP
import PerfectLocalAuthentication

extension HTTPRequest {
    //MARK: - Web Functions:
    func getSourcePath()->String {
        var retpath = ""
        
        if let pathC = self.getCookie(name: "sourcePage") {
            
            retpath = pathC
        }
        
        return retpath
    }

    
    //MARK: - Functions:
    func postBodyJSON() throws -> [String:Any]? {
        if let json = try? self.postBodyString?.jsonDecode() as? [String:Any], json.isNotNil {
            return json
        } else if let str = self.postBodyString, str.isEmpty {
            return [:]
        } else if let str = self.postBodyString {
            throw BucketAPIError.unparceableJSON(str)
        } else {
            return nil
        }
    }
    func securityCheck() -> Bool {
        // always not require header security values on the local machine
        #if os(macOS)
        return true
        #endif
        
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
            
            // If auditing is turned on, then we will go and do the audit:
//            AuditRecordActions.securityFailure(schema: nil,
//                                               session_id: self.session?.token ??  "NO TOKEN",
//                                               user: self.session?.userid ?? "NO USER",
//                                               row_data: audit,
//                                               description: "Security Check Failed.")
            
        }
        
        // let them know if you pass the security check
        return passedCheck
    }
    
    //MARK: - Variables:
    var account : Account? {
        guard let userid = self.session?.userid, !userid.isEmpty else { return nil }
        let acount = Account()
        try? acount.get(userid)
        return acount
    }
}
