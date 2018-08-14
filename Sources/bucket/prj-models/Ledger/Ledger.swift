//
//  Ledger.swift
//  bucket
//
//  Created by Ryan Coyne on 8/9/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Ledger: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil
    
    var ledger_account_id     : Int? = nil
    var ledger_type_id        : Int? = nil
    var credit                : Double? = nil
    var debit                 : Double? = nil
    var wallet_entry          : Bool? = nil
    var code_country_id       : Int? = nil
    var wallet_bucket_user_id : String? = nil
    var customer_code         : String? = nil
    var blockchain_audit      : String? = nil
    var description           : String? = nil
    
    //MARK: Table name
    override public func table() -> String { return "ledger" }
    
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
        
        if let data = this.data.ledgerDic.ledger_account_id {
            ledger_account_id = data
        }
        
        if let data = this.data.ledgerDic.ledger_type_id {
            ledger_type_id = data
        }
        
        if let data = this.data.ledgerDic.credit {
            credit = data
        }
        
        if let data = this.data.ledgerDic.debit {
            debit = data
        }

        if let data = this.data.ledgerDic.customer_code {
            customer_code = data
        }

        if let data = this.data.ledgerDic.code_country_id {
            code_country_id = data
        }

        if let data = this.data.ledgerDic.wallet_entry {
            wallet_entry = data
        }
        
        if let data = this.data.ledgerDic.wallet_bucket_user_id {
            wallet_bucket_user_id = data
        }

        if let data = this.data.ledgerDic.blockchain_audit {
            blockchain_audit = data
        }

        if let data = this.data.ledgerDic.description {
            description = data
        }

    }
    
    func rows() -> [Ledger] {
        var rows = [Ledger]()
        for i in 0..<self.results.rows.count {
            let row = Ledger()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
            
            case "ledger_account_id":
                if (value as? Int).isNotNil {
                    self.ledger_account_id = (value as! Int)
                }

            case "ledger_type_id":
                if (value as? Int).isNotNil {
                    self.ledger_type_id = (value as! Int)
                }
                
            case "credit":
                if (value as? Double).isNotNil {
                    self.credit = (value as! Double)
                }
                
            case "debit":
                if (value as? Double).isNotNil {
                    self.debit = (value as! Double)
                }
                
            case "customer_code":
                if (value as? String).isNotNil {
                    self.customer_code = (value as! String)
                }

            case "wallet_entry":
                if (value as? Bool).isNotNil {
                    self.wallet_entry = (value as! Bool)
                }

            case "code_country_id":
                if (value as? Int).isNotNil {
                    self.code_country_id = (value as! Int)
                }

            case "wallet_bucket_user_id":
                if (value as? String).isNotNil {
                    self.wallet_bucket_user_id = (value as! String)
                }

            case "blockchain_audit":
                if (value as? String).isNotNil {
                    self.blockchain_audit = (value as! String)
                }
                
            case "description":
                if (value as? String).isNotNil {
                    self.description = (value as! String)
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
        
        if self.ledger_account_id.isNotNil {
            dictionary.ledgerDic.ledger_account_id = self.ledger_account_id
        }

        if self.ledger_type_id.isNotNil {
            dictionary.ledgerDic.ledger_type_id = self.ledger_type_id
        }

        if self.credit.isNotNil {
            dictionary.ledgerDic.credit = self.credit
        }

        if self.debit.isNotNil {
            dictionary.ledgerDic.debit = self.debit
        }

        if self.customer_code.isNotNil {
            dictionary.ledgerDic.customer_code = self.customer_code
        }

        if self.code_country_id.isNotNil {
            dictionary.ledgerDic.code_country_id = self.code_country_id
        }

        if self.wallet_entry.isNotNil {
            dictionary.ledgerDic.wallet_entry = self.wallet_entry
        }

        if self.wallet_bucket_user_id.isNotNil {
            dictionary.ledgerDic.wallet_bucket_user_id = self.wallet_bucket_user_id
        }

        if self.blockchain_audit.isNotNil {
            dictionary.ledgerDic.blockchain_audit = self.blockchain_audit
        }
        
        if self.description.isNotNil {
            dictionary.ledgerDic.description = self.description
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: Ledger)-> Bool {
        
        var diff = true
        
        if diff == true, self.ledger_account_id != targetItem.ledger_account_id {
            diff = false
        }
        
        if diff == true, self.ledger_type_id != targetItem.ledger_type_id {
            diff = false
        }

        if diff == true, self.credit != targetItem.credit {
            diff = false
        }
        
        if diff == true, self.debit != targetItem.debit {
            diff = false
        }
        
        if diff == true, self.customer_code != targetItem.customer_code {
            diff = false
        }

        if diff == true, self.code_country_id != targetItem.code_country_id {
            diff = false
        }

        if diff == true, self.wallet_bucket_user_id != targetItem.wallet_bucket_user_id {
            diff = false
        }
        
        if diff == true, self.wallet_entry != targetItem.wallet_entry {
            diff = false
        }
        
        if diff == true, self.blockchain_audit != targetItem.blockchain_audit {
            diff = false
        }
        

        if diff == true, self.description != targetItem.description {
            diff = false
        }
        
        return diff
        
    }
}
