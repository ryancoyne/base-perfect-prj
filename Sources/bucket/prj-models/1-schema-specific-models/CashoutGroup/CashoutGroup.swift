//
//  CashoutGroup.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class CashoutGroup: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var display       : Bool? = nil
    var group_name    : String? = nil
    var description   : String? = nil
    var long_description   : String? = nil
    var picture_url   : String? = nil
    var icon_url : String?=nil
    var detail_icon_url : String?=nil
    var option_layout : String?=nil
    var display_order : Int? = nil
    var country_id    : Int? = nil
    var threshold_amount : Double? = nil
    var detail_disbursement_reasons : Int? = nil
    
    //MARK: Table name
    override public func table() -> String { return "cashout_group" }
    
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
        
        if let data = this.data.cashoutGroupDic.optionLayout {
            option_layout = data
        }
        
        if let data = this.data.cashoutGroupDic.iconURL {
            icon_url = data
        }
        
        if let data = this.data.cashoutGroupDic.detailIconURL {
            detail_icon_url = data
        }
        
        if let data = this.data.cashoutGroupDic.country_id {
            country_id = data
        }
        
        if let data = this.data.cashoutGroupDic.description {
            description = data
        }
        
        if let data = this.data.cashoutGroupDic.longDescription {
            long_description = data
        }

        if let data = this.data.cashoutGroupDic.display_order {
            display_order = data
        }

        if let data = this.data.cashoutGroupDic.group_name {
            group_name = data
        }
        
        if let data = this.data.cashoutGroupDic.thresholdAmount {
            threshold_amount = data
        }

        if let data = this.data.cashoutGroupDic.picture_url {
            picture_url = data
        }

        if let data = this.data.cashoutGroupDic.display {
            display = data
        }

        if let data = this.data.cashoutGroupDic.detail_disbursement_reasons {
            detail_disbursement_reasons = data
        }

        

    }
    
    func rows() -> [CashoutGroup] {
        var rows = [CashoutGroup]()
        for i in 0..<self.results.rows.count {
            let row = CashoutGroup()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
                
            case "country_id":
                if (value as? Int).isNotNil {
                    self.country_id = (value as! Int)
                }
                
            case "description":
                if (value as? String).isNotNil {
                    self.description = (value as! String)
                }
            
            case "long_description":
                if (value as? String).isNotNil {
                    self.long_description = (value as! String)
                }
                
            case "threshold_amount":
                if (value as? Double).isNotNil {
                    self.threshold_amount = (value as! Double)
                }
                
            case "icon_url":
                if (value as? String).isNotNil {
                    self.icon_url = (value as! String)
                }
                
            case "detail_icon_url":
                if (value as? String).isNotNil {
                    self.detail_icon_url = (value as! String)
                }
                
            case "option_layout":
                if (value as? String).isNotNil {
                    self.option_layout = (value as! String)
                }
                
            case "display_order":
                if (value as? Int).isNotNil {
                    self.display_order = (value as! Int)
                }
                
            case "group_name":
                if (value as? String).isNotNil {
                    self.group_name = (value as! String)
                }
                
            case "picture_url":
                if (value as? String).isNotNil {
                    self.picture_url = (value as! String)
                }

            case "display":
                if (value as? Bool).isNotNil {
                    self.display = (value as! Bool)
                }
                
            case "detail_disbursement_reasons":
                if (value as? Int).isNotNil {
                    self.detail_disbursement_reasons = (value as! Int)
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
        
        if self.option_layout.isNotNil {
            dictionary.cashoutGroupDic.optionLayout = self.option_layout
        }
        
        if self.icon_url.isNotNil {
            dictionary.cashoutGroupDic.iconURL = self.icon_url
        }
        
        if self.detail_icon_url.isNotNil {
            dictionary.cashoutGroupDic.detailIconURL = self.detail_icon_url
        }
        
        if self.country_id.isNotNil {
            dictionary.cashoutGroupDic.country_id = self.country_id
        }

        if self.group_name.isNotNil {
            dictionary.cashoutGroupDic.group_name = self.group_name
        }

        if self.display_order.isNotNil {
            dictionary.cashoutGroupDic.display_order = self.display_order
        }

        if self.description.isNotNil {
            dictionary.cashoutGroupDic.description = self.description
        }
        
        if self.long_description.isNotNil {
            dictionary.cashoutGroupDic.longDescription = self.long_description
        }

        if self.picture_url.isNotNil {
            dictionary.cashoutGroupDic.picture_url = self.picture_url
        }
        
        if self.threshold_amount.isNotNil {
            dictionary.cashoutGroupDic.thresholdAmount = self.threshold_amount
        }

        if self.display.isNotNil {
            dictionary.cashoutGroupDic.display = self.display
        }

        if self.detail_disbursement_reasons.isNotNil {
            dictionary.cashoutGroupDic.detail_disbursement_reasons = self.detail_disbursement_reasons
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: CashoutGroup)-> Bool {
        
        var diff = true
        
        if diff == true, self.country_id != targetItem.country_id {
            diff = false
        }
        
        if diff == true, self.icon_url != targetItem.icon_url {
            diff = false
        }
        
        if diff == true, self.threshold_amount != targetItem.threshold_amount {
            diff = false
        }
        
        if diff == true, self.detail_icon_url != targetItem.detail_icon_url {
            diff = false
        }
        
        if diff == true, self.option_layout != targetItem.option_layout {
            diff = false
        }
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        if diff == true, self.long_description != targetItem.long_description {
            diff = false
        }

        if diff == true, self.group_name != targetItem.group_name {
            diff = false
        }

        if diff == true, self.display_order != targetItem.display_order {
            diff = false
        }
        
        if diff == true, self.picture_url != targetItem.picture_url {
            diff = false
        }

        if diff == true, self.display != targetItem.display {
            diff = false
        }

        if diff == true, self.detail_disbursement_reasons != targetItem.detail_disbursement_reasons {
            diff = false
        }
        
        return diff
        
    }
}

