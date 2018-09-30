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
