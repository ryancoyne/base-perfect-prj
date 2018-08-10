
//
//  PRJExtensions.swift
//  bucket
//
//  Created by Ryan Coyne on 8/10/18.
//

import PerfectHTTP

enum BucketAPIError: Error {
    case unparceableJSON(String)
}

extension HTTPRequest {
    func postBodyJSON() throws -> [String:Any]? {
        if let json = try? self.postBodyString?.jsonDecode() as? [String:Any], json.isNotNil {
            return json
        } else if let str = self.postBodyString {
            throw BucketAPIError.unparceableJSON(str)
        } else {
            return nil
        }
    }
}

