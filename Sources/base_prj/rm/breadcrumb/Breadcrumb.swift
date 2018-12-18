//
//  Breadcrumb.swift
//
//  Created by Ryan Coyne on 10/31/17.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLocalAuthentication

class Breadcrumb: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id                  : Int?    = nil
    var created             : Int?    = nil
    var createdby           : String? = nil
    var modified            : Int?    = nil
    var modifiedby          : String? = nil
    
    var altitude            : Double? = nil
    var bssid               : String? = nil
    var distancefromlast    : Double? = nil
    var horizontalaccuracy  : Double? = nil
    var user_id             : String? = nil
    var geopointtime        : Int?    = nil
    var ssid                : String? = nil
    var speed               : Double? = nil
    var verticalaccuracy    : Double? = nil
    var batterylevel        : Double? = nil
    var applicationstatus   : String? = nil
    
    var geopoint            : RMGeographyPoint = RMGeographyPoint()
    
    //MARK: Table name
    override public func table() -> String { return "breadcrumb" }
    
    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        id                  = this.data.id
        created             = this.data.created.intValue
        modified            = this.data.modified.intValue
        
        createdby       = this.data.createdBy
        
        modifiedby      = this.data.modifiedBy
        
        user_id             = this.data.user.id
        geopointtime        = this.data.breadcrumb.geopointtime.intValue
        ssid                = this.data.breadcrumb.ssid
        bssid               = this.data.breadcrumb.bssid
        speed               = this.data.breadcrumb.speed
        altitude            = this.data.breadcrumb.altitude
        horizontalaccuracy  = this.data.breadcrumb.horizontalAccuracy
        verticalaccuracy    = this.data.breadcrumb.verticalAccuracy
        distancefromlast    = this.data.breadcrumb.distanceFromLast
        applicationstatus   = this.data.breadcrumb.applicationstatus
        batterylevel        = this.data.breadcrumb.batterylevel
        
    }
    
    func rows() -> [Breadcrumb] {
        var rows = [Breadcrumb]()
        for i in 0..<self.results.rows.count {
            let row = Breadcrumb()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        dictionary.id = self.id
        dictionary.created = self.created
        dictionary.createdBy = self.createdby
        dictionary.modified = self.modified
        dictionary.modifiedBy = self.modifiedby
        dictionary.user.id = self.user_id
        dictionary.geopointtime = self.geopointtime
        dictionary.breadcrumb.ssid = self.ssid
        dictionary.breadcrumb.bssid = self.bssid
        dictionary.breadcrumb.speed = self.speed
        dictionary.breadcrumb.applicationstatus = self.applicationstatus
        dictionary.breadcrumb.batterylevel = self.batterylevel
        
        return dictionary
    }

}
