//
//  Breadcrumb.swift
//  findapride
//
//  Created by Mike Silvers on 7/2/17.
//
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Notification: PostgresStORM {

    // NOTE: First param in class should be the ID.
    var id                  : Int?    = nil
    var created             : Int?    = nil
    var createdby           : String? = nil
    var modified            : Int?    = nil
    var modifiedby          : String? = nil

    var user_id             : String? = nil

    var devicetoken         : String? = nil
    var devicetype          : String? = nil
    var timezone            : String? = nil

    //MARK: Table name
    override public func table() -> String { return "notification" }

    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        if let data = this.data.notifications.id.intValue {
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

        if let data = this.data.notifications.devicetype {
            devicetype = data
        }
        
        if let data = this.data.notifications.devicetoken {
            devicetoken = data
        }

        if let data = this.data.notifications.timezone {
            timezone = data
        }

    }

    func rows() -> [Notification] {
        var rows = [Notification]()
        for i in 0..<self.results.rows.count {
            let row = Notification()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }

    func asDictionary() -> [String: Any] {

        var dictionary:[String:Any] = [:]
        
        if self.id.isNotNil {
            dictionary.notifications.id = self.id
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
            dictionary.notifications.devicetype = self.devicetype
        }
        
        if self.devicetoken.isNotNil {
            dictionary.notifications.devicetoken = self.devicetoken
        }

        if self.timezone.isNotNil {
            dictionary.notifications.timezone = self.timezone
        }

        return dictionary
    }


}
