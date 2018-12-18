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

public class Badge: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id                  : Int?    = nil
    var created             : Int?    = nil
    var createdby           : String? = nil
    var modified            : Int?    = nil
    var modifiedby          : String? = nil
    
    var pictureurl          : String? = nil
    var name                : String? = nil

    // badge definitions:
    //    number required  = a specific number of times an event occurs is required
    //    date_expired     = when the badge events need to occur
    //    seconds_required = time required to complete badge requirememnts
    var number_required     : Int?    = nil
    var date_expired        : Int?    = nil
    var seconds_required    : Int?    = nil

    //MARK: Table name
    override public func table() -> String { return "badges" }
    
    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        if let data = this.data.badge.id.intValue {
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
        
        if let data = this.data.badge.name.stringValue {
            name = data
        }
        
        if let data = this.data.badge.picture_url {
            pictureurl = data
        }
        
    }
    
    func rows() -> [Badge] {
        var rows = [Badge]()
        for i in 0..<self.results.rows.count {
            let row = Badge()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.id.isNotNil {
            dictionary.badge.id = self.id
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
        
        if self.pictureurl.isNotNil {
            dictionary.badge.picture_url = self.pictureurl
        }
        
        if self.name.isNotNil {
            dictionary.badge.name = self.name
        }

        if self.date_expired.isNotNil {
            dictionary.badge.date_expired = self.date_expired
        }

        if self.number_required.isNotNil {
            dictionary.badge.number_required = self.number_required
        }

        if self.seconds_required.isNotNil {
            dictionary.badge.seconds_required = self.seconds_required
        }

        return dictionary
    }
}

