//
//  Retailer.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM

public class Retailer: PostgresStORM {
    
    // NOTE: First param in class should be the ID.
    var id         : Int?    = nil
    var created    : Int?    = nil
    var createdby  : String? = nil
    var modified   : Int?    = nil
    var modifiedby : String? = nil
    var deleted    : Int?    = nil
    var deletedby  : String? = nil

    var retailer_code : String? = nil
    var name     : String? = nil
    var is_suspended     : Bool? = nil
    var is_verified     : Bool? = nil
    var send_settlement_confirmation     : Bool? = nil
    var ach_transfer_minimum_default : Double? = nil
    
    //MARK: Table name
    override public func table() -> String { return "retailer" }
    
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
        
        if let data = this.data.retailerDic.name {
            name = data
        }
        
        if let data = this.data.retailerDic.retailerCode {
            retailer_code = data
        }
        
        if let data = this.data.retailerDic.isVerified {
            is_verified = data
        }
        
        if let data = this.data.retailerDic.isSuspended {
            is_suspended = data
        }
    
        if let data = this.data.retailerDic.sendSettlementConfirmation {
            send_settlement_confirmation = data
        }
        
        if let data = this.data.retailerDic.ach_transfer_minimum_default {
            ach_transfer_minimum_default = data
        }
        
        
    }
    
    func rows() -> [Retailer] {
        var rows = [Retailer]()
        for i in 0..<self.results.rows.count {
            let row = Retailer()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func fromDictionary(sourceDictionary: [String:Any]) {
        
        for (key, value) in sourceDictionary {
            
            switch key.lowercased() {
            
            case "name":
                if (value as? String).isNotNil {
                    self.name = (value as! String)
                }
                
            case "retailer_code":
                if (value as? String).isNotNil {
                    self.retailer_code = (value as! String)
                }
                
            case "is_suspended":
                if (value as? Bool).isNotNil {
                    self.is_suspended = (value as! Bool)
                }
                
            case "is_approved":
                if (value as? Bool).isNotNil {
                    self.is_verified = (value as! Bool)
                }

            case "ach_transfer_minimum_default":
                if (value as? Decimal).isNotNil {
                    self.ach_transfer_minimum_default = (value as! Double)
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
        
        if self.name.isNotNil {
            dictionary.retailerDic.name = self.name
        }
        
        if self.retailer_code.isNotNil {
            dictionary.retailerDic.retailerCode = self.retailer_code
        }
        
        if self.is_suspended.isNotNil {
            dictionary.retailerDic.isSuspended = self.is_suspended
        }
        
        if self.is_verified.isNotNil {
            dictionary.retailerDic.isVerified = self.is_verified
        }
        
        if self.ach_transfer_minimum_default.isNotNil {
            dictionary.retailerDic.ach_transfer_minimum_default = self.ach_transfer_minimum_default
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: Retailer)-> Bool {
        
        var diff = true
        
        if diff == true, self.retailer_code != targetItem.retailer_code {
            diff = false
        }
        
        if diff == true, self.name != targetItem.name {
            diff = false
        }
        
        if diff == true, self.is_verified != targetItem.is_verified {
            diff = false
        }
        
        if diff == true, self.is_suspended != targetItem.is_suspended {
            diff = false
        }
        
        if diff == true, self.send_settlement_confirmation != targetItem.send_settlement_confirmation {
            diff = false
        }

        if diff == true, self.ach_transfer_minimum_default != targetItem.ach_transfer_minimum_default {
            diff = false
        }

        return diff
        
    }
    
    //MARK: Function to create Customer Codes
    func createCustomerCode(schemaId:String? = "public", _ data: [String:Any])->(success:Bool, message:String) {
        
        let schema = schemaId!.lowercased()
        
        // lets make sure the correct parameters were passed in..
        
        let customerCode = self.createCustomerCodeRaw(schema)
        
        // Make sure a transaction does not exist with this customer code already:
        let trans = CodeTransaction()
        let sql = "SELECT * FROM \(schema).code_transaction WHERE customer_code = '\(customerCode)'"
        let tran = try? trans.sqlRows(sql, params: [])
        if let t = tran?.first {
            trans.to(t)
        }
        
        if trans.id.isNotNil {
            
            return (false, "Code exists and was not redeemed")
            
        } else {

            // check the code history to make sure it was not redeemed.
            let ctrs = CodeTransactionHistory()
            let sql = "SELECT * FROM \(schema).code_transaction WHERE customer_code = '\(customerCode)'"
            let tran = try? ctrs.sqlRows(sql, params: [])
            if let t = tran?.first {
                ctrs.to(t)
            }

            if ctrs.created! > 0 {
                return (false, "Code exists and was redeemed")
            }
            
            
            return (true, customerCode)
        }
    }
    
    fileprivate func createCustomerCodeRaw (_ schemaId:String) -> String {
        
        let schema = schemaId.lowercased()
        
        var returnCC = ""
        
        let customerCode64 = ([UInt8](randomCount: 128).encode(.base64))
        let customerCode = String(validatingUTF8: customerCode64!)
//        print("Customer Code Created: \(String(describing: customerCode))")
        
        if customerCode.isNil {
            return ""
        }
        
        for i in customerCode!.unicodeScalars {
            
            if i.isAlphaNum() {
                returnCC.append(i.escaped(asASCII: true))
                
                // we want this as a length of 12 alphanumeric characters
                if returnCC.length > 12 {
//                    print("  This is the final CC: \(returnCC)")
                    return returnCC
                }
            }
            
        }
        
        // add on the schema name
        let retCC = "\(schema).\(returnCC)"
        return retCC
        
    }
}
