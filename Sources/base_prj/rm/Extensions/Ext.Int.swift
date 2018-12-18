//
//  Ext.Int.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation

extension Int {
    var dateString : String {
        return RMServiceClass.sharedInstance.dateStampFormatter.string(from: Date(timeIntervalSince1970: Double(exactly: self)!))
    }
    func dateString(format : String) -> String {
        let lastFormat = RMServiceClass.sharedInstance.dateStampFormatter.dateFormat
        RMServiceClass.sharedInstance.dateStampFormatter.dateFormat = format
        let value = RMServiceClass.sharedInstance.dateStampFormatter.string(from: Date(timeIntervalSince1970: Double(exactly: self)!))
        RMServiceClass.sharedInstance.dateStampFormatter.dateFormat = lastFormat
        return value
    }
}
