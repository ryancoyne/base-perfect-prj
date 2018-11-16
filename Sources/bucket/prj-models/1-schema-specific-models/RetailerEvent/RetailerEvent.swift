//
//  RetailerEvent.swift
//  bucket
//
//  Created by Ryan Coyne on 11/15/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

/// This is the class that defines the order, by line, of which Sutton requires us to upload details.
public class RetailerEvent: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var event_name : String? = nil
    var event_message : String? = nil
    var start_date : Int? = nil
    var end_date : Int? = nil
    var retailer_id : Int? = nil
    
    //MARK: Table name
    override public func table() -> String { return "retailer_event" }
    
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
        
        if let data = this.data.retailerEventDic.eventName {
            event_name = data
        }
        
        if let data = this.data.retailerEventDic.eventMessage {
            event_message = data
        }
        
        if let data = this.data.retailerEventDic.startDate {
            start_date = data
        }
        
        if let data = this.data.retailerEventDic.endDate {
            end_date = data
        }
        
        if let data = this.data.retailerEventDic.retailerId {
            retailer_id = data
        }
        
    }
    
    func rows() -> [RetailerEvent] {
        var rows = [RetailerEvent]()
        for i in 0..<self.results.rows.count {
            let row = RetailerEvent()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "start_date":
                if (value as? Int).isNotNil {
                    self.start_date = (value as! Int)
                }
                
            case "end_date":
                if (value as? Int).isNotNil {
                    self.end_date = (value as! Int)
                }
                
            case "retailer_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "event_message":
                if (value as? String).isNotNil {
                    self.event_message = (value as! String)
                }
                
            case "event_name":
                if (value as? String).isNotNil {
                    self.event_name = (value as! String)
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
        
        if self.retailer_id.isNotNil {
            dictionary.retailerEventDic.retailerId = self.retailer_id
        }
        
        
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: RetailerEvent)-> Bool {
        
        var diff = true
        
        if diff == true, self.retailer_id != targetItem.retailer_id {
            diff = false
        }
        
        if diff == true, self.event_message != targetItem.event_message {
            diff = false
        }
        
        if diff == true, self.event_name != targetItem.event_name {
            diff = false
        }
        
        if diff == true, self.start_date != targetItem.start_date {
            diff = false
        }
        
        if diff == true, self.end_date != targetItem.end_date {
            diff = false
        }
        
        return diff
        
    }
    
    public static func exists(withId : Int) -> Bool {
        let test = RetailerEvent()
        try? test.get(withId)
        return test.isError()
    }
    
}




