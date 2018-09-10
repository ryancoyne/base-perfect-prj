//
//  Address.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Address: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var country_id     : Int? = nil
    var retailer_id     : Int? = nil
    var retailer_contact_id     : Int? = nil
    var postal_code     : String? = nil
    var state     : String? = nil
    var city : String? = nil
    var address1 : String? = nil
    var address2 : String? = nil
    var address3 : String? = nil
    var ach_transfer_minimum: Double? = nil
    
    var geopoint : CCXGeographyPoint? = nil

    //MARK: Table name
    override public func table() -> String { return "address" }
    
    //MARK: Functions to retrieve data and such
    override open func to(_ this: StORMRow) {
        
        if let data = this.data.id.intValue {
            id = data
        }
        
        if let data = this.data.created.intValue {
            created = data
        }
        
        if let data = this.data.modified.intValue {
            modified = data
        }
        
        if let data = this.data.deleted.intValue {
            deleted = data
        }
        
        if let data = this.data.createdBy {
            createdby = data
        }
        
        if let data = this.data.modifiedBy {
            modifiedby = data
        }
        
        if let data = this.data.deletedBy {
            deletedby = data
        }
        
        if let data = this.data.addressDic.countryId {
           country_id  = data
        }
        
        if let data = this.data.addressDic.retailerId {
            retailer_id = data
        }
        
        if let data = this.data.addressDic.retailerContactId {
            retailer_contact_id = data
        }
        
        if let data = this.data.addressDic.address1 {
            address1 = data
        }
        
        if let data = this.data.addressDic.address2 {
            address2 = data
        }
        
        if let data = this.data.addressDic.address3 {
            address3 = data
        }
        
        if let data = this.data.addressDic.city {
            city = data
        }
        
        if let data = this.data.addressDic.state {
            state = data
        }
        
        if let data = this.data.addressDic.postalCode {
            postal_code = data
        }
        
        if let data = this.data.addressDic.ach_transfer_minimum {
            ach_transfer_minimum = data
        }
        
        if let long = this.data.longitude, let lat = this.data.latitude {
            if geopoint.isNil {
                geopoint = CCXGeographyPoint()
            }
            geopoint?.longitude = long
            geopoint?.latitude = lat
        }

        
        
    }
    
    func rows() -> [Address] {
        var rows = [Address]()
        for i in 0..<self.results.rows.count {
            let row = Address()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        var lat = 0.0
        var lon = 0.0
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "country_id":
                if (value as? Int).isNotNil {
                    self.country_id = (value as! Int)
                }
                
            case "retailer_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "retailer_contact_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "address1":
                if (value as? String).isNotNil {
                    self.address1 = (value as! String)
                }
                
            case "address2":
                if (value as? String).isNotNil {
                    self.address2 = (value as! String)
                }
                
            case "address3":
                if (value as? String).isNotNil {
                    self.address3 = (value as! String)
                }
                
            case "postal_code":
                if (value as? String).isNotNil {
                    self.postal_code = (value as! String)
                }
                
            case "city":
                if (value as? String).isNotNil {
                    self.city = (value as! String)
                }
                
            case "state":
                if (value as? String).isNotNil {
                    self.state = (value as! String)
                }

            case "ach_transfer_minimum":
                if (value as? Double).isNotNil {
                    self.ach_transfer_minimum = (value as! Double)
                }

            case "latituide":
                if (value as? Double).isNotNil {
                    lat = (value as! Double)
                }

            case "longitude":
                if (value as? Double).isNotNil {
                    lon = (value as! Double)
                }

            default:
                print("This should not occur")
            }
            
        }
        
        // add the geopoint if the lat and lon are sent in - if not get rid of the geopooint
        if lat != 0.0 && lon != 0.0 {
            self.geopoint = CCXGeographyPoint(latitude: lat, longitude: lon)
        } else {
            self.geopoint = nil
        }
        
    }
    
    
    func asDictionary() -> [String: Any] {
        
        var dictionary:[String:Any] = [:]
        
        if self.id.isNotNil {
            dictionary.id = self.id
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
        
        if self.deleted.isNotNil {
            dictionary.deleted = self.deleted
        }
        
        if self.deletedby.isNotNil {
            dictionary.deletedBy = self.deletedby
        }
        
        if self.country_id.isNotNil {
            dictionary.addressDic.countryId = self.country_id
        }
        
        if self.retailer_id.isNotNil {
            dictionary.addressDic.retailerId = self.retailer_id
        }
        
        if self.retailer_contact_id.isNotNil {
            dictionary.addressDic.retailerContactId = self.retailer_contact_id
        }
        
        if self.address3.isNotNil {
            dictionary.addressDic.address3 = self.address3
        }
        
        if self.address2.isNotNil {
            dictionary.addressDic.address2 = self.address2
        }
        
        if self.address1.isNotNil {
            dictionary.addressDic.address1 = self.address1
        }
        
        if self.city.isNotNil {
            dictionary.addressDic.city = self.city
        }
        
        if self.state.isNotNil {
            dictionary.addressDic.state = self.state
        }
        
        if self.postal_code.isNotNil {
            dictionary.addressDic.postalCode = self.postal_code
        }

        if self.ach_transfer_minimum.isNotNil {
            dictionary.addressDic.ach_transfer_minimum = self.ach_transfer_minimum
        }

        if self.geopoint.isNotNil {
            dictionary.addressDic.latitude  = self.geopoint?.latitude
            dictionary.addressDic.longitude = self.geopoint?.longitude
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: Address)-> Bool {
        
        var diff = true
        
        if diff == true, self.country_id != targetItem.country_id {
            diff = false
        }
        
        if diff == true, self.retailer_id != targetItem.retailer_id {
            diff = false
        }
        
        if diff == true, self.retailer_contact_id != targetItem.retailer_contact_id {
            diff = false
        }
        
        if diff == true, self.state != targetItem.state {
            diff = false
        }
        
        if diff == true, self.city != targetItem.city {
            diff = false
        }
        
        if diff == true, self.postal_code != targetItem.postal_code {
            diff = false
        }
        
        if diff == true, self.address3 != targetItem.address3 {
            diff = false
        }
        
        if diff == true, self.address2 != targetItem.address2 {
            diff = false
        }
        
        if diff == true, self.address1 != targetItem.address1 {
            diff = false
        }

        if diff == true, self.ach_transfer_minimum != targetItem.ach_transfer_minimum {
            diff = false
        }

        if diff == true, self.geopoint?.latitude != targetItem.geopoint?.latitude  {
            diff = false
        }

        if diff == true, self.geopoint?.longitude != targetItem.geopoint?.longitude  {
            diff = false
        }

        return diff
        
    }
}


