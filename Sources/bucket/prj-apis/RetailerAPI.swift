//
//  RetailerAPI.swift
//  COpenSSL
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession
import SwiftMoment

//MARK: - Retailer API
/// This Retailer structure supports all the normal endpoints for a user based login application.
struct RetailerAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
                ["method":"post",    "uri":"/api/v1/billDenoms", "handler":billDenoms],
                ["method":"post",   "uri":"/api/v1/registerterminal", "handler":registerTerminal],
                ["method":"post",   "uri":"/api/v1/transaction/{retailerId}", "handler":createTransaction],
                ["method":"post",   "uri":"/api/v1/transaction", "handler":createTransaction],
                ["method":"post",   "uri":"/api/v1/report", "handler":report],
                ["method":"delete", "uri":"/api/v1/transaction/{customerCode}", "handler":deleteTransaction,],
                ["method":"put", "uri":"/api/v1/event", "handler":createOrUpdateEvent,],
                ["method":"delete", "uri":"/api/v1/event/{id}", "handler":deleteEvent,],
                ["method":"post", "uri":"/api/v1/events", "handler":getEvents,],
            ]
        }
        
        //MARK: - Fetch Events:
        public static func getEvents(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Do our normal stuff here:
                guard request.SecurityCheck() else { return response.badSecurityToken }
                
                // We should first bouce the retailer (takes care of all the general retailer errors):
                guard  let rt = Retailer.retailerTerminalBounce(request, response), !rt.bounced! else { return }
                
                // We will have a country passed in through the header:
                guard let _ = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)
                
                let offsetLimit = request.offsetLimit
                
                // Okay.  Lets first do the scenario when they have the id:
                do {
                    let json = try request.postBodyJSON()!
                    // We do not require a post body here.  It can be empty.
                    
                    let eventId = json.id ?? 0
                    let dates = request.epochDates
                    
                    var sqlStatement = "SELECT * FROM \(schema).getRetailerEvents(\(rt.retailer!.id!), \(eventId)"
                    
                    if dates.isNotNil {
                        sqlStatement.append(", \(dates!.start), \(dates!.end)")
                    }
                    
                    if offsetLimit.isNotNil {
                        sqlStatement.append(", \(offsetLimit!.offset), \(offsetLimit!.limit)")
                    }
                    
                    sqlStatement.append(")")
                    
                    if let events = try? RetailerEvent().sqlRows(sqlStatement, params: []) {
                        
                        var eventsJSON = [[String:Any]]()
                        
                        for event in events {
                            var eventJSON = [String:Any]()
                            eventJSON["id"] = event.data.id
                            if let modified = event.data.modified.intValue, modified > 0 {
                                eventJSON["modified"] = modified.dateString
                            }
                            if let modified = event.data.created.intValue, modified > 0 {
                                eventJSON["created"] = modified.dateString
                            }
                            eventJSON["eventName"] = event.data["event_name"].stringValue
                            eventJSON["eventMessage"] = event.data["event_message"].stringValue
                            eventJSON["startDate"] = event.data["start_date"].intValue?.dateString
                            eventJSON["endDate"] = event.data["end_date"].intValue?.dateString
                            eventsJSON.append(eventJSON)
                        }
                        
                        // Return the events!
                        return response.returnEvents(eventsJSON)
                        
                    } else {
                        return response.noEvents
                    }
                    
                } catch BucketAPIError.unparceableJSON(let theStr) {
                    return response.invalidRequest(theStr)
                } catch {
                    return response.caughtError(error)
                }
            }
        }
        
        //MARK: - Create Or Update Event:
        public static func createOrUpdateEvent(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Do our normal stuff here:
                guard request.SecurityCheck() else { return response.badSecurityToken }
                
                // We should first bouce the retailer (takes care of all the general retailer errors):
                guard  let rt = Retailer.retailerTerminalBounce(request, response), !rt.bounced! else { return }
                
                // We will have a country passed in through the header:
                guard let _ = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)
                
                do {
                    
                    let json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    // Okay, lets first check the dates.  They are required.
                    var epochStart : Int? = nil
                    var epochEnd : Int? = nil
                
                    if let startStr = json["start"].stringValue, let startDate = moment(startStr, dateFormat: "yyyy-MM-dd HH:mm:ssZZZ", timeZone: .utc), let endStr = json["end"].stringValue, let endDate = moment(endStr, dateFormat: "yyyy-MM-dd HH:mm:ssZZZ", timeZone: .utc) {
                        epochStart = Int(startDate.epoch())
                        epochEnd = Int(endDate.epoch())
                        guard epochStart! < epochEnd! else { return response.dateIssue }
                    } else if let startStr = json["start"].stringValue, let endStr = json["end"].stringValue {
                        return response.dateParseIssue(start: startStr, end: endStr)
                    }
                    
                    // If they sent the json id, they are updating:
                    let theEvent = RetailerEvent()
                    theEvent.retailer_id = rt.retailer?.id
                    if let id = json.id {
                        // THIS IS AN UPDATE:
                        // First check to see if this id exists:
                        guard RetailerEvent.exists(withId: id, schema: schema) else { return response.eventDNE }
                        
                        theEvent.id = id
                        theEvent.event_name = json["eventName"].stringValue
                        theEvent.event_message = json["eventMessage"].stringValue
                        // When updating, the start and end dates are not required:
                        theEvent.start_date = epochStart
                        theEvent.end_date = epochEnd
                        
                        _ = try? theEvent.saveWithCustomType(schemaIn: schema)
                        
                       return response.updatedEvent(id)
                        
                    } else {
                        // THIS IS A CREATE:
                        theEvent.event_name = json["eventName"].stringValue
                        theEvent.event_message = json["eventMessage"].stringValue
                        
                        // When creating, the start and end dates are required.
                        if epochStart.isNil || epochEnd.isNil { return response.eventDatesRequired }
                        
                        theEvent.start_date = epochStart
                        theEvent.end_date = epochEnd
                        
                        if let id = try! theEvent.saveWithCustomType(schemaIn: schema).first?.data.id {
                            theEvent.id = id
                            return response.createdEvent(id)
                        } else {
                            return response.caughtError(NSError(domain: "PUT /event", code: 500, userInfo: [NSLocalizedDescriptionKey : "There was a database error attempting to create your event."]))
                        }
                        
                    }
                    
                } catch BucketAPIError.unparceableJSON(let theString) {
                    return response.invalidRequest(theString)
                } catch {
                    return response.caughtError(error)
                }
                
            }
        }
        
        //MARK: - Delete Event:
        public static func deleteEvent(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // Do our normal stuff here:
                guard request.SecurityCheck() else { return response.badSecurityToken }
                
                // We should first bouce the retailer (takes care of all the general retailer errors):
                guard  let rt = Retailer.retailerTerminalBounce(request, response), !rt.bounced! else { return }
                
                // We will have a country passed in through the header:
                guard let _ = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)
                
                guard let eventId = request.urlVariables["id"]!.intValue, RetailerEvent.exists(withId: eventId, schema: schema) else { return response.eventDNE }
                
                // Okay.. we need to check if we have any transactions associated with this event.  If we do, then we need to return an error.
                guard !rt.retailer!.hasTransactionsInEvent(eventId: eventId) else { return response.cannotDeleteEvent }
                
                let event = RetailerEvent()
                event.id = eventId
                _ = try? event.softDeleteWithCustomType(schemaIn: schema)
                
                return response.eventDeleted
                
            }
        }
        
        //MARK: - Get Bill Denominations:
        public static func billDenoms(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }

                // We will have a country passed in through the header:
                guard let _ = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)
                
                var bodyReturn:[String:Any]? = nil
                
                switch schema {
                case "us":
                // Return the US denominations:
                    bodyReturn = ["usesNaturalChangeFunction":true, "denominations":[100.00, 50.00, 20.00, 10.00, 5.00, 2.00, 1.00], "currencyDecimals":2]
                    break
                case "sg":
                // Return the SG Denominations:
                    bodyReturn = ["usesNaturalChangeFunction":true, "denominations":[100.00, 50.00, 20.00, 10.00, 5.00, 2.00], "currencyDecimals":2]
                    break
                default:
                    return response.unsupportedCountry
                }
                
                AuditRecordActions.pageView(schema: schema,
                                            session_id: request.session?.token ?? "NO SESSION TOKEN",
                                            page: "/api/v1/billDenoms",
                                            row_data: bodyReturn,
                                            description: nil,
                                            viewedby: request.session?.userid ?? "NO SESSION USER")
                
                if bodyReturn.isNotNil {
                    _ = try? response.setBody(json: bodyReturn).setHeader(.custom(name: "Content-Type"), value: "application/json; charset=UTF-8").completed(status: .ok)
                }
            }
        }
        
        //MARK: - Register Terminal Function
        public static func registerTerminal(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }

                // *IMPORTANT*  If this is development, then we can automatically verify the device.  If we are production, then we will make them to go the web and verify the device is theirs.
                
                do {
                    
                    // Get our post body JSON.  This will throw an error, along with the string that it tried parsing.
                    let json = try request.postBodyJSON()
                    // Throw an error if the json body is empty.  We should have something in the post body JSON here.
                    guard !json!.isEmpty else { return response.emptyJSONBody }
                    
                    guard (request.countryId) != nil else {  response.invalidCountryCode; return }
                    
                    let schema = Country.getSchema(request)
//                    var retailerIntegerId = 0

                    let r = Retailer()

                    if let retcode = request.getRetailerCode() {
                        // there is only one retailer code per schema (one retailer per retailer_code)
                        let sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(retcode.lowercased())'"
                        let r_ret = try? r.sqlRows(sql, params: [])
                        for i in r_ret! {
                            r.to(i)
//                            retailerIntegerId = r.id!
                        }
                    } else {
                        return response.invalidRetailer
                    }
                    
                    guard let serialNumber = json?["terminalId"].stringValue else { return response.noTerminalId }
                    guard let server = EnvironmentVariables.sharedInstance.Server else { return response.serverEnvironmentError }
                    guard let _ = request.countryId else { return response.invalidCountryCode }
                
                    // If there is only one location, lets automagically attach it to the one location for this retailer
                    let add = Address()
                    let add_sql = "SELECT * FROM \(schema).\(add.table()) WHERE retailer_id = \(r.id!)"
                    let addresses = try? add.sqlRows(add_sql, params: [])
                    if let _ = addresses, addresses!.count == 1, let a = addresses!.first {
                        let a_sql = "SELECT * FROM \(schema).\(add.table()) WHERE id = \(a.data.id!)"
                        let adr = try? add.sqlRows(a_sql, params: [])
                        if adr.isNotNil {
                            add.to(adr!.first!)
                        }
                    }
 //MARK--
// CHANGE ME WHEN THE WEBPAGE IS UP
                    switch server {
                    // Production & Staging are acting the same.
//                    case .production, .staging:
                    case .production:
                        // We should do everything like regular here:
                        
                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                        let terminal = Terminal()
                        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(serialNumber)' "
                        let trm = try? terminal.sqlRows(sql, params: [])
                        if let t = trm?.first {
                            terminal.to(t)
                        }
                        
                        
                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
                            
                            let term = Terminal()
                            
                            let apiKey = UUID().uuidString
                            term.serial_number = serialNumber
                            term.retailer_id = r.id!
                            term.terminal_key = apiKey.ourPasswordHash

                            // there is only one address for this company
                            if add.id.isNotNil {
                                term.address_id = add.id
                            }

                            if let rc_s = r.retailer_code, rc_s == "bucket-s" {
                                term.is_sample_only = true
                                term.is_approved    = true
                            }

                            do {
                                
                                try term.saveWithCustomType(schemaIn: schema)
                                
                                var terminfo:[String:Any] = [:]
                                terminfo["retailerName"] = r.name!
                                
                                if term.address_id.isNotNil, term.address_id! > 0 {
                                    // look up the address for the address information
                                    let addresshere = Address()
                                    let a_sql = "SELECT * FROM \(schema).\(addresshere.table()) WHERE id = \(term.address_id!)"
                                    if let a = try? addresshere.sqlRows(a_sql, params: []) {
                                        addresshere.to(a.first!)
                                        
                                        var termadd:[String:Any] = [:]
                                        if let a1 = addresshere.address1, !a1.isEmpty { termadd["address1"] = a1 }
                                        if let a1 = addresshere.address2, !a1.isEmpty { termadd["address2"] = a1 }
                                        if let a1 = addresshere.address3, !a1.isEmpty { termadd["address3"] = a1 }
                                        if let a1 = addresshere.postal_code, !a1.isEmpty { termadd["postalCode"] = a1 }
                                        if let a1 = addresshere.city, !a1.isEmpty { termadd["city"] = a1 }
                                        if let a1 = addresshere.state, !a1.isEmpty { termadd["state"] = a1 }
                                        
                                        terminfo["address"] = termadd
                                    }
                                }
                                
                                var retInfo:[String:Any] = [:]
                                retInfo["isApproved"]        = term.is_approved
                                // Only return this if the terminal IS for samples:
                                if term.is_sample_only {
                                    retInfo["isSample"]          = term.is_sample_only
                                }
                                retInfo["apiKey"]            = apiKey
                                retInfo["requireEmployeeId"] = term.require_employee_id
                                
                                retInfo.merge(terminfo, uniquingKeysWith: { (current, _) in current })
                                
                                var arec = term.asDictionary()
                                arec.merge(retInfo, uniquingKeysWith: { (current, _) in current })
                                
                                AuditRecordActions.terminalAdd(schema: schema,
                                                               session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                               user: request.session?.userid ?? "NO SESSION USER",
                                                               row_data: arec,
                                                               changed_fields: nil,
                                                               description: nil,
                                                               changedby: nil)
                                

                                try? response.setBody(json: retInfo)
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .created)
                                
                            } catch {
                                // Return some caught error:
                                response.caughtError(error)
                                return
                            }
                            
                        } else {
                            
                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
                            guard r.id! == terminal.retailer_id else { return response.alreadyRegistered(serialNumber) }
                            
                            // Save the new password, and return the response:
                            let thePassword = UUID().uuidString
                            
                            // Build the response:
                            var responseDictionary = [String:Any]()
                            responseDictionary["isApproved"] = terminal.is_approved
                            // Only return this if the terminal IS for samples:
                            if terminal.is_sample_only {
                                responseDictionary["isSample"]          = terminal.is_sample_only
                            }
                            responseDictionary["apiKey"] = thePassword
                            responseDictionary["requireEmployeeId"] = terminal.require_employee_id

                            var terminfo:[String:Any] = [:]
                            terminfo["retailerName"] = r.name!
                            
                            if terminal.address_id.isNotNil, terminal.address_id! > 0 {
                                // look up the address for the address information
                                let addresshere = Address()
                                let a_sql = "SELECT * FROM \(schema).\(addresshere.table()) WHERE id = \(terminal.address_id!)"
                                if let a = try? addresshere.sqlRows(a_sql, params: []) {
                                    addresshere.to(a.first!)
                                    
                                    var termadd:[String:Any] = [:]
                                    if let a1 = addresshere.address1, !a1.isEmpty { termadd["address1"] = a1 }
                                    if let a1 = addresshere.address2, !a1.isEmpty { termadd["address2"] = a1 }
                                    if let a1 = addresshere.address3, !a1.isEmpty { termadd["address3"] = a1 }
                                    if let a1 = addresshere.postal_code, !a1.isEmpty { termadd["postalCode"] = a1 }
                                    if let a1 = addresshere.city, !a1.isEmpty { termadd["city"] = a1 }
                                    if let a1 = addresshere.state, !a1.isEmpty { termadd["state"] = a1 }
                                    
                                    terminfo["address"] = termadd
                                }
                            }

                            responseDictionary.merge(terminfo, uniquingKeysWith: { (current, _) in current })
                            
                            // Create and assign the hashed password:
                            terminal.terminal_key = thePassword.ourPasswordHash
                            
                            // Save:
                            try terminal.saveWithCustomType(schemaIn: schema)
                            
                            // Return the response:
                            try? response.setBody(json: responseDictionary)
                                .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                .completed(status: .ok)
                            
                        }
                        
                        break
