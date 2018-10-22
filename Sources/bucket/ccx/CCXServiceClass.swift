//
//  CCXServiceClass.swift
//
//  Created by Ryan Coyne on 10/30/17.
//

import Foundation
import PerfectLib
// import SwiftString
import SwiftMoment

final class CCXServiceClass {
    
    private init() {
        Config.runSetup()
        displayTitle = Config.getVal("title", "")
        displaySubTitle = Config.getVal("subtitle","")
        displayLogo = Config.getVal("logo","/assets/images/no-logo.png")
        displayLogoSrcSet = Config.getVal("logosrcset","/assets/images/no-logo.png 1x, /assets/images/no-logo.svg 2x")
        let si = Config.getVal("sysinit", "0")
        systemInit = si.toBool()!
        
    }
    
    let displayTitle: String
    let displaySubTitle: String
    let displayLogo: String
    let displayLogoSrcSet: String
    let systemInit: Bool
    
    static let sharedInstance = CCXServiceClass()
    
    public let dateStampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.gmt
        return formatter
    }()
    
//    public let filesDirectory: String = {
//
//        #if os(macOS)
//            return "./fileslocal"
//        #elseif os(Linux)
//            return "./files"
//        #endif
//
//    }()
    
    func getRandomNum(_ min: Int, _ max: Int) -> Int {
        // make sure the following is in the main.sqift to seed the random number in Lunix
        // #if os(Linux)
        //   srandom(UInt32(time(nil)))
        // #endif
        #if os(Linux)
          return Int(random() % max) + min
        #else
          return Int(arc4random_uniform(UInt32(max)) + UInt32(min))
        #endif
    }
    
    public let filesDirectoryProfilePics: String = {
        
        #if os(macOS)
            return "./fileslocal/profilepics"
        #elseif os(Linux)
            return "./files/profilepics"
        #endif
        
    }()

    //MARK:- Date Support functions
    /**
     convertDateFieldsEPochToDefaultFormatter: This function will return the dictionary with the fields specified
     converted from an Int (epoch) to a String (formatted using the default formatter).  No need to send the audit
     fields in the fields array - that is done for you!
     - parameter: data:[String:Any]
     The dictionary containing the fields and data for the change
     - parameter: fields:[String]
     An optional parameter containing the fields to convert date values.
     */
    static func convertDateFieldsEPochToDefaultFormatter (_ data:[String:Any], _ fields:[String]=[])->[String:Any] {
        
        var returnData = data
        
        var newfields = fields
        newfields.append("created")
        newfields.append("modified")
        
        for field in fields {

            returnData["\(field)"] = returnData["\(field)"].intValue?.dateString
            
        }
        
        
        return returnData
    }
    
    static func getFilename()->String {
        
        // name the new file
        var newfilename = UUID().uuidString
        // since we are using the UUID function there is a ~~very~~ slim chance of duplicates
        // if it is a duplicate, select another UUID.
        if CCXServiceClass.doesFileExist(filename: newfilename) {
            newfilename = UUID().uuidString
        }
        
        return newfilename
    }
    
    static func doesFileExist(filename: String) -> Bool {
        
        var filefound = false
        
        // if the directories are not there, then well - it can't work
        if EnvironmentVariables.sharedInstance.filesDirectory == nil {
            return false
        }
        
        // does it exist?
        var context = ["files":[[String:String]]()]
        let d = Dir(EnvironmentVariables.sharedInstance.filesDirectory!)
        
        // if the directory does not exist, create it....
        CCXServiceClass.doesDirectoryExist(d)
        
        do {
            try d.forEachEntry(closure: {
                f in
                
                if f.lowercased() == filename.lowercased() {
                    filefound = true
                    return
                }
                
                context["files"]?.append(["name":f])
            })
        } catch {
            print("Searching the directory error: \(error)")
        }
        
        // we didn't see the file, or maybe we did?
        return filefound
        
    }


    static func movePicture(picturename: File, todirectory: Dir, newfilename: String = "")-> Bool {
        
        // make sure the directories exist first
        CCXServiceClass.doesDirectoryExist(todirectory)

        let url = URL(fileURLWithPath: picturename.path)

        var thepath = ""
        if newfilename.isEmpty {
            thepath = "\(todirectory.path)\(url.lastPathComponent).\(url.pathExtension)"
        } else {
            thepath = "\(todirectory.path)\(newfilename)"
        }

        print("File name for the file move: \(thepath)")
        
        // now lets do the move....
        do {
            let _ = try picturename.moveTo(path: todirectory.path, overWrite: false)
        } catch {
            // if there was an error - print it and return FALSE
            print("File Move ERROR: \(error.localizedDescription)")
            return false
        }
        
        return true
        
    }
    
    @discardableResult
    static func doesDirectoryExist(_ directory: Dir, create: Bool = true) -> Bool {
        // lets see if it exists (and create it)
        if !directory.exists, create {
            do {
                try directory.create()
                return true
            } catch {
                print("Creating directory error: \(error.localizedDescription)")
                return false
            }
        } else if !directory.exists, !create {
            return false
        }
        
        // the directory exists :)
        return true
        
    }

    public func getNow() -> Int {
        return Int(utc().epoch())
        // return Int(Date().timeIntervalSince1970)
    }
    
    public func getMidnight() -> Int {
        
        let yest  = utc()
        let start = Int(yest.startOf(.Days).epoch())
        return start
    }
    
    public func getYesterday() -> [String:Int] {
        
        let yest  = utc().subtract(1, .Days)
        let start = Int(yest.startOf(.Days).epoch())
        // 86,400 less 1 second
        let end = start + 86399
        return ["start":start,"end":end]
    }
    
    public func getTwoDaysAgo() -> [String:Int] {
        let twodays = utc().subtract(2, .Days)
        let start = Int(twodays.startOf(.Days).epoch())
        // 86,400 less 1 second
        let end = start + 86399
        return ["start":start,"end":end]
    }
    
    public func getLastWeek() -> [String:Int] {
        
        let today = utc()
        var lastweek:Moment
        
        // get the day of the week so we know how many to subtract to get Monday
        // 1-7 with Sunday being 1
        let dayofweek = today.weekday
        switch dayofweek {
        case 1:
            lastweek = today.subtract(6, .Days)
        case 2:
            lastweek = today.subtract(7, .Days)
        case 3:
            lastweek = today.subtract(8, .Days)
        case 4:
            lastweek = today.subtract(9, .Days)
        case 5:
            lastweek = today.subtract(10, .Days)
        case 6:
            lastweek = today.subtract(11, .Days)
        case 7:
            lastweek = today.subtract(12, .Days)
        default:
            // should never occur
            lastweek = today.subtract(7, .Days)
        }
        
        // ok = now lets see what last week at midiight was with the wek starting Monday
        let start = Int(lastweek.startOf(.Days).epoch())
        let end = Int(lastweek.add(7, .Days).endOf(.Days).epoch())
        return ["start":start,"end":end]
    }
    
    public func getSevenDaysAgoMidnight() -> Int {
        let sevendays = utc().subtract(7, .Days)
        return Int(sevendays.startOf(.Days).epoch())
    }
    
    public func getGISFields(locationField: String)->String {
        
        var gisfields = " "
        
        gisfields.append("ST_X(\(locationField)::geometry) as longitude, ST_Y(\(locationField)::geometry) as latitude")
        
        return gisfields
        
    }
    
    public func getGISWhere(locationField: String, longitude: Double, latitude: Double, distance: Double)->String {
        
        var giswhere  = " "
        
        giswhere.append("ST_DWithin(\(locationField), ST_SetSRID(ST_Point(\(longitude), \(latitude)), 4326), \(distance.toMeters)) ")
        
        return giswhere
        
    }
    
    let ResultNone:[String:Any] = ["result":"none"]
    let ResultSuccess:[String:Any] = ["result":"success"]
    let ResultError:[String:Any] = ["result":"error"]
    let ResultFailure:[String:Any] = ["result":"failure"]
    
}
