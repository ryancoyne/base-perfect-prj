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

public class CodeTransactionRedeemSummary: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var country_id    : Int? = nil
    var customer_code : String? = nil

    //MARK: Table name
    override public func table() -> String { return "code_transaction_redeem_summary" }
    
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
        
        if let data = this.data.codeTransactionRedeemSummaryDic.country_id {
            country_id = data
        }
        
        if let data = this.data.codeTransactionRedeemSummaryDic.customer_code {
            customer_code = data
        }

    }
    
    func rows() -> [CodeTransactionRedeemSummary] {
        var rows = [CodeTransactionRedeemSummary]()
        for i in 0..<self.results.rows.count {
            let row = CodeTransactionRedeemSummary()
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
                
            case "customer_code":
                if (value as? String).isNotNil {
                    self.customer_code = (value as! String)
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
        
        if self.country_id.isNotNil {
            dictionary.codeTransactionRedeemSummaryDic.country_id = self.country_id
        }

        if self.customer_code.isNotNil {
            dictionary.codeTransactionRedeemSummaryDic.customer_code = self.customer_code
        }

        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: CodeTransactionRedeemSummary)-> Bool {
        
        var diff = true
        
        if diff == true, self.country_id != targetItem.country_id {
            diff = false
        }
        
        if diff == true, self.customer_code != targetItem.customer_code {
            diff = false
        }

        return diff
        
    }
}

