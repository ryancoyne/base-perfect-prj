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
        
        if let data = this.data.users_raw.account_id {
            account_id = data
        }
        
        if let data = this.data.users_raw.email {
            email = data.lowercased()
        }
        
        if let data = this.data.users_raw.gender {
            gender = data.lowercased()
        }
        
        if let data = this.data.users_raw.name_first {
            name_first = data
        }
        
        if let data = this.data.users_raw.name_last {
            name_last = data
        }
        
        if let data = this.data.users_raw.name_full {
            name_full = data
        }
        
        if let data = this.data.users_raw.nickname {
            nickname = data
        }
        
        if let data = this.data.users_raw.phone {
            phone = data
        }
        
        if let data = this.data.users_raw.source {
            source = data.lowercased()
        }
        
        if let data = this.data.users_raw.source_id {
            source_id = data
        }
        
        if let data = this.data.users_raw.weight {
            weight = data
        }

        if let data = this.data.users_raw.status {
            status = data.lowercased()
        }
        
        if let data = this.data.users_raw.source_location_id {
            source_location_id = data
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
                if !(value as! Int).isEmpty {
                    self.start_time = (value as! Int)
                }

            case "end_time":
                if !(value as! Int).isEmpty {
                    self.end_time = (value as! Int)
                }

            case "private_competition":
                if !(value as! Bool).isEmpty {
                    self.private_competition = (value as! Bool)
                }

            case "leader_user_id":
                if !(value as! String).isEmpty {
                    self.leader_user_id = (value as! String)
                }

            case "competition_type_id":
                if !(value as! Int).isEmpty {
                    self.competition_type_id = (value as! Int)
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
            dictionary. = self.name
        }
        
        if self.email.isNotNil {
            dictionary.users_raw.email = self.email
        }

        if self.gender.isNotNil {
            dictionary.users_raw.gender = self.gender
        }

        if self.name_first.isNotNil {
            dictionary.users_raw.name_first = self.name_first
        }

        if self.name_full.isNotNil {
            dictionary.users_raw.name_full = self.name_full
        }

        if self.name_last.isNotNil {
            dictionary.users_raw.name_last = self.name_last
        }
        
        if self.nickname.isNotNil {
            dictionary.users_raw.nickname = self.nickname
        }
        
        if self.phone.isNotNil {
            dictionary.users_raw.phone = self.phone
        }
        
        if self.source.isNotNil {
            dictionary.users_raw.source = self.source
        }
        
        if self.source_id.isNotNil {
            dictionary.users_raw.source_id = self.source_id
        }

        if self.source_location_id.isNotNil {
            dictionary.users_raw.source_location_id = self.source_location_id
        }

        if self.weight.isNotNil {
            dictionary.users_raw.weight = self.weight
        }

        if self.status.isNotNil {
            dictionary.users_raw.status = self.status
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: UsersRaw)-> Bool {
        
        var diff = true
        
        if diff == true, self.account_id != targetItem.account_id {
            diff = false
        }
        
        if diff == true, self.email != targetItem.email {
            diff = false
        }
        
        if diff == true, self.gender != targetItem.gender {
            diff = false
        }
        
        if diff == true, self.name_first != targetItem.name_first {
            diff = false
        }
        
        if diff == true, self.name_full != targetItem.name_full {
            diff = false
        }
        
        if diff == true, self.name_last != targetItem.name_last {
            diff = false
        }
        
        if diff == true, self.nickname != targetItem.nickname {
            diff = false
        }
        
        if diff == true, self.phone != targetItem.phone {
            diff = false
        }
        
        if diff == true, self.source != targetItem.source {
            diff = false
        }
        
        if diff == true, self.source_id != targetItem.source_id {
            diff = false
        }
        
        if diff == true, self.weight != targetItem.weight {
            diff = false
        }

        if diff == true, self.status != targetItem.status {
            diff = false
        }

        return diff
        
    }
}

