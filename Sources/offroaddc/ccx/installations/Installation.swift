//
//  Installation.swift
//  findapride
//
//  Created by Mike Silvers on 7/2/17.
//
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Installation: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id                  : Int?    = nil
    var created             : Int?    = nil
    var createdby           : String? = nil
    var modified            : Int?    = nil
    var modifiedby          : String? = nil
    
    var user_id             : String? = nil
    
    var devicetoken         : String? = nil
    var devicetype          : String? = nil
    var name                : String? = nil
    var systemname          : String? = nil
    var systemversion       : String? = nil
    var model               : String? = nil
    var localizedmodel      : String? = nil
    var identifierforvendor : String? = nil
    var timezone            : String? = nil
    
    var acceptedterms       : Int?    = nil
    var declinedterms       : Int?    = nil
    
    //MARK: Table name
    override public func table() -> String { return "installations" }
    
    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        if let data = this.data.installations.id.intValue {
            id = data
        }
        
        if let data = this.data.created.intValue {
            created = data
        }
        
        if let data = this.data.modified.intValue {
            modified = data
        }
        
        if let data = this.data.createdBy {
            createdby = data
        }
        
        if let data = this.data.modifiedBy {
            modifiedby = data
        }
        
        if let data = this.data["user_id"].stringValue {
            user_id = data
        }
        
        if let data = this.data.installations.devicetype {
            devicetype = data
        }
        
        if let data = this.data.installations.name {
            name = data
        }
        
        if let data = this.data.installations.systemname {
            systemname = data
        }
        
        if let data = this.data.installations.systemversion {
            systemversion = data
        }
        
        if let data = this.data.installations.model {
            model = data
        }
        
        if let data = this.data.installations.localizedmodel {
            localizedmodel = data
        }
        
        if let data = this.data.installations.identifierforvendor {
            identifierforvendor = data
        }
        
        if let data = this.data.installations.devicetoken {
            devicetoken = data
        }
        
        if let data = this.data.installations.timezone {
            timezone = data
        }
        
        if let data = this.data.installations.timezone {
            timezone = data
        }
        
        if let data = this.data.installations.acceptedterms {
            acceptedterms = data
        }
        
        if let data = this.data.installations.declinedterms {
            declinedterms = data
        }
        
    }
    
    func rows() -> [Installation] {
        var rows = [Installation]()
        for i in 0..<self.results.rows.count {
            let row = Installation()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.id.isNotNil {
            dictionary.installations.id = self.id
        }
        
        if self.created.isNotNil {
            dictionary.created = self.created
        }
        
        if self.createdby.isNotNil {
            dictionary.createdBy = self.createdby
        }
        
        if self.modified.isNotNil {
            dictionary.modified = self.modified
        }
        
        if self.modifiedby.isNotNil {
            dictionary.modifiedBy = self.modifiedby
        }
        
        if self.user_id.isNotNil {
            dictionary["user_id"] = self.user_id
        }
        
        if self.devicetype.isNotNil {
            dictionary.installations.devicetype = self.devicetype
        }
        
        if self.name.isNotNil {
            dictionary.installations.name = self.name
        }
        
        if self.systemversion.isNotNil {
            dictionary.installations.systemversion = self.systemversion
        }
        
        if self.model.isNotNil {
            dictionary.installations.model = self.model
        }
        
        if self.localizedmodel.isNotNil {
            dictionary.installations.localizedmodel = self.localizedmodel
        }
        
        if self.identifierforvendor.isNotNil {
            dictionary.installations.identifierforvendor  = self.identifierforvendor
        }
        
        if self.devicetoken.isNotNil {
            dictionary.installations.devicetoken = self.devicetoken
        }
        
        if self.timezone.isNotNil {
            dictionary.installations.timezone = self.timezone
        }
        
        if self.acceptedterms.isNotNil {
            dictionary.installations.acceptedterms = self.acceptedterms
        }
        
        if self.declinedterms.isNotNil {
            dictionary.installations.declinedterms = self.declinedterms
        }
        
        return dictionary
    }
}

