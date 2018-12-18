//
//  PRJPictureLocations.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation

struct PRJPictureLocations {
    static let AWSfileURL            = "https://s3.amazonaws.com/<~default dir~>/"
    static let AWSfileURLCapsulePics = "https://s3.amazonaws.com/~default dir~>/capsulepics/"
    static let filesDirectoryPics: String = {
        
        #if os(macOS)
        return "./fileslocal/<~default dir~>"
        #elseif os(Linux)
        return "./files/<~default dir~>"
        #endif
        
    }()
    
    static let filesDirectoryDeletedPics: String = {
        
        #if os(macOS)
        return "./fileslocal/<~default dir~>/deleted"
        #elseif os(Linux)
        return "./files/<~default dir~>/deleted"
        #endif
        
    }()
    
}
