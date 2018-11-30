//
//  AdminWEB.swift
//  bucket
//
//  Created by Mike Silvers on 11/14/18.
//

import Foundation

import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession
import PerfectMustache

// Handler class
// When referenced in a mustache template, this class will be instantiated to handle the request
// and provide a set of values which will be used to complete the template.
struct AdminWEB {

    struct web {
        // POST request for login
        static var routes : [[String:Any]] {
            return [
//                ["method":"post", "uri":"/admin/stats", "handler":generalStats],
            ]
        }
    
        struct generalStats: MustachePageHandler {
            func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        
                // the basics for the return
                var values = MustacheEvaluationContext.MapType()
                // Grab the WebRequest so we can get information about what was uploaded
                let request = contxt.webRequest

                // Grab the regular form parameters
                let params = request.params()

                // All countries
                var schemas:[String] = []
                
                let db = CodeTransaction()
                let db_s = try? db.sqlRows("SELECT schema_name FROM information_schema.schemata", params: [])
                if let d = db_s, d.count > 0 {
                    for i in d {
                        schemas.append(i.data["schema_name"] as! String)
                    }
                }

                // process the schemas
                for s in schemas {
                    
                    var data:[String:Any] = [:]
                    let sql = "SELECT SUM(amount) AS bucket_total, COUNT(customer_code) AS bucket_count"
                    
                    
                    
                    
                    values[s] = data
                }
                
                contxt.extendValues(with: values)
                do {
                    try contxt.requestCompleted(withCollector: collector)
                } catch {
                    let response = contxt.webResponse
                    response.status = .internalServerError
                    response.appendBody(string: "\(error)")
                    response.completed()
                    return
                }

            }
        }
    }
    
    // all template handlers must inherit from PageHandler
    
    // This is the function which all handlers must impliment.
    // It is called by the system to allow the handler to return the set of values which will be used when populating the template.
    // - parameter context: The MustacheEvaluationContext which provides access to the WebRequest containing all the information pertaining to the request
    // - parameter collector: The MustacheEvaluationOutputCollector which can be used to adjust the template output. For example a `defaultEncodingFunc` could be installed to change how outgoing values are encoded.
    func generalStats(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        #if DEBUG
        print("UploadHandler got request")
        #endif
        var values = MustacheEvaluationContext.MapType()
        // Grab the WebRequest so we can get information about what was uploaded
        let request = contxt.webRequest
        
        // Grab the fileUploads array and see what's there
        // If this POST was not multi-part, then this array will be empty
        
        if let uploads = request.postFileUploads , uploads.count > 0 {
            // Create an array of dictionaries which will show what was uploaded
            // This array will be used in the corresponding mustache template
            var ary = [[String:Any]]()
            
            for upload in uploads {
                ary.append([
                    "fieldName": upload.fieldName,
                    "contentType": upload.contentType,
                    "fileName": upload.fileName,
                    "fileSize": upload.fileSize,
                    "tmpFileName": upload.tmpFileName
                    ])
            }
            values["files"] = ary
            values["count"] = ary.count
        }
        
        // Grab the regular form parameters
        let params = request.params()
        if params.count > 0 {
            // Create an array of dictionaries which will show what was posted
            // This will not include any uploaded files. Those are handled above.
            var ary = [[String:Any]]()
            
            for (name, value) in params {
                ary.append([
                    "paramName":name,
                    "paramValue":value
                    ])
            }
            values["params"] = ary
            values["paramsCount"] = ary.count
        }
        
        values["title"] = "Upload Enumerator"
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
            return
        }
    }
}