// MARK--
// CHANGE WHEN THE WEB PAGES ARE UP
//                    case .development:
                    case .development, .staging:
                        // In development, we are automatically setting the terminal as approved, so they do not need to go to the web.
                        
                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                        let terminal = Terminal()
                        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(serialNumber)' "
                        let trm = try? terminal.sqlRows(sql, params: [])
                        if let t = trm?.first {
                            terminal.to(t)
                        }
                        
                        // we will take the first address on file for this retailer and add the location here for them
                        let add = Address()
                        let a_sql = "SELECT * FROM \(schema).address WHERE retailer_id = '\(r.id!)'"
                        let a_res = try? add.sqlRows(a_sql, params: [])
                        if let a = a_res?.first {
                            add.to(a)
                        }
                        
                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
                            let term = Terminal()
                            
                            let apiKey = UUID().uuidString
                            term.serial_number = serialNumber
                            term.retailer_id = r.id!
                            term.terminal_key = apiKey.ourPasswordHash

                            // auto approval:
                            term.is_approved = true

                            if add.id.isNotNil, add.retailer_id == r.id! {
                                term.address_id = add.id
                            }
                            
                            if let rc_s = r.retailer_code, rc_s == "bucket-s" {
                                term.is_sample_only = true
                                term.is_approved    = true
                            }

                            var terminfo:[String:Any] = [:]
                            terminfo["retailerName"] = r.name!
                            
                            if term.address_id.isNotNil, term.address_id! > 0 {
                                // look up the address for the address information
                                let addresshere = Address()
                                let a_sql = "SELECT * FROM \(schema).\(addresshere.table()) WHERE id = \(term.address_id!)"
                                if let a = try? addresshere.sqlRows(a_sql, params: []) {
                                    addresshere.to(a.first!)
                                    
                                    var termadd:[String:Any] = [:]
                                    if let a1 = addresshere.address1, !a1.isEmpty { termadd["address1"] = a1 }
                                    if let a1 = addresshere.address2, !a1.isEmpty { termadd["address2"] = a1 }
                                    if let a1 = addresshere.address3, !a1.isEmpty { termadd["address3"] = a1 }
                                    if let a1 = addresshere.postal_code, !a1.isEmpty { termadd["postalCode"] = a1 }
                                    if let a1 = addresshere.city, !a1.isEmpty { termadd["city"] = a1 }
                                    if let a1 = addresshere.state, !a1.isEmpty { termadd["state"] = a1 }
                                    
                                    terminfo["address"] = termadd
                                }
                            }
                            
                            var retInfo:[String:Any] = [:]
                            retInfo["isApproved"] = term.is_approved
                            // Only return this if the terminal IS for samples:
                            if term.is_sample_only {
                                retInfo["isSample"]   = term.is_sample_only
                            }
                            retInfo["apiKey"]     = apiKey
                            retInfo["requireEmployeeId"] = term.require_employee_id
                            
                            retInfo.merge(terminfo, uniquingKeysWith: { (current, _) in current })
                            
                            var audit:[String:Any] = [:]
                            audit.merge(retInfo, uniquingKeysWith: { (current, _) in current })
                            audit["terminal"] = term.asDictionary()

                            AuditRecordActions.terminalAdd(schema: schema,
                                                           session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                           user: request.session?.userid ?? "NO SESSION USER",
                                                           row_data: audit,
                                                           changed_fields: nil,
                                                           description: nil,
                                                           changedby: nil)
                            
                            do {
                                
                                try term.saveWithCustomType(schemaIn: schema)
                                try? response.setBody(json: retInfo )
                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                    .completed(status: .created)
                                
                            } catch {
                                // Return some caught error:
                                response.caughtError(error)
                                return
                            }

                        } else if terminal.retailer_id.isNotNil && terminal.is_approved {
                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
                            guard r.id! == terminal.retailer_id else { /* Send back an error indicating this device is on another account */  return response.alreadyRegistered(serialNumber) }

                            // Save the new password, and return the response:
                            let thePassword = UUID().uuidString

                            // if the address has nnot ben set, and there is only one address, set it to that address
                            if let ta = terminal.address_id, ta == 0, add.id.isNotNil {
                                terminal.address_id = add.id
                            }

                            // Build the response:
                            var responseDictionary = [String:Any]()
                            responseDictionary["isApproved"] = terminal.is_approved
                            // Only return this if the terminal IS for samples:
                            if terminal.is_sample_only {
                                responseDictionary["isSample"]   = terminal.is_sample_only
                            }
                            responseDictionary["apiKey"] = thePassword
                            responseDictionary["requireEmployeeId"] = terminal.require_employee_id

                            if terminal.address_id.isNotNil, terminal.address_id! > 0 {
                                // look up the address for the address information
                                let addresshere = Address()
                                let a_sql = "SELECT * FROM \(schema).\(addresshere.table()) WHERE id = \(terminal.address_id!)"
                                if let a = try? addresshere.sqlRows(a_sql, params: []) {
                                    addresshere.to(a.first!)
                                    
                                    var termadd:[String:Any] = [:]
                                    if let a1 = addresshere.address1, !a1.isEmpty { termadd["address1"] = a1 }
                                    if let a1 = addresshere.address2, !a1.isEmpty { termadd["address2"] = a1 }
                                    if let a1 = addresshere.address3, !a1.isEmpty { termadd["address3"] = a1 }
                                    if let a1 = addresshere.postal_code, !a1.isEmpty { termadd["postalCode"] = a1 }
                                    if let a1 = addresshere.city, !a1.isEmpty { termadd["city"] = a1 }
                                    if let a1 = addresshere.state, !a1.isEmpty { termadd["state"] = a1 }
                                    
                                    responseDictionary["address"] = termadd
                                }
                            }

                            // Create and assign the hashed password:
                            terminal.terminal_key = thePassword.ourPasswordHash
                            
                            var audit:[String:Any] = [:]
                            audit.merge(responseDictionary, uniquingKeysWith: { (current, _) in current })
                            audit["terminal"] = terminal.asDictionary()
                            
                            AuditRecordActions.terminalAdd(schema: schema,
                                                           session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                           user: request.session?.userid ?? "NO SESSION USER",
                                                           row_data: audit,
                                                           changed_fields: nil,
                                                           description: nil,
                                                           changedby: nil)
                            
                            // Save:
                            let _ = try? terminal.saveWithCustomType(schemaIn: schema)
                            
                            // Return the response:
                            try? response.setBody(json: responseDictionary)
                                .setHeader(.contentType, value: "application/json; charset=UTF-8")
                                .completed(status: .ok)
                        }
                        
                    }
                    
                } catch BucketAPIError.unparceableJSON(let invalidJSONString) {
                    return response.invalidRequest(invalidJSONString)
                    
                } catch {
                    // Not sure what error could be thrown here, but the only one we throw right now is if the JSON is unparceable.
                    // Return some caught error:
                    response.caughtError(error)
                    return
                }
            }
        }
        
        public static func report(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }
                
                // We should first bouce the retailer (takes care of all the general retailer errors):
                guard  let rt = Retailer.retailerTerminalBounce(request, response), !rt.bounced! else { return }
                
                guard let _ = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)
                
                // Here we may be requiring the employeeId.  SO we will have the employeeId also in the JSON to give the flexibility to change the report.
                if let t = rt.terminal, t.require_employee_id {
                    // If we require the id, and it is empty or nil, return an error:
                    guard !request.employeeId.isEmptyOrNil else { return response.invalidEmployeeId }
                    let check = t.checkEmployeeId(request.employeeId!, schema)
                    guard check.success else { return response.invalidEmployeeId }
                }
                
                var retailerUserId : Int = 0
                let offsetLimit = request.offsetLimit
                
                do {
                    
                    let requestJSON = try request.postBodyJSON()!
                    if requestJSON.isEmpty { return response.emptyJSONBody }
                    
                    // Here we will set the retailerUserId for the query of the request:
                    if let retailerUserCode = requestJSON["employeeId"].stringValue, let t = rt.terminal {
                        let check = t.checkEmployeeId(retailerUserCode, schema)
                        retailerUserId = check.retailerUserId ?? 0
                    }
                    
                    // Okay, theres 3 different ways they can send the dates in here:
                    // 1. As an integer.
                    // 2. As a string.
                    // 3. As a start and end string.
                    
                    var startOrFrom = 0
                    var endOrTo = 0
                    
                    if let day = requestJSON["day"].stringValue {
                        
                        if let startMoment = moment(day, dateFormat: "yyyy-MM-dd", timeZone: .utc) {
                            // Lets make sure we are getting the very end of the day, in the correct timezone:
                            let endMoment = moment(["year":startMoment.year,
                                                                                   "month":startMoment.month,
                                                                                   "day":startMoment.day,
                                                                                   "hour":23,
                                                                                   "minute":59,
                                                                                   "second":59,],
                                                                                    timeZone: .utc)!
                            
                            startOrFrom = Int(startMoment.epoch())
                            endOrTo = Int(endMoment.epoch())
                            
                        }
                        
                    } else {
                        // Okay they sent start & end.  Lets see if its a string or an integer epoch date:
                        if let start = requestJSON["start"], let end = requestJSON["end"] {
                            
                            if let start = start as? String, let theMoment = moment(start, dateFormat: "yyyy-MM-dd HH:mm:ssZZZ", timeZone: .utc) {
                                startOrFrom = Int(theMoment.epoch())
                            } else if let start = start as? Int {
                                startOrFrom = start
                            }
                            if let end = end as? String, let theMoment = moment(end, dateFormat: "yyyy-MM-dd HH:mm:ssZZZ", timeZone: .utc) {
                                endOrTo = Int(theMoment.epoch())
                            } else if let end = end as? Int {
                                endOrTo = end
                            }
                        }
                        
                    }
                    
                    var terminalId : Int = 0
                    if let terminalSerial = requestJSON["terminalId"].stringValue {
                        if let id = Terminal.idFrom(schema, rt.retailer!.id!, terminalSerial: terminalSerial) {
                            terminalId = id
                        } else {
                            return response.invalidTerminalId
                        }
                    }
                    
                    if startOrFrom > endOrTo { return response.dateIssue }
                    
                    var sqlStatement = ""
                    
                    if offsetLimit.isNil {
                        sqlStatement = "SELECT * FROM \(schema).getTransactionReport(\(startOrFrom), \(endOrTo), \(rt.retailer!.id!), \(terminalId), \(retailerUserId));"
                    } else {
                        sqlStatement = "SELECT * FROM \(schema).getTransactionReport(\(startOrFrom), \(endOrTo), \(rt.retailer!.id!), \(terminalId), \(retailerUserId),\(offsetLimit!.offset), \(offsetLimit!.limit));"
                    }
                    
                    let rows = try? CodeTransaction().sqlRows(sqlStatement, params: [])
                    
                    if let transactions = rows, !transactions.isEmpty {
                        var bucketTotal = 0.0
                        var transactionsJSON : [[String:Any]] = []
                        for transaction in transactions {
                            var transjson = [String:Any]()
                            
                            if let id = transaction.data.id {
                                transjson["bucketTransactionId"] = id
                            }
                            if let created = transaction.data["created"].intValue, created > 0 {
                                transjson["created"] = created.dateString
                            }
                            if let amount = transaction.data["amount"].doubleValue {
                                transjson["amount"] = amount
                                bucketTotal += amount
                            }
                            if let totalAmount = transaction.data["total_amount"].doubleValue {
                                transjson["totalTransactionAmount"] = totalAmount
                            }
                            if let clientTransactionId = transaction.data["client_transaction_id"].doubleValue {
                                transjson["clientTransactionId"] = clientTransactionId
                            }
                            if let locationId = transaction.data["client_location"].doubleValue {
                                transjson["locationId"] = locationId
                            }
                            if let disputed = transaction.data["disputed"].intValue, disputed > 0 {
                                transjson["disputed"] = disputed.dateString
                            }
                            if let disputedBy = transaction.data["disputedby"].stringValue {
                                transjson["disputedBy"] = disputedBy
                            }
                            if let redeemed = transaction.data["redeemed"].intValue, redeemed > 0 {
                                transjson["redeemed"] = redeemed.dateString
                            }
                            if let terminalId = transaction.data["terminal_id"].intValue {
                                transjson["terminalId"] = terminalId
                            }
                            
                            transactionsJSON.append(transjson)
                            
                        }
                        
                        return response.returnReport(bucketTotal, transactions: transactionsJSON)
                        
                    } else {
                        
                        return response.emptyReport(start: startOrFrom, end: endOrTo)
                        
                    }
    
                } catch BucketAPIError.unparceableJSON(let theString) {
                    return response.invalidRequest(theString)
                } catch {
                    return response.caughtError(error)
                }
            
                // We use a function here to get the report:
                // Start Date, End Date, RetailerID, TerminalID
                
                
            }
        }
        
        //MARK: - Register Terminal Function
        public static func unregisterTerminal(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }

                // *IMPORTANT*  If this is development, then we can automatically verify the device.  If we are production, then we will make them to go the web and verify the device is theirs.
                
                do {
                    
                    // Get our post body JSON.  This will throw an error, along with the string that it tried parsing.
                    let json = try request.postBodyJSON()
                    // Throw an error if the json body is empty.  We should have something in the post body JSON here.
                    guard !json!.isEmpty else { return response.emptyJSONBody }
                    
                    // This should be the retailerBounce part:
                    guard let retailerIntegerId = Retailer.retailerBounce(request, response) else { return }
                    guard let serialNumber = json?["terminalId"].stringValue else { return response.noTerminalId }
                    guard let server = EnvironmentVariables.sharedInstance.Server else { return response.serverEnvironmentError }
                    guard let _ = request.countryId else { return response.invalidCountryCode }
                    
                    let schema = Country.getSchema(request)

                    
                    switch server {
                    // Production & Staging are acting the same.
                    case .production, .staging:
                        // We should do everything like regular here:
                        
//                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
//                        let terminal = Terminal()
//                        try terminal.find(["serial_number": serialNumber])
//
//                        // Check and make sure the terminal is approved or not:
//                        if terminal.id.isNil {
//                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
//                            let term = Terminal()
//
//                            let apiKey = UUID().uuidString
//                            term.serial_number = serialNumber
//                            term.retailer_id = retailerIntegerId
//                            term.terminal_key = apiKey.ourPasswordHash
//
//                            do {
//
//                                try term.saveWithCustomType()
//                                try? response.setBody(json: ["isApproved":false, "apiKey":apiKey])
//                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                    .completed(status: .created)
//
//                            } catch {
//                                // Return some caught error:
//                                try? response.setBody(json: ["error":error.localizedDescription])
//                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                    .completed(status: .internalServerError)
//                            }
//
//                        } else {
//
//                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
//                            guard retailerIntegerId == terminal.retailer_id else { return response.alreadyRegistered(serialNumber) }
//
//                            // Save the new password, and return the response:
//                            let thePassword = UUID().uuidString
//
//                            // Build the response:
//                            var responseDictionary = [String:Any]()
//                            responseDictionary["isApproved"] = terminal.is_approved
//                            responseDictionary["apiKey"] = thePassword
//
//                            // Create and assign the hashed password:
//                            terminal.terminal_key = thePassword.ourPasswordHash
//
//                            // Save:
//                            try terminal.saveWithCustomType()
//
//                            // Return the response:
//                            try? response.setBody(json: responseDictionary)
//                                .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                .completed(status: .ok)
//
//                        }
                        
                        break
                    case .development:
                        // In development, we are automatically setting the terminal as approved, so they do not need to go to the web.
                        
                        // We need to check if the terminal exists, if it doesn't we send back a thing telling them to go and approve the device.
                        let terminal = Terminal()
                        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(serialNumber)' "
                        let trmn = try? terminal.sqlRows(sql, params: [])
                        if trmn.isNotNil, let c = trmn!.first {
                            terminal.to(c)
                        }

                        // Check and make sure the terminal is approved or not:
                        if terminal.id.isNil {
                            // The terminal does not exist for this retailer.  Lets create the terminal & password and send it back to the client:
//                            let term = Terminal()
//
//                            let apiKey = UUID().uuidString
//                            term.is_approved = true
//                            term.serial_number = serialNumber
//                            term.retailer_id = retailerIntegerId
//                            term.terminal_key = apiKey.ourPasswordHash
//
//                            // we will take the first address on file for this retailer and add the location here for them
//                            let add = Address()
//                            try? add.find(["retailer_id" : String(retailerIntegerId)])
//
//                            if add.id.isNotNil, add.retailer_id == retailerIntegerId {
//                                term.address_id = add.id
//                            }
//
//                            do {
//
//                                try term.saveWithCustomType()
//                                try? response.setBody(json: ["isApproved":true, "apiKey":apiKey])
//                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                    .completed(status: .created)
//
//                            } catch {
//                                // Return some caught error:
//                                try? response.setBody(json: ["error":error.localizedDescription])
//                                    .setHeader(.contentType, value: "application/json; charset=UTF-8")
//                                    .completed(status: .internalServerError)
//                            }
//
                        } else if terminal.retailer_id.isNotNil {
                            // The terminal does exist.  Lets see if we retailer id is the same as what they are saying, if so.. send them a password:
                            guard retailerIntegerId == terminal.retailer_id else { /* Send back an error indicating this device is on another account */  return response.alreadyRegistered(serialNumber) }
                            
                            // If they are who they say they are, we will go and unregister the terminal:
                            let _  = try? terminal.softDeleteWithCustomType(schemaIn: schema)
                            
                        }
                        
                    }
                    
                } catch BucketAPIError.unparceableJSON(let invalidJSONString) {
                    return response.invalidRequest(invalidJSONString)
                    
                } catch {
                    // Not sure what error could be thrown here, but the only one we throw right now is if the JSON is unparceable.
                    // Return some caught error:
                    response.caughtError(error)
                    return
                }
            }
        }
        
        //MARK: - Create Transaction
        public static func createTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }
            
                // We should first bouce the retailer (takes care of all the general retailer errors):
                guard  let rt = Retailer.retailerTerminalBounce(request, response), !rt.bounced! else { return }
                
                guard let _ = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)
                
                var theEventId : Int = 0
                if let eventId = request.eventId {
                    guard RetailerEvent.exists(withId: eventId, schema: schema) else { return response.eventDNE }
                    // Okay.. lets make sure we aren't past the ending date ->
                    let event = try? RetailerEvent().sqlRows("SELECT * FROM \(schema).retailer_event_view_deleted_no WHERE id = \(eventId);", params: []).first
                    let now = CCXServiceClass.getNow()
                    
                    if let endDate = event??.data["end_date"].intValue, now >= endDate {
                        return response.eventClosed
                    } else {
                        theEventId = event??.data.id ?? 0
                    }
                }
                
                var retailerUserId : Int? = nil
                
                if let t = rt.terminal, t.require_employee_id {
                    // If we require the id, and it is empty or nil, return an error:
                    guard !request.employeeId.isEmptyOrNil else { return response.invalidEmployeeId }
                     let check = t.checkEmployeeId(request.employeeId!, schema)
                    guard check.success else { return response.invalidEmployeeId }
                    
                    retailerUserId = check.retailerUserId
                    
                }
                
                do {

                    // we are using the json variable to return the code too.
                    var json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    // get the code
                    if let t = rt.terminal, t.is_sample_only {
                        json["sample"] = true
                    }
                    var ccode = Retailer().createCustomerCode(schemaId: schema, json)
                    
                    // loop until we get a customer code that is unique
                    while !ccode.success {
                        ccode = Retailer().createCustomerCode(schemaId: schema, json)
                    }
                    
//                    var itsASample = false
//                    if let sample = json!["sample"].boolValue {
//                        itsASample = sample
//                    }
                    
                    // put together the return dictionary
                    if ccode.success {
                        
                        let thecode: String = ccode.message
//                        if itsASample { thecode.append(".SAMPLE") }
                    
                        json["customerCode"] = thecode
                        
                        var qrCodeURL = ""
                        qrCodeURL.append(EnvironmentVariables.sharedInstance.PublicServerApiURL?.absoluteString ?? "")
                        qrCodeURL.append("redeem/")
                        qrCodeURL.append(thecode)
                        json["qrCodeContent"] = qrCodeURL
                        
                        var sql = ""
                        
                        // We need to go and get the integer terminal id:
                        var retailer = Retailer()
                        if let r = rt.retailer {
                            retailer = r
                        } else {
                            sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(request.getRetailerCode()!)' "
                            let rtlr = try? retailer.sqlRows(sql, params: [])
                            if rtlr.isNotNil, let c = rtlr!.first {
                                retailer.to(c)
                            }
                        }
                        
                        var terminal:Terminal
                        if let t = rt.terminal {
                            terminal = t
                        } else {
                            terminal = Terminal()
                            sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(request.terminalId!)' "
                            let trmn = try? terminal.sqlRows(sql, params: [])
                            if trmn.isNotNil, let c = trmn!.first {
                                terminal.to(c)
                                
                                // this means that there was an issue with the retailer ID - lets catch up
                                sql = "SELECT * FROM \(schema).retailer WHERE id = \(terminal.retailer_id!)"
                                if let ret_2 = try? terminal.sqlRows(sql, params: []), let rt2 = ret_2.first {
                                    retailer.to(rt2)
                                }
                                
                            }
                        }
                        
                        // lets get the country id for this transaction
                        let add = Address()
                        sql = "SELECT * FROM \(schema).address WHERE id = \(String(terminal.address_id!)) "
                        let adr = try? terminal.sqlRows(sql, params: [])
                        if adr.isNotNil, let c = adr!.first {
                            add.to(c)
                        }

                        let transaction = CodeTransaction()
                        transaction.created = CCXServiceClass.getNow()
                        transaction.retailer_user_id = retailerUserId
                        transaction.event_id = theEventId
                        transaction.amount = json["amount"].doubleValue
                        transaction.amount_available = json["amount"].doubleValue
                        transaction.total_amount = json["totalTransactionAmount"].doubleValue
                        transaction.client_location = json["locationId"].stringValue
                        transaction.client_transaction_id = json["clientTransactionId"].stringValue
                        transaction.terminal_id = terminal.id
                        transaction.retailer_id = retailer.id
                        transaction.customer_code = json["customerCode"].stringValue
                        transaction.customer_codeurl = json["qrCodeContent"].stringValue
                        if let cc = add.country_id {
                            transaction.country_id = cc
                        }
                        transaction.description = retailer.name
                        
                        // Save the transaction
                        let trn = try? transaction.saveWithCustomType(schemaIn: schema, CCXDefaultUserValues.user_server)
                        if let t = trn?.first, let tid = t.data["id"]  {
                            transaction.id = (tid as! Int)
                        }
                        // and now - lets save theb transaction in the Audit table
                        AuditFunctions().addCustomerCodeAuditRecord(transaction)
                        
                        json["bucketTransactionId"] = transaction.id
                        
                        var rn:[String:Any] = transaction.asDictionary()
                        for (key, val) in json {
                            rn[key] = val
                        }
                        
                        AuditRecordActions.customerCodeAdd(schema: schema,
                                                           session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                           row_data: rn,
                                                           changed_fields: nil,
                                                           description: "Customer Code \(transaction.customer_code!) was created",
                                                           changedby: nil)
                        
                        
                        // if we are here then everything went well
                        try? response.setBody(json: json)
                            .completed(status: .ok)
                        return
                    }
                    
                    // we have to work on the correct error return codes
                    // ideas?
                    try? response.setBody(json: json)
                        .completed(status: .ok)
                    
                } catch BucketAPIError.unparceableJSON(let invalidJSONString) {
                    return response.invalidRequest(invalidJSONString)
                } catch {
                    // Not sure what error could be thrown here, but the only one we throw right now is if the JSON is unparceable.
                    return response.caughtError(error)
                }
                
            }
        }

        
        //MARK: - Delete Transaction
        public static func deleteTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }
                
                // We should first bouce the retailer (takes care of all the general retailer errors):
                guard let rt = Retailer.retailerTerminalBounce(request, response), !rt.bounced! else { return }
                
                guard let code = request.customerCode else { response.invalidCustomerCode; return }
                guard let _ = request.countryId else { response.invalidCountryCode; return }
                
                let schema = Country.getSchema(request)
                
                // note that since the unclaimed codes are not in the individual countries (yet), there is only one table in the public schema to deal with
                // get the code from the url path
                // lets see if the code has not been redeemed yet :)
                let thecode = CodeTransaction()
                
                let sql = "SELECT * FROM \(schema).code_transaction WHERE customer_code = '\(code)' "
                let cde = try? thecode.sqlRows(sql, params: [])
                if cde.isNotNil, let c = cde!.first {
                    thecode.to(c)
                } else {
                    // check for the already redeemed
                    let sqld = "SELECT * FROM \(schema).code_transaction_history WHERE customer_code = '\(code)' "
                    let cded = try? thecode.sqlRows(sqld, params: [])
                    if cded.isNotNil, cded!.count > 0 {
                        // it was already redeemed - we CANNOT delete!
                        _ = try? response.setBody(json: ["errorCode":"CodeRedeemed","message":"The code was redeemed already.  Please Contact Bucket Support."])
                        response.completed(status: .custom(code: 452, message: "Code Already Redeemed"))
                        return
                    }
                }

                // We should also check and make sure the retailer is deleting their own transaction:
                guard let retailerId = request.retailer?.id, thecode.retailer_id == retailerId else { return response.incorrectRetailer }
                
                // Check if we have a returning object:
                if thecode.id.isNotNil {

                    // see if the code is deleted
                    guard thecode.deleted! == 0 else { _ = try? response.setBody(json: ["errorCode":"CodeDeleted","message":"The code was already deleted."])
                        response.completed(status: .custom(code: 451, message: "Code Already Deleted"))
                        return }
                    
                    // Make sure the retailers match:
                    // Return a general error with a different status code that we will know that the retailers are not matching.
                    // We will tell them to go to Bucket for support.  If they report an error of code 454, we know there is an issue with the retailers matching.
                    let retailer = Retailer()
                    let sql = "SELECT * FROM \(schema).retailer WHERE id = '\(request.retailerId!)' "
                    let rtlr = try? retailer.sqlRows(sql, params: [])
                    if rtlr.isNotNil, let c = rtlr!.first {
                        retailer.to(c)
                    }

                    guard thecode.retailer_id == retailer.id else { _ = try? response.setBody(json: ["errorCode":"UnexpectedIssue","message":"There is an issue with this transaction.  Please contact Bucket Support."])
                        response.completed(status: .custom(code: 454, message: "Contact Support"))
                        return }
                    
                    // lets delete the code
                    thecode.deleted = CCXServiceClass.getNow()
                    
                    let terminal = request.terminal!
                    thecode.deleted_reason = "Terminal \(terminal.serial_number!) deleted this transaction at \(thecode.deleted!.dateString) GMT"
                    
                    // see if a user is logged in
                    if let user = request.session?.userid, !user.isEmpty {
                        thecode.deletedby = user
                    } else {
                        thecode.deletedby = CCXDefaultUserValues.user_server
                    }
                    
                    let _ = try? thecode.saveWithCustomType(schemaIn: schema,thecode.deletedby)
                    
                    // audit the delete
                    AuditFunctions().deleteCustomerCodeAuditRecord(thecode)
                    
                    AuditRecordActions.customerCodeDelete(schema: schema,
                                                          session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                          row_data: ["deleted_code": thecode.asDictionary()],
                                                          changed_fields: nil,
                                                          description: nil,
                                                          changedby: request.session?.token ?? "NO SESSION USER")
                    
                    // all OK - returned at the bottom
                    _=try? response.setBody(json: ["result":"Successfully deleted the transaction."])
                    response.completed(status: .ok)
                    
                } else {
                    
                    // We did not... if it is in the history table, then it is already redeemed...
                    let theCode = CodeTransactionHistory()
                    let sql = "SELECT * FROM \(schema).code_transaction_history WHERE customer_code = '\(code)'"
                    let cde = try? theCode.sqlRows(sql, params: [])
                    if cde.isNotNil, let c = cde!.first {
                        theCode.to(c)
                    }

                    if theCode.id.isNotNil {
                        
                        let responseD:[String:Any] = ["errorCode":"CodeRedeemed","message":"The code was redeemed already.  Please Contact Bucket Support."]
                        var audit:[String:Any] = responseD
                        audit["code"]    = theCode.customer_code
                        audit["code_id"] = theCode.id
                        
                        AuditRecordActions.customerCodeDelete(schema: schema,
                                                              session_id: request.session?.token ?? "NO SESSION TOKEN",
                                                              row_data: audit,
                                                              changed_fields: nil,
                                                              description: nil,
                                                              changedby: request.session?.token ?? "NO SESSION USER")

                        
                        let _ = try? response.setBody(json: responseD)
                        response.completed(status: .custom(code: 452, message: "Code Redeemed Already"))
                        return
                    }
                    
                    response.invalidCustomerCode
                    return
                }
                
            }
        }
        

        //MARK: - Delete Terminal
        static func terminalDelete(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
                guard request.SecurityCheck() else { return response.badSecurityToken }
                
                // Verify Retailer
                Retailer.retailerBounce(request, response)
                
            }
        }

    }
}

