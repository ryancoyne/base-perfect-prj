//
//  Transaction.swift
//  bucket
//
//  Created by Ryan Coyne on 8/8/18.
//

import Foundation
import PerfectHTTP
import StORM
import PostgresStORM
import PerfectLocalAuthentication

struct CodeTransactionCodes {
    static let completed                = "completed" // the code has been complete
    static let cashout_pending          = "cashout pending" // external services to be contacted
    static let merchant_pending         = "merchant pending" // external services to be contacted
    static let partial_cashout_pending  = "partial cashout pending" // partial amount cashed out
    static let partial_cashout_complete = "partial cashout complete" // partial amount cashed out
}

public class CodeTransaction: PostgresStORM {
    
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

    var processed    : Int?    = nil
    var processedby  : String? = nil
    
    var retailer_id     : Int? = nil
    var country_id     : Int? = nil
    var event_id     : Int? = nil
    var customer_code     : String? = nil
    var deleted_reason     : String? = nil
    var disputed_reason     : String? = nil
    var customer_codeurl     : String? = nil
    var terminal_id : Int? = nil
    var retailer_user_id : Int? = nil
    var client_location : String? = nil
    var client_transaction_id     : String? = nil
    var batch_id : String? = nil
    var amount : Double? = nil
    var amount_available : Double? = nil
    var total_amount : Double? = nil
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
    override public func table() -> String { return "code_transaction" }
    
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

        if let data = this.data.codeTransactionDic.cashedoutBy {
            cashedoutby = data
        }

        if let data = this.data.codeTransactionDic.deletedReason {
            deleted_reason = data
        }
        
        if let data = this.data.codeTransactionDic.disputedReason {
            disputed_reason = data
        }
        
        if let data = this.data.codeTransactionDic.cashedout {
            cashedout = data
        }

        if let data = this.data.codeTransactionDic.cashedoutNote {
            cashedout_note = data
        }
        if let data = this.data.codeTransactionDic.cashedoutTotal.doubleValue {
            cashedout_total = data
        }

        if let data = this.data.codeTransactionDic.archived.intValue {
            archived = data
        }
        
        if let data = this.data.codeTransactionDic.archivedBy {
            archivedby = data
        }

        if let data = this.data.codeTransactionDic.processed.intValue {
            processed = data
        }
        
        if let data = this.data.codeTransactionDic.eventId {
            event_id = data
        }
        
        if let data = this.data.codeTransactionDic.processedBy {
            processedby = data
        }
        
        if let data = this.data.codeTransactionDic.countryId {
            country_id = data
        }
        
        if let data = this.data.codeTransactionDic.retailerId {
            retailer_id = data
        }
        
        if let data = this.data.codeTransactionDic.batchId {
            batch_id = data
        }
        
        if let data = this.data.codeTransactionDic.clientLocation {
            client_location = data
        }
        
        if let data = this.data.codeTransactionDic.clientTransactionId {
            client_transaction_id = data
        }
        
        if let data = this.data.codeTransactionDic.retailerUserId {
            retailer_user_id = data
        }
        
        if let data = this.data.codeTransactionDic.customerCode {
            customer_code = data
        }
        
        if let data = this.data.codeTransactionDic.customerCodeURL {
            customer_codeurl = data
        }
        
        if let data = this.data.codeTransactionDic.redeemed {
            redeemed = data
        }
        
        if let data = this.data.codeTransactionDic.redeemedBy {
            redeemedby = data
        }
        
        if let data = this.data.codeTransactionDic.disputedBy {
            disputedby = data
        }
        
        if let data = this.data.codeTransactionDic.disputed {
            disputed = data
        }
        
        if let data = this.data.codeTransactionDic.terminalId {
            terminal_id = data
        }
        
        if let data = this.data.codeTransactionDic.amount.doubleValue {
            amount = data
        }

        if let data = this.data.codeTransactionDic.amountAvailable.doubleValue {
            amount_available = data
        }

        if let data = this.data.codeTransactionDic.totalAmount.doubleValue {
            total_amount = data
        }

        if let data = this.data.codeTransactionDic.status.stringValue {
            status = data
        }
        
