//
//  Ext.Optional.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation

extension Optional {
    var isNil : Bool {
        return self == nil
    }
    var isNotNil : Bool {
        return self != nil
    }
    var boolValue : Bool? {
        if self is String {
            return Bool(self as! String)
        }
        return self as? Bool
    }
    // Going to use this for the Optional<Any> date fields from our dictionary :)
    var stringValue : String? {
        if self.isNil { return nil }
        switch self {
        case is Int?, is Int:
            return String(self as! Int)
        default:
            return self as? String
        }
    }
    var dicValue : [String:Any]! {
        get {
            return self as? [String:Any] ?? [:]
        }
        set {
            
        }
    }
    var arrayDicValue : [[String:Any]]! {
        return self as? [[String:Any]] ?? [[:]]
    }
    var intValue : Int? {
        if self == nil {
            return nil
        }
        switch self {
        case is Double, is Double?:
            return Int(self as! Double)
        case is Float, is Float?:
            return Int(self as! Float)
        case is Int, is Int?:
            return self as? Int
        case is String, is String?:
            return Int(self as! String)
        default:
            return nil
        }
    }
    var doubleValue : Double? {
        if self == nil {
            return nil
        }
        switch self {
        case is Int, is Int?:
            return Double(exactly: self as! Int)
        case is Float, is Float?:
            return Double(exactly: self as! Float)
        case is Double, is Double?:
            return self as? Double
        case is String, is String?:
            return Double(self as! String)
        default:
            return nil
        }
    }
    var floatValue : Float? {
        return self as? Float
    }
}
