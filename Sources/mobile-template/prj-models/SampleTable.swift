import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession

class SampleTable: PostgresStORM {
    //MARK: - Inherited fields:
    var id         : Int?
    var created    : Int?
    var createdby  : String?
    var modified   : Int?
    var modifiedby : String?
    
    //MARK: - Fields
    var geopoint : CCXGeographyPoint? = nil
    var geopointtime : Int? = nil

    //MARK: Table name
    override public func table() -> String { return "sampletable" }
    
    //MARK: Init Functions
    
    //MARK -
    //MARK: initializers
    override init() {
        super.init()
    }
    
    init(_ stormrow: StORMRow) {
        
        // common fields
        if let data = stormrow.data["id"].intValue {
            self.id = data
        }
        
        if let data = stormrow.data["created"].intValue {
            self.created = data
        }
        
        if let data = stormrow.data["modified"].intValue {
            self.modified = data
        }
        
        if let data = stormrow.data["createdby"].stringValue, !data.isEmpty {
            self.createdby = data
        }
        
        if let data = stormrow.data["modifiedby"].stringValue, !data.isEmpty {
            self.modifiedby = data
        }

        if let data = stormrow.data.geopointtime.intValue {
            geopointtime = data
        }
        
        if let long = stormrow.data.longitude, let lat = stormrow.data.latitude {
            if geopoint.isNil {
                geopoint = CCXGeographyPoint()
            }
            geopoint?.longitude = long
            geopoint?.latitude = lat
        }

    }
    
    
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
        
        
    }
    
    func rows() -> [SampleTable] {
        var rows = [SampleTable]()
        for i in 0..<self.results.rows.count {
            let row = SampleTable()
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


