//
//  AdminAPI.swift
//  bucket
//
//  Created by Mike Silvers on 8/29/18.
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

//MARK: - Admin API
/// This Admin structure supports all the normal endpoints for a user based login application.
struct AdminAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
//                ["method":"post",    "uri":"/api/v1/admin/userStats", "handler":userStats],
                ["method":"post",    "uri":"/api/v1/admin/suttonBatchAll", "handler":processSuttonBatchAll],
                
                // Cashout Group Management (Admin Only)
                // Create & Update:
                ["method":"post",    "uri":"/api/v1/update/cashout/groups", "handler":createOrUpdateCashoutGroup],
                // Delete:
                ["method":"delete",    "uri":"/api/v1/cashout/groups/{groupId}", "handler":deleteGroup],
            ]
        }
        
        //MARK: - Cashout Group Create or Update
        public static func createOrUpdateCashoutGroup(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                let bounce = Account.adminBouce(request, response)
                guard !bounce.fails else { return response.accountPermissionsBounce }
                guard let countryId = request.countryId else { return response.invalidCountryCode }
                
                let schema = Country.getSchema(request)
                
                // We wont be doing JSON here since we have files to upload for the images:
                
                if let id = request.param(name: "id", defaultValue: nil) {
                    
                    // We are UPDATING a new group:
                    let group = CashoutGroup()
                    _ = try? group.get(id, schema: schema)
                    
                    group.country_id = countryId
                    if let value = request.param(name: "name", defaultValue: nil) {
                        group.group_name = value
                    }
                    if let value = request.param(name: "description", defaultValue: nil) {
                        group.description = value
                    }
                    if let value = request.param(name: "longDescription", defaultValue: nil) {
                        group.long_description = value
                    }
                    if let value = request.param(name: "optionLayout", defaultValue: nil) {
                        group.option_layout = value
                    }
                    if let value = request.param(name: "display", defaultValue: nil).boolValue {
                        group.display = value
                    }
                    if let value = request.param(name: "thresholdAmount", defaultValue: nil).doubleValue {
                        group.threshold_amount = value
                    }
                    if let value = request.param(name: "displayOrder", defaultValue: nil).intValue {
                        group.display_order = value
                    }
                    
                    _ = try? group.saveWithCustomType(schemaIn: schema, bounce.user?.id)
                    
                } else {
                    // Okay, we are CREATING:
                    let group = CashoutGroup()
                    
                    // First lets make sure they have the images we need:
                    guard let pictureFiles = request.uploadedFiles else { return response.pictureFilesRequired }
                    
                    for pictureFile in pictureFiles {
                        //  Here we are assuming that this is the 1x image.  We need to create and save the 1x, 1.5x, 2x, 2.5x, 3x, 3.5x, 4x.
                        // We also need to get an icon, and a background:
                        switch pictureFile.fieldName {
                        case "icon":
                            break
                        case "background":
                            break
                        default: break
                        }
                    }
                    
                    if let value = request.param(name: "name", defaultValue: nil) {
                        group.group_name = value
                    }
                    if let value = request.param(name: "description", defaultValue: nil) {
                        group.description = value
                    }
                    if let value = request.param(name: "longDescription", defaultValue: nil) {
                        group.long_description = value
                    }
                    if let value = request.param(name: "optionLayout", defaultValue: nil) {
                        group.option_layout = value
                    }
                    if let value = request.param(name: "display", defaultValue: nil).boolValue {
                        group.display = value
                    }
                    if let value = request.param(name: "thresholdAmount", defaultValue: nil).doubleValue {
                        group.threshold_amount = value
                    }
                    if let value = request.param(name: "displayOrder", defaultValue: nil).intValue {
                        group.display_order = value
                    }
                    
                }
                
                do {
                    
                    let json = try request.postBodyJSON()!
                    guard !json.isEmpty else { return response.emptyJSONBody }
                    
                    // Okay.. lets see if we are updating or creating:
                    if json.id.isNil {
                        
                        
                        // Okay. We need to have images for the cashout groups:
                        
                        
                        // Okay lets save this new group:
                        
                        
                    } else {
                        
                        
                        
                        
                    }
                    
                } catch BucketAPIError.unparceableJSON(let theStr) {
                    return response.invalidRequest(theStr)
                } catch {
                    return response.caughtError(error)
                }
                
            }
        }
        
        public static func deleteGroup(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                let bounce = Account.adminBouce(request, response)
                guard !bounce.fails else { return response.accountPermissionsBounce }
                
                // Make sure we have the correct schema:
                let schema = Country.getSchema(request)
                guard schema != "public" else { return response.invalidCountryCode }
                
                let groupId = request.groupId
                
                let theGroup = CashoutGroup()
                try? theGroup.get(groupId, schema: schema)
                
                if theGroup.id.isNil {
                    return response.groupDNE
                } else {
                    if theGroup.deleted ?? 0 > 0 { return response.alreadyDeleted }
                    _=try? theGroup.softDeleteWithCustomType(schemaIn: schema, bounce.user?.id)
                    return response.deletedGroup(theGroup.id!)
                }
            
            }
        }
        
        //MARK: - User Stats Function
        public static func userStats(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                let bounce = Account.adminBouce(request, response)
                guard !bounce.fails else { return response.accountPermissionsBounce }
                
                let user = Account()
                let _ = try? user.get((request.session!.userid as String))
                
                // now we can differentiate between user types (user.usertype)
                
                // Okay.. they are good to go.  Lets get the user stats
                
                // number of retailers
                
                // number of codes issued per retailer (red color indicates "stale" retailers)
                
                // number of accounts
                
                // number of "stale" accounts
                
                // number of unclaimed codes per country
                
                // number of claimed codes in the last 24 hours
                
                
                // and render the template (once we have the template complete)
                response.render(template: "views/forgotpassword")
                response.completed()
                return
            }
        }
        
        //MARK: - User Stats Function
        public static func processSuttonBatchAll(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
//                guard Account.adminBouce(request, response) else { response.accountPermissionsBounce; return  }
                
                // breate the batch
                SuttonFunctions.batchAll()
                
                // process the newly created batch
                let bp = BatchProcessing()
                bp.processSutton()
                
                // and render the template (once we have the template complete)
                response.render(template: "views/batch")
                response.completed()
                return
            }
        }
    }
}

fileprivate extension HTTPRequest {
    var groupId : Int {
        return self.urlVariables["groupId"].intValue ?? 0
    }
    var uploadedFiles : [MimeReader.BodySpec]? {
        return self.postFileUploads?.filter { $0.file.isNotNil }
    }
}

fileprivate extension HTTPResponse {
    var groupDNE : Void {
        return try! self.setBody(json: ["errorCode":"GroupDNE", "message": "The group id does not exist."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 404, message: "The Group Id does not exist."))
    }
    var alreadyDeleted : Void {
        return try! self.setBody(json: ["errorCode":"GroupAlreadyDeleted", "message": "The group has already been deleted."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 404, message: "The Group Id does not exist."))
    }
    var pictureFilesRequired : Void {
        return try! self.setBody(json: ["errorCode":"PictureFilesRequired", "message": "You must include picture files to create a new cashout group."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .custom(code: 400, message: "Picture Files Are Required"))
    }
    func deletedGroup(_ id: Int) -> Void {
        return try! self.setBody(json: ["message":"You successfully deleted group id: \(id)."])
            .setHeader(.contentType, value: "application/json; charset=UTF-8")
            .completed(status: .ok)
    }
}
