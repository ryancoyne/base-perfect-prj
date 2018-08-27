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

public class CashoutSource: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var name               : String? = nil
    var website            : String? = nil
    var description        : String? = nil
    var source_id          : String? = nil
    var country_id         : Int?    = nil
    
    var hours_between_processing : Int?    = nil
    var lastprocessed            : Int?    = nil
    var lastprocessedby          : String? = nil
    var lastprocessed_note       : String? = nil

    //MARK: Table name
    override public func table() -> String { return "cashout_source" }
    
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
        
        if let data = this.data.shortdescription {
            description = data
        }
        
        if let data = this.data.cashoutSourceDic.sourceId {
            source_id = data
        }
        
        if let data = this.data.cashoutSourceDic.name {
            name = data
        }
        
        if let data = this.data.cashoutSourceDic.website {
            website = data
        }

        if let data = this.data.cashoutSourceDic.countryId {
            country_id = data
        }

        if let data = this.data.cashoutSourceDic.lastprocessed {
            lastprocessed = data
        }

        if let data = this.data.cashoutSourceDic.lastprocessedBy {
            lastprocessedby = data
        }

        if let data = this.data.cashoutSourceDic.lastprocessedNote {
            lastprocessed_note = data
        }

    }
    
    func rows() -> [CashoutSource] {
        var rows = [CashoutSource]()
        for i in 0..<self.results.rows.count {
            let row = CashoutSource()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "name":
                if (value as? String).isNotNil {
                    self.name = (value as! String)
                }
                
            case "description":
                if (value as? String).isNotNil {
                    self.description = (value as! String)
                }
                
            case "website":
                if (value as? String).isNotNil {
                    self.website = (value as! String)
                }

            case "source_id":
                if (value as? String).isNotNil {
                    self.source_id = (value as! String)
                }

            case "country_id":
                if (value as? Int).isNotNil {
                    self.country_id = (value as! Int)
                }

            case "hours_between_processing":
                if (value as? Int).isNotNil {
                    self.hours_between_processing = (value as! Int)
                }
            case "lastprocessed":
                if (value as? Int).isNotNil {
                    self.lastprocessed = (value as! Int)
                }

            case "lastprocessedby":
                if (value as? String).isNotNil {
                    self.lastprocessedby = (value as! String)
                }
            case "lastprocessed_note":
                if (value as? String).isNotNil {
                    self.lastprocessed_note = (value as! String)
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
        
        if self.name.isNotNil {
            dictionary.cashoutSourceDic.name = self.name
        }
        
        if self.website.isNotNil {
            dictionary.cashoutSourceDic.website = self.website
        }
        
        if self.description.isNotNil {
            dictionary.shortdescription = self.description
        }
        
        if self.source_id.isNotNil {
            dictionary.cashoutSourceDic.sourceId = self.source_id
        }

        if self.country_id.isNotNil {
            dictionary.cashoutSourceDic.countryId = self.country_id
        }
        if self.hours_between_processing.isNotNil {
            dictionary.cashoutSourceDic.hoursBetweenProcessing = self.hours_between_processing
        }
        if self.lastprocessed.isNotNil {
            dictionary.cashoutSourceDic.lastprocessed = self.lastprocessed
        }
        if self.lastprocessedby.isNotNil {
            dictionary.cashoutSourceDic.lastprocessedBy = self.lastprocessedby
        }
        if self.lastprocessed_note.isNotNil {
            dictionary.cashoutSourceDic.lastprocessedNote = self.lastprocessed_note
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: CashoutSource)-> Bool {
        
        var diff = true
        
        if diff == true, self.source_id != targetItem.source_id {
            diff = false
        }
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        if diff == true, self.website != targetItem.website {
            diff = false
        }

        if diff == true, self.country_id != targetItem.country_id {
            diff = false
        }

        if diff == true, self.hours_between_processing != targetItem.hours_between_processing {
            diff = false
        }

        if diff == true, self.lastprocessed != targetItem.lastprocessed {
            diff = false
        }

        if diff == true, self.lastprocessedby != targetItem.lastprocessedby {
            diff = false
        }

        if diff == true, self.lastprocessed_note != targetItem.lastprocessed_note {
            diff = false
        }

        return diff
        
    }
}

