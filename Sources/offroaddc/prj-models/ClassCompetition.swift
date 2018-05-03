//
//  ClassCompetition.swift
//  Atlete Program
//
//  Created by Mike Silvers on 5/2/18.
//
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class ClassCompetition: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id                  : Int?    = nil
    var created             : Int?    = nil
    var createdby           : String? = nil
    var modified            : Int?    = nil
    var modifiedby          : String? = nil
    
    var name                : String? = nil
    var start_time          : Int?    = nil
    var end_time            : Int?    = nil
    var private_competition : Bool    = true
    var leader_user_id      : String? = nil
    var competition_type_id : Int?    = nil

    //MARK: Table name
    override public func table() -> String { return "class_competition" }
    
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
        
        if let data = this.data.class_competition.name {
            name = data
        }
        
        if let data = this.data.class_competition.start_time {
            start_time = data
        }
        
        if let data = this.data.class_competition.end_time {
            end_time = data
        }
        
        if let data = this.data.class_competition.private_competition {
            private_competition = data
        }
        
        if let data = this.data.class_competition.leader_user_id {
            leader_user_id = data
        }
        
        if let data = this.data.class_competition.competition_type_id {
            competition_type_id = data
        }
    }
    
    func rows() -> [ClassCompetition] {
        var rows = [ClassCompetition]()
        for i in 0..<self.results.rows.count {
            let row = ClassCompetition()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "name":
                if !(value as! String).isEmpty {
                    self.name = (value as! String)
                }

            case "start_time":
                if let v = (value as? Int) {
                    self.start_time = v
                }

            case "end_time":
                if let v = (value as? Int) {
                    self.end_time = v
                }

            case "private_competition":
                if let v = (value as? Bool) {
                    self.private_competition = v
                }

            case "leader_user_id":
                if !(value as! String).isEmpty {
                    self.leader_user_id = (value as! String)
                }

            case "competition_type_id":
                if let v = (value as? Int) {
                    self.competition_type_id = v
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
        
        
        
        if self.name.isNotNil {
            dictionary.class_competition.name = self.name
        }
        
        if self.start_time.isNotNil {
            dictionary.class_competition.start_time = self.start_time
        }

        if self.end_time.isNotNil {
            dictionary.class_competition.end_time = self.end_time
        }

        // the default is TRUE
        dictionary.class_competition.private_competition = self.private_competition

        if self.leader_user_id.isNotNil {
            dictionary.class_competition.leader_user_id = self.leader_user_id
        }

        if self.competition_type_id.isNotNil {
            dictionary.class_competition.competition_type_id = self.competition_type_id
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: ClassCompetition)-> Bool {
        
        var diff = true
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.start_time != targetItem.start_time {
            diff = false
        }
        
        if diff == true, self.end_time != targetItem.end_time {
            diff = false
        }
        
        if diff == true, self.private_competition != targetItem.private_competition {
            diff = false
        }
        
        if diff == true, self.competition_type_id != targetItem.competition_type_id {
            diff = false
        }
        
        if diff == true, self.leader_user_id != targetItem.leader_user_id {
            diff = false
        }
        
        return diff
        
    }
}

