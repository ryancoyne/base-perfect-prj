//
//  TestingAPI.swift
//  bucket
//
//  Created by Mike Silvers on 8/13/18.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession
import SwiftMoment

//MARK: - Retailer API
/// This Retailer structure supports all the normal endpoints for a user based login application.
struct TestingAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [
                ["method":"post",    "uri":"/api/v1/testingProcess", "handler":testFunction]
            ]
        }
        //MARK: - Close Interval Function
        public static func testFunction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                // make sure we are NOT in production
                if EnvironmentVariables.sharedInstance.Server!.rawValue == "PROD" {
                    let _ = try? response.setBody(json: " { \"error\": \"This function is not on\" } ")
                    return response.completed(status: .internalServerError)
                }
                
                
                // SET TESTING STUFF HERE:
                
                // testing the archiving process
                // grab 5 records from code_transaction
                var thecount = 0
                let t = CodeTransaction()
                try? t.findAll()
                for i in t.rows() {
                    thecount += 1
                    if thecount > 5 {
                        break
                    }
                    // archive the records
                    i.archiveRecord()
                }
                
                response.setBody(string: "Completed testing.")
                return response.completed(status: .ok)
                
            }
        }
    }
}
