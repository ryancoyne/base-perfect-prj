//
//  Ext.HTTPResponse.swift
//  COpenSSL
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation
import PerfectHTTP

extension HTTPResponse {
    //MARK: - Web Functions:
    func addSourcePage(_ sourcePage:String) {
        
        if sourcePage.isEmpty { return }
        
        /*
         Note that the Expiration enum is defined as follows:
         
         public enum Expiration {
         /// Session cookie with no explicit expiration
         case session
         /// Expiratiuon in a number of seconds from now
         case relativeSeconds(Int)
         /// Expiration at an absolute time given in seconds from epoch
         case absoluteSeconds(Int)
         ///    Custom expiration date string
         case absoluteDate(String)
         }
         */
        
        let sourcePageCookie = HTTPCookie(
            name: "sourcePage",
            value: sourcePage,
            domain: "localhost",
            expires: .session,
            path: "/",
            secure: false,
            httpOnly: false
        )
        
        self.addCookie(sourcePageCookie)
        
    }
    
    //MARK: - Functions:
    func invalidRequest(_ invalidJsonString : String) {
        return try! self
            .setBody(json: ["errorCode":"InvalidRequest", "message":"Unable to parse JSON body: \(invalidJsonString)"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .badRequest)
    }
    func notLoggedIn() {
        let returnD = ["errorCode" : "Unauthorized", "message":"Please log in."]
        try! self.setBody(json: returnD)
            .completed(status: .unauthorized)
    }
    func caughtError(_ error : Error) {
        try! self.setBody(json: ["error": error.localizedDescription])
            .completed(status: .unauthorized)
    }
    
    var alreadyLoggedIn : Void {
        try! self.setBody(json: ["error" : "You are already logged in."])
            .completed(status: .ok)
    }
    var invalidJSONFormat : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidJSON", "message":"Please check the required JSON format for this request."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .badRequest)
    }
    //MARK: - Variables:
    var badSecurityToken : Void {
        return try! self
            .setBody(json: ["errorCode":"SecurityError", "message":"There was a problem with a security token"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .unauthorized)
    }
    var emptyJSONBody : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRequest", "message":"Empty JSON body sent."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .badRequest)
    }
}
