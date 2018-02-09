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

public class BadgeUser: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id                  : Int?    = nil
    var created             : Int?    = nil
    var createdby           : String? = nil
    var modified            : Int?    = nil
    var modifiedby          : String? = nil
    
    var user_id             : String? = nil
    var badge_received      : Int? = nil
    var badge_id            : Int? = nil

    //MARK: Table name
    override public func table() -> String { return "badgeusers" }
    
    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        if let data = this.data.badgeuser.id.intValue {
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
        
        if let data = this.data.badgeuser.user_id.stringValue {
            user_id = data
        }
        
        if let data = this.data.badgeuser.badge_received.intValue {
            badge_received = data
        }

        if let data = this.data.badgeuser.badge_id.intValue {
            badge_id = data
        }

    }
    
    func rows() -> [BadgeUser] {
        var rows = [BadgeUser]()
        for i in 0..<self.results.rows.count {
            let row = BadgeUser()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.id.isNotNil {
            dictionary.badgeuser.id = self.id
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
            dictionary.badgeuser.user_id = self.user_id
        }
        
        if self.badge_received.isNotNil {
            dictionary.badgeuser.badge_received = self.badge_received
        }

        if self.badge_id.isNotNil {
            dictionary.badgeuser.badge_id = self.badge_id
        }

        return dictionary
    }
}