fileprivate extension HTTPResponse {
    var invalidRetailer : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRetailer", "message":"Please Check Retailer Id"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .unauthorized)
    }
    var unauthorizedTerminal : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRetailer", "message":"Please Check Retailer Id and Secret Code."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .unauthorized)
    }
    var terminalNotApproved : Void {
        return try! self
            .setBody(json: ["errorCode":"TerminalNotApproved", "message":"Please login the website and approve the terminal."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .unauthorized)
    }
    var incorrectRetailer : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidRetailer", "message":"You cannot delete another retailer's transaction."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 453, message: "Retailer Conflict"))
    }
    var noTerminalId : Void {
        return try! self
            .setBody(json: ["errorCode":"NoTerminalId", "message":"You must send in a 'terminalId' key with the serial number of the device as the value."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .forbidden)
    }
    var invalidTerminalId : Void {
        return try! self
            .setBody(json: ["errorCode":"InvalidTerminalId", "message":"The terminalId you sent does not exist."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .forbidden)
    }
    var dateIssue : Void {
        return try! self
            .setBody(json: ["errorCode":"DateIssue", "message":"Start date must be less than end date."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 420, message: "Date Request Issue"))
    }
    func emptyReport(start : Any, end: Any) -> Void {
        return try! self
            .setBody(json: ["errorCode":"EmptyReport", "message":"Empty report between \(start) and \(end)"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 418, message: "Empty Report"))
    }
    var noLocationTerminal : Void {
        return try! self
            .setBody(json: ["errorCode":"NoTerminalLocation", "message":"You must set the location for the terminal before using the terminal.  Set the location on your retailer portal."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 460, message: "No Terminal Location"))
    }
    var serverEnvironmentError : Void {
        return try! self
            .setBody(json: ["errorCode":"ServerEnvironmentError", "message":"There is a current configuration issue with the system.  Please Contact Bucket's Tech Team."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .internalServerError)
    }
    var invalidCustomerCode : Void {
        let _ = try? self.setBody(json: ["errorCode":"InvalidCode", "message":"Please check your customer code."])
        return self.completed(status: .custom(code: 450, message: "Code Not On Record For UnRedeemed"))
    }
    func alreadyRegistered(_ serialNumber: String) -> Void {
        return try! self
            .setBody(json: ["errorCode":"AlreadyRegistered", "message":"The terminal with the serial number (\(serialNumber)) is registered to another retailer.  Contact Bucket support."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 410, message: "Terminal Registered"))
    }
    
    func returnReport(_ bucketTotal: Double, transactions: [[String:Any]]) -> Void {
        return try! self
            .setBody(json: ["bucketTotal":bucketTotal, "transactions":transactions])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .ok)
    }
    
    var eventDNE : Void {
        return try! self
            .setBody(json: ["errorCode":"EventIdDNE", "message":"The event ID does not exist."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 404, message: "Event Does Not Exist"))
    }
    
    func dateParseIssue(start: String, end: String) -> Void {
        return try! self
            .setBody(json: ["errorCode":"DateParseIssue", "message":"We are having problems parsing \(start) and \(end).  Please make sure it is following the date format of: 'yyyy-MM-dd HH:mm:ssZZZ'."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 420, message: "Date Request Issue"))
    }
    
    var eventDatesRequired : Void {
        return try! self
            .setBody(json: ["errorCode":"EventDatesRequired", "message":"Please include a 'start' and 'end' key for the dates of the event.  Please use date format 'yyyy-MM-dd HH:mm:ssZZZ'.'"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 420, message: "Date Request Issue"))
    }
    
    func createdEvent(_ id : Int) -> Void {
        return try! self
            .setBody(json: ["id":id, "result":"You successfully created the event."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .created)
    }
    
    func updatedEvent(_ id : Int) -> Void {
        return try! self
            .setBody(json: ["id":id, "result":"You successfully updated the event."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .ok)
    }
    
    var cannotDeleteEvent : Void {
        return try! self
            .setBody(json: ["errorCode":"EventHasTransactions", "message":"You can only delete an event if it has no associated transactions."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 421, message: "Can't Delete"))
    }
    
    var eventDeleted : Void {
        return try! self
            .setBody(json: ["result":"You successfully deleted the event!"])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .ok)
    }
    
    func returnEvents(_ eventsArray : [[String:Any]]) -> Void {
        return try! self
            .setBody(json: ["events":eventsArray])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .ok)
    }
    var noEvents : Void {
        return try! self
            .setBody(json: ["errorCode":"NoEvents", "message":"There were no events found with the given information."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 430, message: "No Events Found"))
    }
    
    var eventClosed : Void {
        return try! self
            .setBody(json: ["errorCode":"EventClosed", "message":"You cannot add a transaction to an event that is not in session."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 424, message: "Event Closed"))
    }
}

fileprivate extension HTTPRequest {
    
//    @available(*, deprecated, message: "no longer available in version v1.1")
//    var retailerId : String? {
//        return self.header(.custom(name: "retailerId")) ?? self.urlVariables["retailerId"]
//    }
    var intervalId : String? {
        return self.urlVariables["intervalId"]
    }
    var customerCode : String? {
        return self.urlVariables["customerCode"]
    }
    var retailerSecret : String? {
        return self.header(.custom(name: "x-functions-key"))
    }
    var terminalId : String? {
        if let terminalIdFromHeader = self.header(.custom(name: "terminalId")).stringValue {
            return terminalIdFromHeader
        }
        let theTry = try? self.postBodyJSON()?["terminalId"].stringValue
        if theTry.isNil {
            return nil
        } else {
            return theTry!
        }
    }
    
    var offsetLimit : (offset : Int, limit: Int)? {
        
        let foundOffsetStr = self.queryParams.first { $0.0 == "offset" }?.1
        let foundLimitStr = self.queryParams.first { $0.0 == "limit" }?.1
        
        
        if let fO = foundOffsetStr, let fL = foundLimitStr {
            if let ffO = Int(fO), let ffL = Int(fL) {
                return (offset: ffO, limit: ffL)
            }
        }
        
        return nil
    }
    
    var epochDates : (start: Int, end: Int)? {
        
        if let postJSON = try? self.postBodyJSON() {
            if let start = postJSON?["start"].stringValue, let end = postJSON?["end"].stringValue, let startEpochInt = moment(start, dateFormat: "yyyy-MM-dd HH:mm:ssZZZ", timeZone: .utc)?.epoch(), let endEpochInt = moment(end, dateFormat: "yyyy-MM-dd HH:mm:ssZZZ", timeZone: .utc)?.epoch() {
                return (Int(startEpochInt), Int(endEpochInt))
            } else if let start = postJSON?["start"].intValue, let end = postJSON?["end"].intValue {
                return (start, end)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    var eventId : Int? {
        if let eventId = self.header(.custom(name: "eventId"))?.intValue {
            return eventId
        } else {
            return nil
        }
    }
    
    var employeeId : String? {
        if let employeeIdFromHeader = self.header(.custom(name: "employeeId")).stringValue {
            return employeeIdFromHeader
        }
        let theTry = try? self.postBodyJSON()?["employeeId"].stringValue
        if theTry.isNil {
            return nil
        } else {
            return theTry!
        }
    }

    var retailer : Retailer? {
        guard let retailerId = retailerId, let countryId = countryId else { return nil }
        let schema = Country.getSchema(countryId)
        let retailer = Retailer()
        let sql = "SELECT * FROM \(schema).retailer WHERE id = \(retailerId)"
        if let res = try? retailer.sqlRows(sql, params: []), let row = res.first {
            retailer.to(row)
            return retailer
        } else {
            return nil
        }
    }
    var terminal : Terminal? {
        // Lets see if we have a terminal from the input data:
        // They need to input the x-functions-key as their retailer password.
        guard let password = self.retailerSecret, let terminalId = self.terminalId, let countryId = self.countryId else { return nil }
        
        let schema = Country.getSchema(countryId)
        
        let term = Terminal()
        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(terminalId)' AND terminal_key = '\(password.ourPasswordHash!)' "
        let trm = try? term.sqlRows(sql, params: [])
        if trm.isNotNil, let t = trm?.first {
            term.to(t)
        }

        if term.id.isNotNil { return term }
            
        else { return nil }
    }
    
}


extension Retailer {

    public static func exists(_ with: String, _ countryId: String) -> Bool {
        
        let schema = Country.getSchema(countryId)
        if schema.isEmpty { return false }
        
        // Find the terminal
        let retailer = Retailer()
        let sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(with.lowercased())'"
        let rtlr = try? retailer.sqlRows(sql, params: [])
        if rtlr.isNotNil, let t = rtlr?.first {
            retailer.to(t)
        }

        return retailer.id.isNotNil
        
    }
    
    @discardableResult
    public static func retailerBounce(_ request: HTTPRequest, _ response: HTTPResponse) -> Int? {
        
        // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
        guard request.SecurityCheck() else { response.badSecurityToken; return nil }

        //Make sure we have the retailer Id and retailer secret:
        guard let retailerId = request.retailerId else { response.invalidRetailer; return nil }
        guard let countryId = request.countryId else {  response.invalidCountryCode; return nil }
        
        let schema = Country.getSchema(countryId)
        if schema.isEmpty { response.invalidCountryCode; return nil }

        // Find the terminal
        let retailer = Retailer()
        let sql = "SELECT * FROM \(schema).retailer WHERE retailer_code = '\(retailerId)'"
        let rtlr = try? retailer.sqlRows(sql, params: [])
        if rtlr.isNotNil, let t = rtlr?.first {
            retailer.to(t)
        }

        // this is where we will check the temrminal ID, retailer and the secret to make sure the terminal is approved.
        
        if retailer.id.isNil { response.invalidRetailer; return nil }
        
        return retailer.id
        
    }

    public static func retailerTerminalBounce(_ request: HTTPRequest, _ response: HTTPResponse) -> (bounced:Bool?, terminal:Terminal?, retailer:Retailer?)? {
        
        // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
        guard request.SecurityCheck() else { response.badSecurityToken; return (true, nil, nil) }

        //Make sure we have the retailer Id and retailer secret:
//        guard let retailerSecret = request.retailerSecret, let retailerId = request.retailerId else { response.unauthorizedTerminal; return true }
        guard let retailerSecret = request.retailerSecret else { response.unauthorizedTerminal; return (true, nil, nil) }

        guard let terminalSerialNumber = request.terminalId else { response.noTerminalId; return (true, nil, nil) }
        guard let _ = request.countryId else { response.invalidCountryCode; return (true, nil, nil) }
        
        // lets test for the retailer code (not the retailer ID
        let schema = Country.getSchema(request)
        
        var retailerId = 0
        
        if let retcode = request.getRetailerCode() {
            let sql = "SELECT id FROM \(schema).retailer WHERE retailer_code = '\(retcode.lowercased())'"
            let r = Retailer()
            let r_ret = try? r.sqlRows(sql, params: [])
            if r_ret.isNil, r_ret!.count == 0 {
                // the code was not found
                response.invalidRetailer
                return (true, nil, nil)
            } else {
                // set the retailer id
                retailerId = r_ret!.first!.data["id"].intValue!
            }
        } else {
            // the retailer code was not sent in
            response.invalidRetailer
            return (true, nil, nil)
        }

        // Get our secret code formatted properly to check what we have in the DB:
        let passwordToCheck = retailerSecret.ourPasswordHash!
        
        let terminalQuery = Terminal()
        let sql = "SELECT * FROM \(schema).terminal WHERE serial_number = '\(terminalSerialNumber)' AND terminal_key = '\(passwordToCheck)' "
        let term = try? terminalQuery.sqlRows(sql, params: [])
        if term.isNotNil, let t = term?.first {
            terminalQuery.to(t)
        }
        
        // Checking three conditions:
        //  1. The terminal is not registered
        //  2. The terminal is not active
        //  3. The terminal is not for this retailer
        //  4. The terminal is not assigned to an address
        
        // this means the terminal number is invalid - RETURN the appropriate error code
        if terminalQuery.id.isNil { response.unauthorizedTerminal; return (true, nil, nil) }
        
        // this means the terminal is not approved
        if !terminalQuery.is_approved { response.unauthorizedTerminal; return (true, nil, nil) }
        
        // and finally - make sure there is an address assigned to this terminal
        if terminalQuery.address_id.isNil || terminalQuery.address_id == 0 { response.noLocationTerminal; return (true, nil, nil) }

        // Checking the final condition (last condition to minimize the number of queries during error)
        let retailerQuery = Retailer()
        let sqlr = "SELECT * FROM \(schema).retailer WHERE id = '\(retailerId)'"
        let rtl = try? retailerQuery.sqlRows(sqlr, params: [])
        if rtl.isNotNil, let t = rtl?.first {
            retailerQuery.to(t)
        }

        // now lets look to make sure the serial number is to the current retailer
        if retailerQuery.id != terminalQuery.retailer_id { response.alreadyRegistered(terminalSerialNumber); return (true, nil, nil) }
        
        return (false, terminalQuery, retailerQuery)
    }

}
