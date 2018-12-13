//
//  UserLocation.swift
//
//  Created by Ryan Coyne on 10/31/17.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLocalAuthentication

class UserLocation: PostgresStORM {
    
    //MARK: - Inherited fields:
    var id : Int? = nil
    var created : Int? = nil
    var createdby : String? = nil
    var modified : Int? = nil
    var modifiedby : String? = nil
    
    var geopoint : RMGeographyPoint? = nil
    var geopointtime : Int? = nil
    var user_id : String? = nil
    
    override func table() -> String { return "userlocation" }
    
    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        if let data = this.data.id {
            id = data
        }
        
        if let data = this.data.created.intValue {
            created = data
        }
        
        if let data = this.data.modified.intValue {
            modified = data
        }
        
        if let data = this.data.createdBy {
            createdby           = data
        }
        
        if let data = this.data.modifiedBy {
            modifiedby          = data
        }
        
        if let data = this.data.geopointtime.intValue {
            geopointtime = data
        }
        
        if let long = this.data.longitude, let lat = this.data.latitude {
            if geopoint.isNil {
                geopoint = RMGeographyPoint()
            }
            geopoint?.longitude = long
            geopoint?.latitude = lat
        }
        
    }
    
    func rows() -> [UserLocation] {
        var rows = [UserLocation]()
        for i in 0..<self.results.rows.count {
            let row = UserLocation()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
    
        if self.id.isNotNil {
            dictionary.id = self.id
        }
        // audit fields
        if self.created.isNotNil {
            dictionary.created = self.created
        }
        if self.createdby.isNotNil {
            dictionary.createdBy = self.createdby
        }
        
        if self.modified.isNotNil {
            dictionary.modified   = self.modified
        }
        if self.modifiedby.isNotNil {
            dictionary.modifiedBy = self.modifiedby
        }
        
        if self.geopoint.isNotNil {
            dictionary.geopoint.latitude = self.geopoint?.latitude
            dictionary.geopoint.longitude = self.geopoint?.longitude
        }
        
        if self.geopointtime.isNotNil {
            dictionary.geopointtime = self.geopointtime
        }
        
        return dictionary
    }
    
}
