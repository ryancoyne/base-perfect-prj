//
//  Ext.Optional<String>.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation

extension Optional where Wrapped == String {
    var isEmptyOrNil: Bool {
        if self == "nil" {
            return true
        } else {
            return (self ?? "").isEmpty
        }
    }
}
