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

    var archived    : Int?    = nil
    var archivedby  : String? = nil

    var retailer_id           : Int? = nil
    var country_id            : Int? = nil
    var customer_code         : String? = nil
    var deleted_reason     : String? = nil
    var disputed_reason     : String? = nil
    var customer_codeurl      : String? = nil
    var terminal_id           : Int? = nil
    var client_location       : String? = nil
    var client_transaction_id : String? = nil
    var batch_id              : String? = nil
    var amount                : Double? = nil
    var amount_available      : Double? = nil
    var total_amount          : Double? = nil
    var status : String? = nil
    var description : String? = nil

    var disputed : Int? = nil
    var disputedby : String? = nil
    var redeemed : Int? = nil
    var redeemedby : String? = nil
    var cashedout : Int? = nil
    var cashedoutby : String? = nil
    var cashedout_total : Double? = nil
    var cashedout_note : String? = nil

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
        
        if let data = this.data.codeTransactionHistoryDic.disputedReason {
            disputed_reason = data
        }

        if let data = this.data.codeTransactionHistoryDic.cashedoutBy {
            cashedoutby = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.cashedout {
            cashedout = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.cashedoutNote {
            cashedout_note = data
        }
        if let data = this.data.codeTransactionHistoryDic.cashedoutTotal.doubleValue {
            cashedout_total = data
        }
        if let data = this.data.codeTransactionHistoryDic.deletedReason {
            deleted_reason = data
        }
        if let data = this.data.codeTransactionHistoryDic.archived.intValue {
            archived = data
        }
        
        if let data = this.data.codeTransactionHistoryDic.archivedBy {
            archivedby = data
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
            customer_codeurl = data
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

        if let data = this.data.codeTransactionHistoryDic.amountAvailable {
            amount_available = data
        }

        if let data = this.data.codeTransactionHistoryDic.totalAmount {
            total_amount = data
        }
        
        if let data = this.data.codeTransactionDic.status.stringValue {
            status = data
        }

        if let data = this.data.codeTransactionDic.description.stringValue {
            description = data
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

            case "id":
                if (value as? Int).isNotNil {
                    self.id = (value as! Int)
                }

            case "country_id":
                if (value as? Int).isNotNil {
                    self.country_id = (value as! Int)
                }
                
            case "retailer_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
                
            case "client_transaction_id":
                if (value as? String).isNotNil {
                    self.client_transaction_id = (value as! String)
                }
                
            case "terminal_id":
                if (value as? Int).isNotNil {
                    self.terminal_id = (value as! Int)
                }
                
            case "amount":
                if let dbV = (value as Any?).doubleValue {
                    self.amount = dbV
                }

            case "amount_available":
                if (value as? Double).isNotNil {
                    self.amount_available = (value as! Double)
                }

            case "total_amount":
                if let dbV = (value as Any?).doubleValue {
                    self.total_amount = dbV
                }
                
            case "customer_code":
                if (value as? String).isNotNil {
                    self.customer_code = (value as! String)
                }
                
            case "deleted_reason":
                if (value as? String).isNotNil {
                    self.deleted_reason = (value as! String)
                }
                
            case "disputed_reason":
                if (value as? String).isNotNil {
                    self.disputed_reason = (value as! String)
                }
                
            case "customer_codeurl":
                if (value as? String).isNotNil {
                    self.customer_codeurl = (value as! String)
                }
                
            case "client_location":
                if (value as? String).isNotNil {
                    self.client_location = (value as! String)
                }
                
            case "batch_id":
                if (value as? String).isNotNil {
                    self.batch_id = (value as! String)
                }

            case "status":
                if (value as? String).isNotNil {
                    self.status = (value as! String)
                }

            case "description":
                if (value as? String).isNotNil {
                    self.description = (value as! String)
                }

            case "redeemedby":
                if (value as? String).isNotNil {
                    self.redeemedby = (value as! String)
                }
                
            case "redeemed":
                if (value as? Int).isNotNil {
                    self.redeemed = (value as! Int)
                }
                
            case "disputedby":
                if (value as? String).isNotNil {
                    self.disputedby = (value as! String)
                }
                
            case "disputed":
                if (value as? Int).isNotNil {
                    self.disputed = (value as! Int)
                }

            case "cashedoutby":
                if (value as? String).isNotNil {
                    self.cashedoutby = (value as! String)
                }
                
            case "cashedout":
                if (value as? Int).isNotNil {
                    self.cashedout = (value as! Int)
                }
               
            case "cashedout_note":
                if (value as? String).isNotNil {
                    self.cashedout_note = (value as! String)
                }
            case "cashedout_total":
                if (value as? Double).isNotNil {
                    self.cashedout_total = (value as! Double)
                }

            case "archivedby":
                if (value as? String).isNotNil {
                    self.archivedby = (value as! String)
                }
                
            case "archived":
                if (value as? Int).isNotNil {
                    self.archived = (value as! Int)
                }

            case "modifiedby":
                if (value as? String).isNotNil {
                    self.modifiedby = (value as! String)
                }
                
            case "modified":
                if (value as? Int).isNotNil {
                    self.modified = (value as! Int)
                }

            case "createdby":
                if (value as? String).isNotNil {
                    self.createdby = (value as! String)
                }
                
            case "created":
                if (value as? Int).isNotNil {
                    self.created = (value as! Int)
                }

            case "deletedby":
                if (value as? String).isNotNil {
                    self.deletedby = (value as! String)
                }
                
            case "deleted":
                if (value as? Int).isNotNil {
                    self.deleted = (value as! Int)
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
        
        if self.archived.isNotNil {
            dictionary.codeTransactionHistoryDic.archived = self.archived
        }
        
        if self.disputed_reason.isNotNil {
            dictionary.codeTransactionDic.disputedReason = self.disputed_reason
        }
        
        if self.cashedoutby.isNotNil {
            dictionary.codeTransactionHistoryDic.cashedoutBy = self.cashedoutby
        }

        if self.cashedout.isNotNil {
            dictionary.codeTransactionHistoryDic.cashedout = self.cashedout
        }
        
        if self.deleted_reason.isNotNil {
            dictionary.codeTransactionHistoryDic.deletedReason = self.deleted_reason
        }
        
        if self.archivedby.isNotNil {
            dictionary.codeTransactionHistoryDic.archivedBy = self.archivedby
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

        if self.status.isNotNil {
            dictionary.codeTransactionHistoryDic.status = self.status
        }

        if self.client_location.isNotNil {
            dictionary.codeTransactionHistoryDic.clientLocation = self.client_location
        }
        
        if self.customer_code.isNotNil {
            dictionary.codeTransactionHistoryDic.customerCode = self.customer_code
        }
        
        if self.customer_codeurl.isNotNil {
            dictionary.codeTransactionHistoryDic.customerCodeURL = self.customer_codeurl
        }
        
        if self.amount.isNotNil {
            dictionary.codeTransactionDic.amount = self.amount
        }

        if self.amount_available.isNotNil {
            dictionary.codeTransactionDic.amountAvailable = self.amount_available
        }

        if self.total_amount.isNotNil {
            dictionary.codeTransactionDic.totalAmount = self.total_amount
        }

        if self.description.isNotNil {
            dictionary.codeTransactionDic.description = self.description
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
        
        if diff == true, self.disputed_reason != targetItem.disputed_reason {
            diff = false
        }
        
        if diff == true, self.deleted_reason != targetItem.deleted_reason {
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
        
        if diff == true, self.customer_codeurl != targetItem.customer_codeurl {
            diff = false
        }
        
        if diff == true, self.amount != targetItem.amount {
            diff = false
        }

        if diff == true, self.amount_available != targetItem.amount_available {
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

        if diff == true, self.status != targetItem.status {
            diff = false
        }

        if diff == true, self.description != targetItem.description {
            diff = false
        }

        if diff == true, self.terminal_id != targetItem.terminal_id {
            diff = false
        }

        if diff == true, self.cashedout != targetItem.cashedout {
            diff = false
        }
        
        if diff == true, self.cashedoutby != targetItem.cashedoutby {
            diff = false
        }

        if diff == true, self.cashedout_note != targetItem.cashedout_note {
            diff = false
        }
        
        if diff == true, self.cashedout_total != targetItem.cashedout_total {
            diff = false
        }

        return diff
        
    }
    
    func isSample()->Bool {
        
        if self.customer_code.isNil { return false }
        
        return self.customer_code!.contains(string: ".SAMPLE")
    }

}
