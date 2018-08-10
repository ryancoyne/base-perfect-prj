//
//  TransactionHistory.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class CodeTransactionHistory: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var retailer_id     : Int? = nil
    var country_id     : Int? = nil
    var customer_code     : String? = nil
    var customer_codeURL     : String? = nil
    var terminal_id : Int? = nil
    var client_location : String? = nil
    var client_transaction_id     : String? = nil
    var batch_id : String? = nil
    var amount : Double? = nil
    var total_amount : Double? = nil
    
    var disputed : Int? = nil
    var disputedby : String? = nil
    var redeemed : Int? = nil
    var redeemedby : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "code_transaction_history" }
    
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
        
        if let data = this.data.codeTransactionHistoryDic.countryId {
            country_id = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.retailerId {
            retailer_id = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.batchId {
            batch_id = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.clientLocation {
            client_location = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.clientTransactionId {
            client_transaction_id = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.customerCode {
            customer_code = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.customerCodeURL {
            customer_codeURL = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.redeemed {
            redeemed = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.redeemedBy {
            redeemedby = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.disputedBy {
            disputedby = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.disputed {
            disputed = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.terminalId {
            terminal_id = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.amount {
            amount = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.totalAmount {
            total_amount = data
        }
        
    }
    
    func rows() -> [CodeTransactionHistory] {
        var rows = [CodeTransactionHistory]()
        for i in 0..<self.results.rows.count {
            let row = CodeTransactionHistory()
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
                
            case "retailer_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "client_transaction_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "terminal_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "amount":
                if (value as? Double).isNotNil {
                    self.amount = (value as! Double)
                }
                
            case "total_amount":
                if (value as? Double).isNotNil {
                    self.total_amount = (value as! Double)
                }
                
            case "customer_code":
                if (value as? String).isNotNil {
                    self.customer_code = (value as! String)
                }
                
            case "customer_codeURL":
                if (value as? String).isNotNil {
                    self.customer_codeURL = (value as! String)
                }
                
            case "client_location":
                if (value as? String).isNotNil {
                    self.client_location = (value as! String)
                }
                
            case "batch_id":
                if (value as? String).isNotNil {
                    self.batch_id = (value as! String)
                }
                
            case "redeemed_by":
                if (value as? String).isNotNil {
                    self.redeemedby = (value as! String)
                }
                
            case "redeemed":
                if (value as? Int).isNotNil {
                    self.redeemed = (value as! Int)
                }
                
            case "disputed_by":
                if (value as? String).isNotNil {
                    self.disputedby = (value as! String)
                }
                
            case "disputed":
                if (value as? Int).isNotNil {
                    self.disputed = (value as! Int)
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
            dictionary.codeTransactionHistoryDic.countryId = self.country_id
        }
        
        if self.retailer_id.isNotNil {
            dictionary.codeTransactionHistoryDic.retailerId = self.retailer_id
        }
        
        if self.client_transaction_id.isNotNil {
            dictionary.codeTransactionHistoryDic.clientTransactionId = self.client_transaction_id
        }
        
        if self.redeemedby.isNotNil {
            dictionary.codeTransactionHistoryDic.redeemedBy = self.redeemedby
        }
        
        if self.redeemed.isNotNil {
            dictionary.codeTransactionHistoryDic.redeemed = self.redeemed
        }
        
        if self.disputedby.isNotNil {
            dictionary.codeTransactionHistoryDic.disputedBy = self.disputedby
        }
        
        if self.disputed.isNotNil {
            dictionary.codeTransactionHistoryDic.disputed = self.disputed
        }
        
        if self.batch_id.isNotNil {
            dictionary.codeTransactionHistoryDic.batchId = self.batch_id
        }
        
        if self.client_location.isNotNil {
            dictionary.codeTransactionHistoryDic.clientLocation = self.client_location
        }
        
        if self.customer_code.isNotNil {
            dictionary.codeTransactionHistoryDic.customerCode = self.customer_code
        }
        
        if self.customer_codeURL.isNotNil {
            dictionary.codeTransactionHistoryDic.customerCodeURL = self.customer_codeURL
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: CodeTransactionHistory)-> Bool {
        
        var diff = true
        
        if diff == true, self.retailer_id != targetItem.retailer_id {
            diff = false
        }
        
        if diff == true, self.client_location != targetItem.client_location {
            diff = false
        }
        
        if diff == true, self.client_transaction_id != targetItem.client_transaction_id {
            diff = false
        }
        
        if diff == true, self.country_id != targetItem.country_id {
            diff = false
        }
        
        if diff == true, self.customer_code != targetItem.customer_code {
            diff = false
        }
        
        if diff == true, self.customer_codeURL != targetItem.customer_codeURL {
            diff = false
        }
        
        if diff == true, self.amount != targetItem.amount {
            diff = false
        }
        
        if diff == true, self.total_amount != targetItem.total_amount {
            diff = false
        }
        
        if diff == true, self.redeemed != targetItem.redeemed {
            diff = false
        }
        
        if diff == true, self.redeemedby != targetItem.redeemedby {
            diff = false
        }
        
        if diff == true, self.disputed != targetItem.disputed {
            diff = false
        }
        
        if diff == true, self.disputedby != targetItem.disputedby {
            diff = false
        }
        
        if diff == true, self.batch_id != targetItem.batch_id {
            diff = false
        }
        
        if diff == true, self.terminal_id != targetItem.terminal_id {
            diff = false
        }
        
        return diff
        
    }
}
