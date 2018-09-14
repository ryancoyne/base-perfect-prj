//
//  CashoutOption.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class CashoutOption: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var cashout_source_id : Int? = nil
    var group_id          : Int? = nil
    var form_id           : Int? = nil
    var display_order     : Int? = nil
    var name              : String? = nil
    var website           : String? = nil
    var description       : String? = nil
    var long_description  : String? = nil
    var picture_url        : String? = nil
    var sm_picture_url        : String? = nil
    var icon_url        : String? = nil
    var minimum           : Double? = nil
    var maximum           : Double? = nil
    var display           : Bool? = nil

    //MARK: Table name
    override public func table() -> String { return "cashout_option" }
    
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

        if let data = this.data.cashoutOptionsDic.cashoutSourceId {
            cashout_source_id = data
        }

        if let data = this.data.cashoutOptionsDic.formId {
            form_id = data
        }
        
        if let data = this.data.cashoutOptionsDic.groupId {
            group_id = data
        }
        
        if let data = this.data.shortdescription {
            description = data
        }
        
        if let data = this.data.cashoutOptionsDic.longDescription {
            long_description = data
        }
        
        if let data = this.data.cashoutOptionsDic.pictureURL {
            picture_url = data
        }
        
        if let data = this.data.cashoutOptionsDic.smallPictureURL {
            sm_picture_url = data
        }
        
        if let data = this.data.cashoutOptionsDic.iconURL {
            icon_url = data
        }
        
        if let data = this.data.cashoutOptionsDic.name {
            name = data
        }
        
        if let data = this.data.cashoutOptionsDic.displayOrder {
            display_order = data
        }
        
        if let data = this.data.cashoutOptionsDic.maximum {
            maximum = data
        }
        
        if let data = this.data.cashoutOptionsDic.minimum {
            minimum = data
        }
        
        if let data = this.data.cashoutOptionsDic.website {
            website = data
        }

        if let data = this.data.cashoutOptionsDic.display {
            display = data
        }

    }
    
    func rows() -> [CashoutOption] {
        var rows = [CashoutOption]()
        for i in 0..<self.results.rows.count {
            let row = CashoutOption()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {

            case "cashout_source_id":
                if (value as? Int).isNotNil {
                    self.cashout_source_id = (value as! Int)
                }

            case "form_id":
                if (value as? Int).isNotNil {
                    self.form_id = (value as! Int)
                }
                
            case "group_id":
                if (value as? Int).isNotNil {
                    self.group_id = (value as! Int)
                }
            
            case "maximum":
                if (value as? Double).isNotNil {
                    self.maximum = (value as! Double)
                }
                
            case "minimum":
                if (value as? Double).isNotNil {
                    self.minimum = (value as! Double)
                }
                
            case "picture_url":
                if (value as? String).isNotNil {
                    self.picture_url = (value as! String)
                }
                
            case "sm_picture_url":
                if (value as? String).isNotNil {
                    self.sm_picture_url = (value as! String)
                }
                
            case "icon_url":
                if (value as? String).isNotNil {
                    self.icon_url = (value as! String)
                }
                
            case "display_order":
                if (value as? Int).isNotNil {
                    self.display_order = (value as! Int)
                }
                
            case "name":
                if (value as? String).isNotNil {
                    self.name = (value as! String)
                }
                
            case "description":
                if (value as? String).isNotNil {
                    self.description = (value as! String)
                }
                
            case "long_description":
                if (value as? String).isNotNil {
                    self.long_description = (value as! String)
                }
                
            case "website":
                if (value as? String).isNotNil {
                    self.website = (value as! String)
                }

            case "display":
                if (value as? Bool).isNotNil {
                    self.display = (value as! Bool)
                }

            default:
                print("This should not occur")
            }
            
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
        
        if self.group_id.isNotNil {
            dictionary.cashoutOptionsDic.groupId = self.group_id
        }
        
        if self.form_id.isNotNil {
            dictionary.cashoutOptionsDic.formId = self.form_id
        }
        
        if self.name.isNotNil {
            dictionary.cashoutOptionsDic.name = self.name
        }
        
        if self.website.isNotNil {
            dictionary.cashoutOptionsDic.website = self.website
        }
        
        if self.display_order.isNotNil {
            dictionary.cashoutOptionsDic.displayOrder = self.display_order
        }
        
        if self.picture_url.isNotNil {
            dictionary.cashoutOptionsDic.pictureURL = self.picture_url
        }
        
        if self.sm_picture_url.isNotNil {
            dictionary.cashoutOptionsDic.smallPictureURL = self.sm_picture_url
        }
        
        if self.icon_url.isNotNil {
            dictionary.cashoutOptionsDic.iconURL = self.icon_url
        }
        
        if self.description.isNotNil {
            dictionary.shortdescription = self.description
        }
        
        if self.long_description.isNotNil {
            dictionary.cashoutOptionsDic.longDescription = self.long_description
        }
        
        if self.maximum.isNotNil {
            dictionary.cashoutOptionsDic.maximum = self.maximum
        }
        
        if self.minimum.isNotNil {
            dictionary.cashoutOptionsDic.minimum = self.minimum
        }

        if self.display.isNotNil {
            dictionary.cashoutOptionsDic.display = self.display
        }

        if self.cashout_source_id.isNotNil {
            dictionary.cashoutOptionsDic.cashoutSourceId = self.cashout_source_id
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: CashoutOption)-> Bool {
        
        var diff = true
        
        if diff == true, self.cashout_source_id != targetItem.cashout_source_id {
            diff = false
        }
        
        if diff == true, self.group_id != targetItem.group_id {
            diff = false
        }
        
        if diff == true, self.form_id != targetItem.form_id {
            diff = false
        }
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.maximum != targetItem.maximum {
            diff = false
        }
        
        if diff == true, self.minimum != targetItem.minimum {
            diff = false
        }
        
        if diff == true, self.picture_url != targetItem.picture_url {
            diff = false
        }
        
        if diff == true, self.sm_picture_url != targetItem.sm_picture_url {
            diff = false
        }
        
        if diff == true, self.icon_url != targetItem.icon_url {
            diff = false
        }
        
        if diff == true, self.display_order != targetItem.display_order {
            diff = false
        }
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        if diff == true, self.long_description != targetItem.long_description {
            diff = false
        }
        
        if diff == true, self.website != targetItem.website {
            diff = false
        }

        if diff == true, self.display != targetItem.display {
            diff = false
        }

        return diff
        
    }
}