        if let data = this.data.codeTransactionDic.description.stringValue {
            description = data
        }

    }
    
    func rows() -> [CodeTransaction] {
        var rows = [CodeTransaction]()
        for i in 0..<self.results.rows.count {
            let row = CodeTransaction()
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
                
            case "event_id":
                if (value as? Int).isNotNil {
                    self.event_id = (value as! Int)
                }
                
            case "retailer_user_id":
                if (value as? Int).isNotNil {
                    self.retailer_user_id = (value as! Int)
                }
            
            case "terminal_id":
                if (value as? Int).isNotNil {
                    self.retailer_id = (value as! Int)
                }
            
            case "amount":
                if (value as? Double).isNotNil {
                    self.amount = (value as! Double)
                }

            case "amount_available":
                if (value as? Double).isNotNil {
                    self.amount_available = (value as! Double)
                }

            case "total_amount":
                if (value as? Double).isNotNil {
                    self.total_amount = (value as! Double)
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
                
            case "client_transaction_id":
                if (value as? String).isNotNil {
                    self.client_transaction_id = (value as! String)
                }
                
            case "batch_id":
                if (value as? String).isNotNil {
                    self.batch_id = (value as! String)
                }
                
            case "status":
                if (value as? String).isNotNil {
                    self.status = (value as! String)
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
                
            case "processedby":
                if (value as? String).isNotNil {
                    self.processedby = (value as! String)
                }
                
            case "processed":
                if (value as? Int).isNotNil {
                    self.processed = (value as! Int)
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
        
        if self.archived.isNotNil {
            dictionary.codeTransactionDic.archived = self.archived
        }
        
        if self.event_id.isNotNil {
            dictionary.codeTransactionDic.eventId = self.event_id
        }
        
        if self.retailer_user_id.isNotNil {
            dictionary.codeTransactionDic.retailerUserId = self.retailer_user_id
        }
        
        if self.archivedby.isNotNil {
            dictionary.codeTransactionDic.archivedBy = self.archivedby
        }
        
        if self.processed.isNotNil {
            dictionary.codeTransactionDic.processed = self.processed
        }
        
        if self.processedby.isNotNil {
            dictionary.codeTransactionDic.processedBy = self.processedby
        }
        
        if self.disputed_reason.isNotNil {
            dictionary.codeTransactionDic.disputedReason = self.disputed_reason
        }

        if self.cashedout.isNotNil {
            dictionary.codeTransactionDic.cashedout = self.cashedout
        }
        
        if self.deleted_reason.isNotNil {
            dictionary.codeTransactionDic.deletedReason = self.deleted_reason
        }
        
        if self.cashedoutby.isNotNil {
            dictionary.codeTransactionDic.cashedoutBy = self.cashedoutby
        }
        
        if self.cashedout_note.isNotNil {
            dictionary.codeTransactionDic.cashedoutNote = self.cashedout_note
        }
        
        if self.cashedout_total.isNotNil {
            dictionary.codeTransactionDic.cashedoutTotal = self.cashedout_total
        }
        
        if self.country_id.isNotNil {
            dictionary.codeTransactionDic.countryId = self.country_id
        }
        
        if self.retailer_id.isNotNil {
            dictionary.codeTransactionDic.retailerId = self.retailer_id
        }
        
        if self.redeemedby.isNotNil {
            dictionary.codeTransactionDic.redeemedBy = self.redeemedby
        }
        
        if self.redeemed.isNotNil {
            dictionary.codeTransactionDic.redeemed = self.redeemed
        }
        
        if self.disputedby.isNotNil {
            dictionary.codeTransactionDic.disputedBy = self.disputedby
        }
        
        if self.disputed.isNotNil {
            dictionary.codeTransactionDic.disputed = self.disputed
        }
        
        if self.batch_id.isNotNil {
            dictionary.codeTransactionDic.batchId = self.batch_id
        }

        if self.status.isNotNil {
            dictionary.codeTransactionDic.status = self.status
        }

        if self.client_location.isNotNil {
            dictionary.codeTransactionDic.clientLocation = self.client_location
        }
        
        if self.client_transaction_id.isNotNil {
            dictionary.codeTransactionDic.clientTransactionId = self.client_transaction_id
        }
        
        if self.customer_code.isNotNil {
            dictionary.codeTransactionDic.customerCode = self.customer_code
        }
        
        if self.customer_codeurl.isNotNil {
            dictionary.codeTransactionDic.customerCodeURL = self.customer_codeurl
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
        
        if self.terminal_id.isNotNil {
            dictionary.codeTransactionDic.terminalId = self.terminal_id
        }
        
        if self.batch_id.isNotNil {
            dictionary.codeTransactionDic.batchId = self.batch_id
        }
        
        if self.client_transaction_id.isNotNil  {
            dictionary.codeTransactionDic.clientTransactionId = self.client_transaction_id
        }
        
        if self.customer_codeurl.isNotNil {
            dictionary.codeTransactionDic.customerCodeURL = self.customer_codeurl
        }
        
        if self.description.isNotNil {
            dictionary.codeTransactionDic.description = self.description
        }
        
        return dictionary
    }
    
    // true if they are the same, false if the target item is different than the core item
    func compare(targetItem: CodeTransaction)-> Bool {
        
        var diff = true
        
        if diff == true, self.retailer_id != targetItem.retailer_id {
            diff = false
        }
        
        if diff == true, self.client_location != targetItem.client_location {
            diff = false
        }
        
        if diff == true, self.event_id != targetItem.event_id {
            diff = false
        }
        
        if diff == true, self.retailer_user_id != targetItem.retailer_user_id {
            diff = false
        }
        
        if diff == true, self.disputed_reason != targetItem.disputed_reason {
            diff = false
        }
        
        if diff == true, self.client_transaction_id != targetItem.client_transaction_id {
            diff = false
        }
        
        if diff == true, self.country_id != targetItem.country_id {
            diff = false
        }
        
        if diff == true, self.deleted_reason != targetItem.deleted_reason {
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
        
        if diff == true, self.description != targetItem.description {
            diff = false
        }

        return diff
        
    }
    
    /**
     This function will move the record to the archive table
    */
    func archiveRecord(_ archiveUserId: String? = nil) {
        
        let cth = CodeTransactionHistory()
        
        // save the main stuff
        var recdict = self.asDictionary()
        recdict["id"] = nil

        // add in the core info
        cth.fromDictionary(sourceDictionary: recdict)

        // add the base audit information
        cth.created     = self.created
        cth.createdby   = self.createdby
        cth.modified    = self.modified
        cth.modifiedby  = self.modifiedby
        cth.deleted     = self.deleted
        cth.deletedby   = self.deletedby

        // add the archive audit info
        cth.archived = CCXServiceClass.getNow()
        if archiveUserId.isNil {
            cth.archivedby = CCXDefaultUserValues.user_server
        } else {
            cth.archivedby = archiveUserId
        }
        
        // and finally set the original code transaction id
        cth.id = self.id
        
        // now save the record
        do {
            
            var schema = ""
            
            // determine the schema (country)
            let schemaRow = try? cth.sqlRows("SELECT code_alpha_2 FROM public.country WHERE id = $1", params: ["\(cth.country_id!)"])
            if let r = schemaRow?.first {
                schema = (r.data["code_alpha_2"].stringValue!).lowercased()
            }
                
            // save the archive record - we are doing the copy over option to insert (we have an ID in the record object)
            // see if the record exists - if so it is anb iupdate, if not, it is a copyover
            if cth.id.isNotNil, cth.id! > 0 {
                let sql_check = "SELECT * FROM \(schema).code_transaction_history WHERE id = \(cth.id!)"
                let chk = try? cth.sqlRows(sql_check, params: [])
                if let _ = chk?.first {
                    // this means that there is a record out there already - update the record
                    let oldrec = CodeTransactionHistory()
                    oldrec.to(chk!.first!)
                    // let us know what is going on though:
                    if oldrec.id.isNotNil {
                        var email_text = "There was already a record for \(schema).code_transaction_history with id = \(oldrec.id!)\n"
                        email_text.append("OLD RECORD:\n")
                        if let jsond = try? oldrec.asDictionary().jsonEncodedString() {
                            email_text.append(jsond)
                        }
                        email_text.append("\nNEW RECORD:\n")
                        if let jsond = try? cth.asDictionary().jsonEncodedString() {
                            email_text.append(jsond)
                        }
                        // now lets send the information
                        Utility.sendMail(name: "Bucket Server Problem", address: "engineering@buckettechnologies.com", subject: "Issue with the archive of code transaction history", html: email_text, text: email_text)
                    }
                    try cth.saveWithCustomType(schemaIn: schema, self.modifiedby)
                } else {
                    // this means that there is no record out there - add the new record with the current id
                    try cth.saveWithCustomType(schemaIn: schema, self.modifiedby, true)
                }
            } else {
                try cth.saveWithCustomType(schemaIn: schema, self.modifiedby, true)
            }

            // now hard delete the original record
            let sql = "DELETE FROM \(schema).\(self.table()) WHERE id = \(self.id!)"
            let _ = try? self.sqlRows(sql, params: [])
            
        } catch {
            // do nothing with errors
            print("There was an error on the archive.  Main record id: \(String(describing: self.id))  The error is \(error.localizedDescription)")
        }
    }
    
    @discardableResult
    static func qrCodeCreate(schema : String, session:String, user : String, terminal : Terminal, increment : Int, minimum : Double?) -> CodeTransaction? {
        
        var minimum_amount = 0.0
        if minimum.isNotNil { minimum_amount = minimum! }
        
        let ccode = Retailer().createCustomerCode(schemaId: schema,[:])
        
        if ccode.success {
            
            var qrCodeURL = ""
            qrCodeURL.append(EnvironmentVariables.sharedInstance.PublicServerApiURL?.absoluteString ?? "")
            qrCodeURL.append("redeem/")
            qrCodeURL.append(ccode.message)
            
            // lets get the co\untry id for this transaction
            let add = Address()
            let sqla = "SELECT * FROM \(schema).address WHERE id = '\(terminal.address_id!)'"
            let adda = try? add.sqlRows(sqla, params: [])
            if let a = adda?.first {
                add.to(a)
            }
            
            // make sure the random amount is greater than the minimum passed in
            var bucket_amount:Double = 0.0
            while bucket_amount <= minimum_amount {
                bucket_amount = drand48()
                bucket_amount = Double(round(bucket_amount * 100) / 100)
            }
            
            //let total_trans = arc4random_uniform(10)
            let total_trans = 2.5
            
            let total_trans_dbl = Double(round(Double(total_trans) * 100) / 100)
            
            let transaction = CodeTransaction()
            transaction.created = CCXServiceClass.getNow() + increment
            transaction.amount = bucket_amount
            transaction.amount_available = bucket_amount
            transaction.total_amount = (1 - bucket_amount) + total_trans_dbl + 1
            transaction.client_location = "TESTING_\(user)_\(increment)"
            transaction.client_transaction_id = "TESTING_\(user)_\(increment)"
            transaction.terminal_id = terminal.id
            transaction.retailer_id = terminal.retailer_id
            transaction.customer_code = ccode.message
            transaction.customer_codeurl = qrCodeURL
            if let cc = add.country_id {
                transaction.country_id = cc
            }
            
            // Save the transaction
            let _ = try? transaction.saveWithCustomType(schemaIn: schema, CCXDefaultUserValues.user_server)
            
            // audit the record creation
            let rd = transaction.asDictionary()
            AuditRecordActions.customerCodeAdd(schema: schema,
                                               session_id: session,
                                               row_data: rd,
                                               changed_fields: nil,
                                               description: "Added customer code \(transaction.customer_code!).",
                                               changedby: "\(transaction.createdby!)")

            // and now - lets save the transaction in the Audit table
            AuditFunctions().addCustomerCodeAuditRecord(transaction)
            
            return transaction
            
        }
        
        return nil
    }
    
    func isSample()->Bool {

        if self.customer_code.isNil { return false }

        return self.customer_code!.contains(string: ".SAMPLE")
    }
    
}
