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

public class ClassDate: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    
    var start_time              : Int? = nil
    var end_time                : Int? = nil
    var class_id                : Int? = nil
    var class_status_id         : Int? = nil
    var number_of_registrations : Int? = nil
    var number_of_waitlist      : Int? = nil
    var description             : String? = nil
    var instructor_user_id      : String? = nil

    //MARK: Table name
    override public func table() -> String { return "class_date" }
    
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
        
        if let data = this.data.createdBy {
            createdby = data
        }
        
        if let data = this.data.modifiedBy {
            modifiedby = data
        }
        
        
        
        if let data = this.data.class_date.start_time {
            start_time = data
        }
        
        if let data = this.data.class_date.end_time {
            end_time = data
        }
        
        if let data = this.data.class_date.class_id {
            class_id = data
        }
        
        if let data = this.data.class_date.class_status_id {
            class_status_id = data
        }
        
        if let data = this.data.class_date.description {
            description = data
        }

        if let data = this.data.class_date.instructor_user_id {
            instructor_user_id = data
        }

        if let data = this.data.class_date.number_of_registrations {
            number_of_registrations = data
        }

        if let data = this.data.class_date.number_of_waitlist {
            number_of_waitlist = data
        }

    }
    
    func rows() -> [ClassDate] {
        var rows = [ClassDate]()
        for i in 0..<self.results.rows.count {
            let row = ClassDate()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "start_time":
                if let v = (value as? Int) {
                    self.start_time = v
                }

            case "end_time":
                if let v = (value as? Int) {
                    self.end_time = v
                }

            case "class_id":
                if let v = (value as? Int) {
                    self.class_id = v
                }

            case "class_status_id":
                if let v = (value as? Int) {
                    self.class_status_id = v
                }

            case "number_of_registrations":
                if let v = (value as? Int) {
                    self.number_of_registrations = v
                }

            case "number_of_waitlist":
                if let v = (value as? Int) {
                    self.number_of_waitlist = v
                }

            case "description":
                if let v = (value as? String) {
                    self.description = v
                }
                
            case "instructor_user_id":
                if let v = (value as? String) {
                    self.description = v
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
        
        
        
        if self.start_time.isNotNil {
            dictionary.class_date.start_time = self.start_time
        }
        
        if self.end_time.isNotNil {
            dictionary.class_date.end_time = self.end_time
        }

        if self.class_id.isNotNil {
            dictionary.class_date.class_id = self.class_id
        }

        if self.class_status_id.isNotNil {
            dictionary.class_date.class_status_id = self.class_status_id
        }

        if self.description.isNotNil {
            dictionary.class_date.description = self.description
        }
        
        if self.instructor_user_id.isNotNil {
            dictionary.class_date.instructor_user_id = self.instructor_user_id
        }

        if self.number_of_registrations.isNotNil {
            dictionary.class_date.number_of_registrations = self.number_of_registrations
        }

        if self.number_of_waitlist.isNotNil {
            dictionary.class_date.number_of_waitlist = self.number_of_waitlist
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: ClassDate)-> Bool {
        
        var diff = true
        
        if diff == true, self.start_time != targetItem.start_time {
            diff = false
        }
        
        if diff == true, self.end_time != targetItem.end_time {
            diff = false
        }
        
        if diff == true, self.class_id != targetItem.class_id {
            diff = false
        }
        
        if diff == true, self.class_status_id != targetItem.class_status_id {
            diff = false
        }
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        if diff == true, self.instructor_user_id != targetItem.instructor_user_id {
            diff = false
        }

        if diff == true, self.number_of_registrations != targetItem.number_of_registrations {
            diff = false
        }

        if diff == true, self.number_of_waitlist != targetItem.number_of_waitlist {
            diff = false
        }

        return diff
        
    }
}

