//
//  PRJDBTables.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation
import PerfectLib

final class PRJDBTables {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
        
    }
    
    static let sharedInstance = PRJDBTables()
    
    //MARK: - File Support Functions:
    static func getFilenamePRJ()->String {
        
        // name the new file
        var newfilename = UUID().uuidString
        // since we are using the UUID function there is a ~~very~~ slim chance of duplicates
        // if it is a duplicate, select another UUID.
        if PRJDBTables.doesFileExistPRJPics(filename: newfilename) {
            newfilename = UUID().uuidString
        }
        
        return newfilename
    }
    
    static func doesFileExistPRJPics(filename: String) -> Bool {
        
        var filefound = false
        
        // does it exist?
        var context = ["files":[[String:String]]()]
        let d = Dir(PRJPictureLocations.filesDirectoryPics)
        
        // if the directory does not exist, create it....
        RMServiceClass.doesDirectoryExist(d)
        
        // and look for the filename
        do{
            try d.forEachEntry(closure: {
                f in
                
                if f.lowercased() == filename.lowercased() {
                    filefound = true
                    return
                }
                
                context["files"]?.append(["name":f])
            })
        } catch {
            print("Checking directory for file error: \(error.localizedDescription)")
        }
        
        // we didn't see the file, or maybe we did?
        return filefound
        
    }
    
    //MARK:-
    //MARK: Add schema
    public func addSchema(_ schemaName: String, _ userName: String? = PRJDBTableDefaults.databaseUser) -> String {
        
        let sql = "CREATE SCHEMA IF NOT EXISTS \(schemaName.lowercased()) AUTHORIZATION \(userName!)"
        
        return sql
        
    }
}
