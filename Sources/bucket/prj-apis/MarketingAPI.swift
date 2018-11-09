//
//  MarketingAPI.swift
//  bucket
//
//  Created by Ryan Coyne on 10/23/18.
//

import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession

struct MarketingAPI {
    struct json {
        static var routes : [[String:Any]] {
            return [
                ["method":"put",   "uri":"/marketing/api/v1/transaction", "handler":createTransaction],
                ["method":"delete",   "uri":"/marketing/api/v1/transaction/{customerCode}", "handler":deleteTransaction],
                ["method":"post",   "uri":"/marketing/api/v1/currentReport", "handler":currentReport],
                ["method":"post",   "uri":"/marketing/api/v1/currentReport/export", "handler":currentReportExport],
                ["method":"post",   "uri":"/marketing/api/v1/historyReport", "handler":historyReport],
                ["method":"post",   "uri":"/marketing/api/v1/historyReport/export", "handler":historyReportExport],
            ]
        }
        
        
        public static func createTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                
                
            }
        }
        
        public static func deleteTransaction(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                
                
            }
        }
        
        public static func currentReport(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                
                
            }
        }
        
        public static func currentReportExport(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                
                
            }
        }
        
        public static func historyReport(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                
                
            }
        }
        
        public static func historyReportExport(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                
                
            }
        }
            
    }
}
