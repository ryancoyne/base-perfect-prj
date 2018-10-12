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

public class USBucketAccountDetail: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var record_type         : String? = nil
    var change_date         : String? = nil
    var change_time         : String? = nil
    var account_number      : String? = nil
    var value_original      : Int? = nil
    var value_new           : Int? = nil
    var code_number         : String? = nil
    var amount              : Double? = nil
    var adjustment_reason   : Int? = nil
    var disbursement_reason : Int? = nil
    var note                : String? = nil
    
    var processed : Int? = nil
    var processedby : String? = nil

    //MARK: Table name
    override public func table() -> String { return "us_bucket_account_detail" }
    
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
        
        if let data = this.data.usAccountDetailDic.processed {
            processed  = data
        }
        
        if let data = this.data.usAccountDetailDic.processedby {
            processedby  = data
        }
        
        if let data = this.data.usBucketAccountDetailDic.record_type {
           record_type  = data
        }
        
        if let data = this.data.usBucketAccountDetailDic.change_date {
            change_date = data
        }
        
        if let data = this.data.usBucketAccountDetailDic.change_time {
            change_time = data
        }
        
        if let data = this.data.usBucketAccountDetailDic.account_number {
            account_number = data
        }
        
        if let data = this.data.usBucketAccountDetailDic.value_original {
            value_original = data
        }
        
        if let data = this.data.usBucketAccountDetailDic.value_new {
            value_new = data
        }

        if let data = this.data.usBucketAccountDetailDic.code_number {
            code_number = data
        }

        if let data = this.data.usBucketAccountDetailDic.amount {
            amount = data
        }

        if let data = this.data.usBucketAccountDetailDic.adjustment_reason {
            adjustment_reason = data
        }

        if let data = this.data.usBucketAccountDetailDic.disbursement_reason {
            disbursement_reason = data
        }

        if let data = this.data.usBucketAccountDetailDic.note {
            note = data
        }

    }
    
    func rows() -> [USBucketAccountDetail] {
        var rows = [USBucketAccountDetail]()
        for i in 0..<self.results.rows.count {
            let row = USBucketAccountDetail()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "record_type":
                if (value as? String).isNotNil {
                    self.record_type = (value as! String)
                }
                
            case "change_date":
                if (value as? String).isNotNil {
                    self.change_date = (value as! String)
                }
                
            case "processedby":
                if (value as? String).isNotNil {
                    self.processedby = (value as! String)
                }
                
            case "processed":
                if (value as? Int).isNotNil {
                    self.processed = (value as! Int)
                }
                
            case "change_time":
                if (value as? String).isNotNil {
                    self.change_time = (value as! String)
                }
                
            case "account_number":
                if (value as? String).isNotNil {
                    self.account_number = (value as! String)
                }
                
            case "value_original":
                if (value as? Int).isNotNil {
                    self.value_original = (value as! Int)
                }
                
            case "value_new":
                if (value as? Int).isNotNil {
                    self.value_new = (value as! Int)
                }

            case "code_number":
                if (value as? String).isNotNil {
                    self.code_number = (value as! String)
                }

            case "amount":
                if (value as? Double).isNotNil {
                    self.amount = (value as! Double)
                }

            case "adjustment_reason":
                if (value as? Int).isNotNil {
                    self.adjustment_reason = (value as! Int)
                }

            case "disbursement_reason":
                if (value as? Int).isNotNil {
                    self.disbursement_reason = (value as! Int)
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
        
        if self.record_type.isNotNil {
            dictionary.usBucketAccountDetailDic.record_type = self.record_type
        }
        
        if self.change_date.isNotNil {
            dictionary.usBucketAccountDetailDic.change_date = self.change_date
        }
        
        if self.change_time.isNotNil {
            dictionary.usBucketAccountDetailDic.change_time = self.change_time
        }
        
        if self.account_number.isNotNil {
            dictionary.usBucketAccountDetailDic.account_number = self.account_number
        }
        
        if self.value_original.isNotNil {
            dictionary.usBucketAccountDetailDic.value_original = self.value_original
        }
        
        if self.value_new.isNotNil {
            dictionary.usBucketAccountDetailDic.value_new = self.value_new
        }

        if self.code_number.isNotNil {
            dictionary.usBucketAccountDetailDic.code_number = self.code_number
        }

        if self.amount.isNotNil {
            dictionary.usBucketAccountDetailDic.amount = self.amount
        }

        if self.adjustment_reason.isNotNil {
            dictionary.usBucketAccountDetailDic.adjustment_reason = self.adjustment_reason
        }

        if self.disbursement_reason.isNotNil {
            dictionary.usBucketAccountDetailDic.disbursement_reason = self.disbursement_reason
        }

        if self.note.isNotNil {
            dictionary.usBucketAccountDetailDic.note = self.note
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: USBucketAccountDetail)-> Bool {
        
        var diff = true
        
        if diff == true, self.record_type != targetItem.record_type {
            diff = false
        }
        
        if diff == true, self.change_date != targetItem.change_date {
            diff = false
        }
        
        if diff == true, self.change_time != targetItem.change_time {
            diff = false
        }
        
        if diff == true, self.account_number != targetItem.account_number {
            diff = false
        }
        
        if diff == true, self.value_original != targetItem.value_original {
            diff = false
        }
        
        if diff == true, self.value_new != targetItem.value_new {
            diff = false
        }

        if diff == true, self.code_number != targetItem.code_number {
            diff = false
        }

        if diff == true, self.amount != targetItem.amount {
            diff = false
        }

        if diff == true, self.adjustment_reason != targetItem.adjustment_reason {
            diff = false
        }

        if diff == true, self.disbursement_reason != targetItem.disbursement_reason {
            diff = false
        }

        if diff == true, self.note != targetItem.note {
            diff = false
        }

        return diff
        
    }
}


