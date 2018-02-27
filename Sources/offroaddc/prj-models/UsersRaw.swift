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

public class UsersRaw: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    
    var source     : String? = nil
    var account_id : String? = nil
    var source_id  : String? = nil
    var name_first : String? = nil
    var name_last  : String? = nil
    var name_full  : String? = nil
    var nickname   : String? = nil
    var email      : String? = nil
    var gender     : String? = nil
    var status     : String? = nil

    var weight     : Float?    = nil
    var phone      : String?    = nil

    //MARK: Table name
    override public func table() -> String { return "users_raw" }
    
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
            email = data
        }
        
        if let data = this.data.users_raw.gender {
            gender = data
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
            source = data
        }
        
        if let data = this.data.users_raw.source_id {
            source_id = data
        }
        
        if let data = this.data.users_raw.weight {
            weight = data
        }

        if let data = this.data.users_raw.status {
            status = data
        }

    }
    
    func rows() -> [UsersRaw] {
        var rows = [UsersRaw]()
        for i in 0..<self.results.rows.count {
            let row = UsersRaw()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "account_id":
                if !(value as! String).isEmpty {
                    self.account_id = (value as! String)
                }
                
            case "email":
                if !(value as! String).isEmpty {
                    self.email = (value as! String)
                }

            case "gender":
                if !(value as! String).isEmpty {
                    self.gender = (value as! String)
                }

            case "name_first":
                if !(value as! String).isEmpty {
                    self.name_first = (value as! String)
                }

            case "name_last":
                if !(value as! String).isEmpty {
                    self.name_last = (value as! String)
                }

            case "name_full":
                if !(value as! String).isEmpty {
                    self.name_full = (value as! String)
                }

            case "nickname":
                if !(value as! String).isEmpty {
                    self.nickname = (value as! String)
                }

            case "phone":
                if let val = value as? String {
                    self.phone = val
                }

            case "source":
                if !(value as! String).isEmpty {
                    self.source = (value as! String)
                }

            case "source_id":
                if !(value as! String).isEmpty {
                    self.source_id = (value as! String)
                }

            case "weight":
                if (value as! Float) != 0.0 {
                    self.weight = (value as! Float)
                }

            case "status":
                if !(value as! String).isEmpty {
                    self.status = (value as! String)
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
        
        if self.account_id.isNotNil {
            dictionary.users_raw.account_id = self.account_id
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

