//
//  Ext.String.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation

//MARK: - String Extensions:
extension String {
    var sanitized : String {
        return self.replacingOccurrences(of: "'", with: "''")
    }
    
    var ourPasswordHash : String? {
        guard let hexBytes = self.digest(.sha256), let validate = hexBytes.encode(.hex), let theHashedPassword = String(validatingUTF8: validate)  else { return nil }
        return theHashedPassword
    }
    
    func chompLeft(_ prefix: String) -> String {
        if let prefixRange = range(of: prefix) {
            if prefixRange.upperBound >= endIndex {
                return String(self[startIndex..<prefixRange.lowerBound])
            } else {
                return String(self[prefixRange.upperBound..<endIndex])
            }
        }
        return self
    }
    
    func chompRight(_ suffix: String) -> String {
        if let suffixRange = range(of: suffix, options: .backwards) {
            if suffixRange.upperBound >= endIndex {
                return String(self[startIndex..<suffixRange.lowerBound])
            } else {
                return String(self[suffixRange.upperBound..<endIndex])
            }
        }
        return self
    }
    
    func toBool() -> Bool? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if Int(trimmed) != 0 {
            return true
        }
        switch trimmed {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return false
        }
    }
}
