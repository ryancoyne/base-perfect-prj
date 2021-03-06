//
//  Handlers.swift
//  Perfect-App-Template
//
//  Created by Jonathan Guthrie on 2017-02-20.
//	Copyright (C) 2017 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import StORM
import PerfectLocalAuthentication
import PerfectLib
//import SwiftRandom
//import PerfectSMTP

class Handlers {
    
	// Basic "main" handler - simply outputs "Hello, world!"
	static func main(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.securityCheck() else { response.badSecurityToken; return }

			let users = Account()
			try? users.findAll()
			if users.rows().count == 0 {
				response.redirect(path: "/initialize")
                response.completed(status: .ok)
				return
			}

            var context: [String : Any] = appExtras(request)

            // this allows the conditioning of the user pages based on if they are logged in or not
			if let i = request.session?.userid, !i.isEmpty { context["authenticated"] = true }
            
            // check to see if there are ant retailer thingies in the account
            if let i = request.session?.userid {
                let acc = Account()
                if ((try? acc.get(i)) != nil) {
                    // lets see if there is a retailer info on the account
                    if acc.detail["retailer"].isNotNil { context["retailer"] = true }
                }
            }

            response.addSourcePage("/")
            context["title_label"] = "Welcome"
            context["title"] = "Project Title"
            context["subtitle"] = "Project Subtitle"

			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }

			response.renderMustache(template: request.documentRoot + "/views/index.mustache", context: context)
            response.completed()
            return

		}
	}
    
    static func appleAppSiteAssociation(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.securityCheck() else { response.badSecurityToken; return }

            // Here we want to send back the webroot/apple file with application/json:
            let theFile = File(request.documentRoot+"/well-known/apple-app-site-association")
            
            if theFile.exists {
                do {
                    let theString = try theFile.readString()
                    // Make sure it can be casted to json before sending back:
                    _ = try theString.jsonDecode()
                    
                    return response.setBody(string: theString)
                                                .setHeader(.contentType, value: "application/json")
                                                // Set the cache control for the response.
                                                .setHeader(.cacheControl, value: "no-cache")
                                                .completed(status: .ok)
                    
                } catch {
                    return response.caughtError(error)
                }
                
            } else {
                try! response.setBody(json: ["errorCode":"AASAFileDNE","message":"The Apple App Site Association File currently does not exist on the webserver."])
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .noContent)
            }
            
        }
    }
    
    static func extras(_ request: HTTPRequest) -> [String : Any] {
        
        return [
            "token": request.session?.token ?? "",
            "csrfToken": request.session?.data["csrf"] as? String ?? ""
        ]
        
    }
    
    static func appExtras(_ request: HTTPRequest) -> [String : Any] {
        var priv = ""
        var isAdmin = false
        
        let id = request.session?.userid ?? ""
        if !id.isEmpty {
            let user = Account()
            try? user.get(id)
            priv = "\(user.usertype)"
            if user.usertype == .admin {
                isAdmin = true
            }
        }
        return [
            "title": RMServiceClass.sharedInstance.displayTitle,
            "subtitle": RMServiceClass.sharedInstance.displaySubTitle,
            "logo": RMServiceClass.sharedInstance.displayLogo,
            "srcset": RMServiceClass.sharedInstance.displayLogoSrcSet,
            "priv": priv,
            "admin": isAdmin
        ]
        
    }

    static func initialize(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.securityCheck() else { response.badSecurityToken; return }

            let users = Account()
            try? users.findAll()
            if users.rows().count > 0 {
                response.redirect(path: "/")
                response.completed(status: .ok)
                return
            }
            
            var context: [String : Any] = [String: Any]()
            
            // add app config vars
            for i in Handlers.appExtras(request) {
                context[i.0] = i.1
            }
            
            response.renderMustache(template: request.documentRoot + "/views/initialsetup.mustache", context: context)
            // response.renderMustache(template: request.documentRoot + "/views/login.mustache", context: context)
            response.completed()
            return

        }
    }
    
    static func initializeSave(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            let users = Account()
            try? users.findAll()
            if users.rows().count > 0 {
                response.redirect(path: "/")
                response.completed(status: .ok)
                return
            }
            
            Account.setup()
            let user = Account()
            var msg = ""
            
            if let firstname = request.param(name: "firstname"), !firstname.isEmpty,
                let lastname = request.param(name: "lastname"), !lastname.isEmpty,
                let email = request.param(name: "email"), !email.isEmpty,
                let username = request.param(name: "username"), !username.isEmpty{
                user.username = username.lowercased()
                user.detail["firstname"] = firstname
                user.detail["lastname"] = lastname
                user.detail["created"] = RMServiceClass.getNow()
                user.email = email
                
                if let pwd = request.param(name: "pw"), !pwd.isEmpty {
                    user.makePassword(pwd)
                }
                
                user.usertype = .admin
                
                user.makeID()
                try? user.create()
                
                // the user was created - so set the config corectly - not to run setup again
                if user.id != "" {
                    let c = RMConfig()
                    c.name = "sysinit"
                    c.val = "0"
                    try? c.save()
                }
                
            } else {
                print("Please enter the user's first and last name, as well as a valid email.")
                msg = "Please enter the user's first and last name, as well as a valid email."
                redirectRequest(request, response, msg: msg, template: request.documentRoot + "/views/initialsetup.mustache")
                // redirectRequest(request, response, msg: msg, template: request.documentRoot + "/views/login.mustache")
            }
            
            response.redirect(path: "/")
            response.completed(status: .temporaryRedirect)
            return
            
        }
    }

    //MARK:-
    //MARK: Used for the User Web management functions
    static func errorJSON(_ request: HTTPRequest, _ response: HTTPResponse, msg: String) {
        _ = try? response.setBody(json: ["error": msg])
        response.completed(status: .badRequest)
        return
    }

    // Used for healthcheck functionality for monitors and load balancers.
    // Do not remove unless you have an alternate plan
    static func healthcheck(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in

            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.securityCheck() else { response.badSecurityToken; return }

            let _ = try? response.setBody(json: ["health": "ok"])
            response.completed(status: .ok)
            return
        }
    }
    
    // Handles psuedo redirects.
    // Will serve up alternate content, for example if you wish to report an error condition, like missing data.
    static func redirectRequest(_ request: HTTPRequest, _ response: HTTPResponse, msg: String, template: String, additional: [String:String] = [String:String]()) {
        
        var context: [String : Any] = [
            "msg": msg
        ]
        for i in additional {
            context[i.0] = i.1
        }
        
        response.renderMustache(template: template, context: context)
        response.completed(status: .ok)
        return
    }

    
}
