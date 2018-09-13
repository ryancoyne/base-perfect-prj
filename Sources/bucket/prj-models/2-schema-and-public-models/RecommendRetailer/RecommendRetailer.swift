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

public class RecommendRetailer: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var user_id      : String? = nil
    var email_to     : String? = nil
    var emailsent    : Int?    = nil
    var emailsentby  : String? = nil
    var state        : String? = nil
    var city         : String? = nil
    var address      : String? = nil
    var postal_code  : String? = nil
    var country_code : String? = nil
    var phone        : String? = nil
    var name         : String? = nil
    var note         : String? = nil

    //MARK: Table name
    override public func table() -> String { return "recommend_retailer" }
    
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
        
        if let data = this.data.recommendRetailerDic.user_id {
           user_id  = data
        }
        
        if let data = this.data.recommendRetailerDic.email_to {
            email_to = data
        }
        
        if let data = this.data.recommendRetailerDic.emailsent {
            emailsent = data
        }
        
        if let data = this.data.recommendRetailerDic.emailsentby {
            emailsentby = data
        }
        
        if let data = this.data.recommendRetailerDic.state {
            state = data
        }
        
        if let data = this.data.recommendRetailerDic.city {
            city = data
        }
        
        if let data = this.data.recommendRetailerDic.address {
            address = data
        }
        
        if let data = this.data.recommendRetailerDic.postal_code {
            postal_code = data
        }
        
        if let data = this.data.recommendRetailerDic.country_code {
            country_code = data
        }
        
        if let data = this.data.recommendRetailerDic.phone {
            phone = data
        }

        if let data = this.data.recommendRetailerDic.name {
            name = data
        }

        if let data = this.data.recommendRetailerDic.note {
            note = data
        }

    }
    
    func rows() -> [RecommendRetailer] {
        var rows = [RecommendRetailer]()
        for i in 0..<self.results.rows.count {
            let row = RecommendRetailer()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "user_id":
                if (value as? String).isNotNil {
                    self.user_id = (value as! String)
                }
                
            case "email_to":
                if (value as? String).isNotNil {
                    self.email_to = (value as! String)
                }
                
            case "emailsent":
                if (value as? Int).isNotNil {
                    self.emailsent = (value as! Int)
                }
                
            case "emailsentby":
                if (value as? String).isNotNil {
                    self.emailsentby = (value as! String)
                }
                
            case "state":
                if (value as? String).isNotNil {
                    self.state = (value as! String)
                }
                
            case "city":
                if (value as? String).isNotNil {
                    self.city = (value as! String)
                }
                
            case "postal_code":
                if (value as? String).isNotNil {
                    self.postal_code = (value as! String)
                }
                
            case "address":
                if (value as? String).isNotNil {
                    self.address = (value as! String)
                }
                
            case "country_code":
                if (value as? String).isNotNil {
                    self.country_code = (value as! String)
                }

            case "phone":
                if (value as? String).isNotNil {
                    self.phone = (value as! String)
                }

            case "name":
                if (value as? String).isNotNil {
                    self.name = (value as! String)
                }

            case "note":
                if (value as? String).isNotNil {
                    self.note = (value as! String)
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
        
        if self.user_id.isNotNil {
            dictionary.recommendRetailerDic.user_id = self.user_id
        }
        
        if self.email_to.isNotNil {
            dictionary.recommendRetailerDic.email_to = self.email_to
        }
        
        if self.emailsent.isNotNil {
            dictionary.recommendRetailerDic.emailsent = self.emailsent
        }
        
        if self.emailsentby.isNotNil {
            dictionary.recommendRetailerDic.emailsentby = self.emailsentby
        }
        
        if self.state.isNotNil {
            dictionary.recommendRetailerDic.state = self.state
        }
        
        if self.city.isNotNil {
            dictionary.recommendRetailerDic.city = self.city
        }
        
        if self.address.isNotNil {
            dictionary.recommendRetailerDic.address = self.address
        }
        
        if self.postal_code.isNotNil {
            dictionary.recommendRetailerDic.postal_code = self.postal_code
        }
        
        if self.country_code.isNotNil {
            dictionary.recommendRetailerDic.country_code = self.country_code
        }

        if self.phone.isNotNil {
            dictionary.recommendRetailerDic.phone = self.phone
        }

        if self.name.isNotNil {
            dictionary.recommendRetailerDic.name = self.name
        }

        if self.note.isNotNil {
            dictionary.recommendRetailerDic.note = self.note
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: RecommendRetailer)-> Bool {
        
        var diff = true
        
        if diff == true, self.user_id != targetItem.user_id {
            diff = false
        }
        
        if diff == true, self.email_to != targetItem.email_to {
            diff = false
        }
        
        if diff == true, self.emailsent != targetItem.emailsent {
            diff = false
        }
        
        if diff == true, self.emailsentby != targetItem.emailsentby {
            diff = false
        }
        
        if diff == true, self.state != targetItem.state {
            diff = false
        }
        
        if diff == true, self.city != targetItem.city {
            diff = false
        }
        
        if diff == true, self.address != targetItem.address {
            diff = false
        }
        
        if diff == true, self.postal_code != targetItem.postal_code {
            diff = false
        }
        
        if diff == true, self.country_code != targetItem.country_code {
            diff = false
        }

        if diff == true, self.phone != targetItem.phone {
            diff = false
        }

        if diff == true, self.name != targetItem.name  {
            diff = false
        }

        if diff == true, self.note != targetItem.note  {
            diff = false
        }

        return diff
        
    }
}


