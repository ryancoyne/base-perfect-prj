//
//  AuditRecordActions.swift
//  bucket
//
//  Created by Mike Silvers on 9/29/18.
//

import Foundation

final class AuditRecordActions {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
        
    }
    
    static let sharedInstance = AuditRecordActions()

    //MARK:-
    //MARK: Add a generic audit record
    static func addGenericrecord(schema:String? = nil,
                                 audit_group: String,
                                 audit_action: String,
                                 row_data: [String:Any]? = nil,
                                 changed_fields: [String:Any]? = nil,
                                 description: String? = nil,
                                 user: String? = nil) {
        
        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }

        // save using the private function
        self.addAuditRecord(audit_group: audit_group,
                            audit_action: audit_action,
                            row_data: row_data,
                            changed_fields: changed_fields,
                            description: description,
                            user: user)
    }
    
    //MARK: --
    //MARK: User Functions
    static func userAdd(schema: String? = nil,
                        user:String? = nil,
                        row_data:[String:Any]? = nil,
                        changed_fields:[String:Any]? = nil,
                        description:String? = nil,
                        changedby: String? = nil) {
        
        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }

        if user.isNotNil {
            rd["user"] = user!
        }

        self.addAuditRecord(audit_group: "USER",
                            audit_action: "ADD",
                            row_data: rd,
                            changed_fields: changed_fields,
                            description: description,
                            user: changedby)
    }
    
    static func userChange(schema: String? = nil,
                           user:String,
                           row_data:[String:Any]? = nil,
                           changed_fields:[String:Any]? = nil,
                           description:String? = nil,
                           changedby: String? = nil) {
    
        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }

        rd["user"] = user

        self.addAuditRecord(audit_group: "USER",
                            audit_action: "UPDATE",
                            row_data: rd,
                            changed_fields: changed_fields,
                            description: description,
                            user: changedby)
    }

    static func userDelete(schema: String? = nil,
                           user:String,
                           row_data:[String:Any]? = nil,
                           changed_fields:[String:Any]? = nil,
                           description:String? = nil,
                           changedby: String? = nil) {
        
        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }

        rd["user"] = user

        self.addAuditRecord(audit_group: "USER",
                            audit_action: "DELETE",
                            row_data: rd,
                            changed_fields: changed_fields,
                            description: description,
                            user: changedby)
    }

    //MARK: --
    //MARK: Customer Code functions
    static func customerCodeAdd(schema: String? = nil,
                                row_data:[String:Any]? = nil,
                                changed_fields:[String:Any]? = nil,
                                description:String? = nil,
                                changedby:String? = nil) {

        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }

        self.addAuditRecord(audit_group: "CODE",
                            audit_action: "ADD",
                            row_data: rd,
                            changed_fields: changed_fields,
                            description: description,
                            user: changedby)
    }
    
    static func customerCodeChange(schema: String? = nil,
                                   row_data:[String:Any]? = nil,
                                   changed_fields:[String:Any]? = nil,
                                   description:String? = nil,
                                   changedby:String? = nil) {

        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }

        self.addAuditRecord(audit_group: "CODE",
                            audit_action: "UPDATE",
                            row_data: rd,
                            changed_fields: changed_fields,
                            description: description,
                            user: changedby)
    }

    static func customerCodeRedeemed(schema: String? = nil,
                                     redeemedby: String,
                                     row_data:[String:Any]? = nil,
                                     changed_fields:[String:Any]? = nil,
                                     description:String? = nil,
                                     changedby:String? = nil) {
        
        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }

        rd["user"] = redeemedby
        
        self.addAuditRecord(audit_group: "CODE",
                            audit_action: "REDEEMED",
                            row_data: rd,
                            changed_fields: changed_fields,
                            description: description,
                            user: changedby)
    }

    static func customerCodeDelete(schema: String? = nil,
                                   row_data:[String:Any]? = nil,
                                   changed_fields:[String:Any]? = nil,
                                   description:String? = nil,
                                   changedby:String? = nil) {

        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }

        self.addAuditRecord(audit_group: "CODE",
                            audit_action: "DELETE",
                            row_data: rd,
                            changed_fields: changed_fields,
                            description: description,
                            user: changedby)
    }

    
    //MARK: --
    //MARK: Cashout
    static func cashOut(schema: String? = nil,
                        total_cashout_amount: Double,
                        code_and_amount: [String:Double],
                        row_data:[String:Any]? = nil,
                        changed_fields:[String:Any]? = nil,
                        description:String? = nil,
                        changedby:String? = nil) {
        
        // make sure the schema has been added to the row data
        var rd:[String:Any] = row_data ?? [:]
        if schema.isNil {
            rd["schema"] = "public"
        } else if schema!.isEmpty {
            rd["schema"] = "public"
        } else {
            rd["schema"] = schema
        }
        
        rd["cashout_total"]      = total_cashout_amount
        
        // loop thru the codes and amounts
        var codes:[String:Double] = [:]
        for (key, val) in code_and_amount {
            codes[key] = (val as Double)
        }
        
        if codes.count > 0 {
            rd["customer_codes"] = codes
        }
        
        self.addAuditRecord(audit_group: "CODE",
                            audit_action: "DELETE",
                            row_data: rd,
                            changed_fields: changed_fields,
                            description: description,
                            user: changedby)
    }

    
    //MARK: --
    //MARK: Private Functions
    private static func addAuditRecord(audit_group: String,
                                       audit_action: String,
                                       row_data: [String:Any]? = nil,
                                       changed_fields: [String:Any]? = nil,
                                       description: String? = nil,
                                       user: String? = nil) {

        // save the record
        let tbl = AuditRecord()
        
        tbl.audit_group = audit_group
        tbl.audit_action = audit_action
        tbl.description = description
        tbl.row_data = row_data
        tbl.changed_fields = changed_fields
        
        _ = try? tbl.saveWithCustomType(schemaIn: tbl.schema(), user, false)

    }
}
