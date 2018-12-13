//
//  Ext.Moment.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation
import SwiftMoment

extension Moment {
    init(epoch: Int) {
        let timeInt = TimeInterval(exactly: epoch)!
        let date = Date(timeIntervalSince1970: timeInt)
        self = moment(date)
    }
}
