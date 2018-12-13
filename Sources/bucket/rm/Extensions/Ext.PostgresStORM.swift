//
//  Ext.PostgresStORM.swift
//  bucket
//
//  Created by Ryan Coyne on 12/13/18.
//

import Foundation
import StORM
import PostgresStORM
import SwiftMoment
import PerfectLogger

extension PostgresStORM {
    
    /**
     Saves a record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    @discardableResult
    func saveWithCustomType(schemaIn:String? = "public", _ user: String? = nil,_ insertRecord : Bool? = false) throws -> [StORMRow] {
        
        var copyOver = false
        if insertRecord.isNotNil {
            copyOver = insertRecord!
        }
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        // act accordingly if this is an add or an update
        do {
            if copyOver {
                return try insertWithCustomTypes(schemaIn: schema)
            } else if keyIsEmpty() {
                return try addWithCustomTypes(schemaIn: schema, user)
            } else {
                return try updateWithCustomType(schemaIn: schema,user)
            }
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            throw StORMError.error("\(error)")
        }
    }
    
    /**
     Deletes a record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    @discardableResult
    func softDeleteWithCustomType(schemaIn:String? = "public",_ user: String? = nil) throws -> [StORMRow] {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        var idnumber: String = ""
        
        let thedata = self.asData()
        
        for i in thedata.enumerated() {
            
            if i.element.0 == idcolumn {
                let type = type(of: i.element.1)
                switch type {
                case is Int.Type, is Int?.Type:
                    idnumber = String(describing: i.element.1 as! Int)
                case is String.Type, is String?.Type:
                    idnumber = "'\(String(describing: i.element.1 as! String))'"
                default:
                    break
                }
            }
        }
        
        var deleteuser = ""
        if user == nil {
            deleteuser = RMDefaultUserValues.user_admin
        } else {
            deleteuser = user!
        }
        
        // build the sql
        var str = "UPDATE \(schema).\(self.table()) "
        str.append("SET \"deleted\"  = \(String(describing: RMServiceClass.getNow())), \"deletedby\"  = '\(deleteuser)', ")
        str.append("    \"modified\" = \(String(describing: RMServiceClass.getNow())), \"modifiedby\" = '\(deleteuser)' ")
        str.append("WHERE \"\(idcolumn.lowercased())\" = \(idnumber)")
        
        do {
            return try self.execRows(str, params: [])
        } catch {
            LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
    }
    
    /**
     Deletes a record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    @discardableResult
    func softUnDeleteWithCustomType(schemaIn:String? = "public", _ user: String? = nil) throws -> [StORMRow] {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        var idnumber: String = ""
        
        let thedata = self.asData()
        
        for i in thedata.enumerated() {
            
            if i.element.0 == idcolumn {
                let type = type(of: i.element.1)
                switch type {
                case is Int.Type, is Int?.Type:
                    idnumber = String(describing: i.element.1 as! Int)
                case is String.Type, is String?.Type:
                    idnumber = "'\(String(describing: i.element.1 as! String))'"
                default:
                    break
                }
            }
        }
        
        var deleteuser = ""
        if user == nil {
            deleteuser = RMDefaultUserValues.user_server
        } else {
            deleteuser = user!
        }
        
        // build the sql
        var str = "UPDATE \(schema).\(self.table()) "
        str.append("SET \"deleted\"  = 0, \"deletedby\" = NULL, ")
        str.append("    \"modified\" = \(String(describing: RMServiceClass.getNow())), \"modifiedby\" = '\(deleteuser)' ")
        str.append("WHERE \"\(idcolumn.lowercased())\" = \(idnumber)")
        
        do {
            return try self.execRows(str, params: [])
        } catch {
            LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
        
    }
    
    private func insertWithCustomTypes(schemaIn:String? = "public", _ user: String? = nil) throws -> [StORMRow] {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        // get the variables with their values in the dictionary
        let thedata = asData()
        
        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        // remove the id key
        var keys = [String]()
        var vals = [String]()
        for i in thedata {
            
            if (String(describing: i.1) != "nil") {
                let c = type(of: i.1)
                switch c {
                case is String.Type, is String?.Type:
                    let app = "'\((i.1 as! String).sanitized)'"
                    keys.append(i.0)
                    vals.append(app)
                case is RMGeographyPoint.Type:
                    if let point = i.1 as? RMGeographyPoint, point.latitude != 0, point.longitude != 0 {
                        let gisstring = "ST_SetSRID(ST_MakePoint(\(point.longitude),\(point.latitude)),4326)"
                        keys.append(i.0)
                        vals.append(gisstring)
                    } else { continue }
                case is Int.Type, is Double.Type, is Float.Type, is Bool.Type:
                    let value = String(describing: i.1)
                    keys.append(i.0)
                    vals.append(value)
                    break
                // OPTIONAL VALUES:
                case is Int?.Type:
                    // Make sure the according type is casted to our string describing wont include the optional part:
                    let value = String(describing: i.1 as! Int)
                    keys.append(i.0)
                    vals.append(value)
                    break
                case is Float?.Type:
                    let value = String(describing: i.1 as! Float)
                    keys.append(i.0)
                    vals.append(value)
                    break
                case is Bool?.Type:
                    let value = String(describing: i.1 as! Bool)
                    keys.append(i.0)
                    vals.append(value)
                case is Double?.Type:
                    let value = String(describing: i.1 as! Double)
                    keys.append(i.0)
                    vals.append(value)
                    break
                    // We will default here.  We will need to wrap other types here in the case switch.
                    //                case is String?.Type:
                    //                    // Its a string, lets cast it
                    //                    let stringValue = "'\(i.1 as! String)'"
                    //                    keys.append(i.0)
                //                    vals.append(stringValue)
                case is RMGeographyPoint?.Type:
                    let geographypoint = i.1 as! RMGeographyPoint
                    let gisstring = "ST_SetSRID(ST_MakePoint(\(geographypoint.longitude),\(geographypoint.latitude)),4326)"
                    keys.append(i.0)
                    vals.append(gisstring)
                default:
                    print("[CCXStORMExtensions] [updateWithGIS] [\(RMServiceClass.getNow().dateString)]  WARNING: Need to add the following type to update/add/saveWithCustomType: \(c)")
                    continue
                }
            }
        }
        
        var substString = [String]()
        for i in 1..<vals.count {
            substString.append("$\(i)")
        }
        
        let colsjoined = "\"" + keys.joined(separator: "\",\"") + "\""
        
        let str = "INSERT INTO \(schema).\(self.table()) (\(colsjoined.lowercased())) VALUES(\(vals.joined(separator: ","))) RETURNING \"\(idcolumn.lowercased())\""
        
        print(str)
        
        do {
            //            let response = try sql(str, params: [])
            //            let response = try exec(str, params: vals)
            //            return parseRows(response)[0].data[idcolumn.lowercased()]!
            return try self.execRows(str, params: [])
            
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
    }
    
    /**
     Adds a new record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    private func addWithCustomTypes(schemaIn:String? = "public", _ user: String? = nil) throws -> [StORMRow] {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        // get the variables with their values in the dictionary
        let thedata = asData()
        
        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        // remove the id key
        var keys = [String]()
        var vals = [String]()
        for i in thedata {
            
            // first lets see if the field is 'created' or 'createdby'
            if (i.0 == "created") {
                let now = RMServiceClass.getNow()
                keys.append(i.0)
                vals.append(String(describing: now))
            } else if (i.0 == "createdby") {
                let theUser = user ?? RMDefaultUserValues.user_server
                keys.append(i.0)
                vals.append("'\(theUser)'")
            } else if (i.0 != idcolumn) && (String(describing: i.1) != "nil") {
                
                let c = type(of: i.1)
                switch c {
                case is String.Type, is String?.Type:
                    let app = "'\((i.1 as! String).sanitized)'"
                    keys.append(i.0)
                    vals.append(app)
                case is RMGeographyPoint.Type:
                    if let point = i.1 as? RMGeographyPoint, point.latitude != 0, point.longitude != 0 {
                        let gisstring = "ST_SetSRID(ST_MakePoint(\(point.longitude),\(point.latitude)),4326)"
                        keys.append(i.0)
                        vals.append(gisstring)
                    } else { continue }
                case is Int.Type, is Double.Type, is Float.Type, is Bool.Type:
                    let value = String(describing: i.1)
                    keys.append(i.0)
                    vals.append(value)
                    break
                // OPTIONAL VALUES:
                case is Int?.Type:
                    // Make sure the according type is casted to our string describing wont include the optional part:
                    let value = String(describing: i.1 as! Int)
                    keys.append(i.0)
                    vals.append(value)
                    break
                case is Float?.Type:
                    let value = String(describing: i.1 as! Float)
                    keys.append(i.0)
                    vals.append(value)
                    break
                case is Bool?.Type:
                    let value = String(describing: i.1 as! Bool)
                    keys.append(i.0)
                    vals.append(value)
                case is Double?.Type:
                    let value = String(describing: i.1 as! Double)
                    keys.append(i.0)
                    vals.append(value)
                    break
                    // We will default here.  We will need to wrap other types here in the case switch.
                    //                case is String?.Type:
                    //                    // Its a string, lets cast it
                    //                    let stringValue = "'\(i.1 as! String)'"
                    //                    keys.append(i.0)
                //                    vals.append(stringValue)
                case is RMGeographyPoint?.Type:
                    let geographypoint = i.1 as! RMGeographyPoint
                    let gisstring = "ST_SetSRID(ST_MakePoint(\(geographypoint.longitude),\(geographypoint.latitude)),4326)"
                    keys.append(i.0)
                    vals.append(gisstring)
                default:
                    print("[CCXStORMExtensions] [updateWithGIS] [\(RMServiceClass.getNow().dateString)]  WARNING: Need to add the following type to update/add/saveWithCustomType: \(c)")
                    continue
                }
            }
        }
        
        var substString = [String]()
        for i in 1..<vals.count {
            substString.append("$\(i)")
        }
        
        let colsjoined = "\"" + keys.joined(separator: "\",\"") + "\""
        
        let str = "INSERT INTO \(schema).\(self.table()) (\(colsjoined.lowercased())) VALUES(\(vals.joined(separator: ","))) RETURNING \"\(idcolumn.lowercased())\""
        
        print(str)
        
        do {
            //            let response = try sql(str, params: [])
            //            let response = try exec(str, params: vals)
            //            return parseRows(response)[0].data[idcolumn.lowercased()]!
            return try self.execRows(str, params: [])
            
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
    }
    
    /**
     Updates a record with GIS coordinates in a geography type field and other field values.
     - Returns: An Any type.  For a new inser, we will return the id
     */
    private func updateWithCustomType(schemaIn:String? = "public", _ user: String? = nil) throws -> [StORMRow] {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        // get the variables with their values in the dictionary
        let thedata = self.asData()
        
        // get the key (id)
        let (idcolumn, _) = firstAsKey()
        
        var idnumber: String = ""
        
        var set:String = ""
        
        for i in thedata.enumerated() {
            
            // We dont need to continue if they value is nil:
            let value = String(describing: i.element.1)
            
            // Make sure we set the idnumber correctly:
            if i.element.0 == idcolumn {
                switch i.element.1 {
                case is Int:
                    idnumber = String(describing: i.element.1 as! Int)
                case is String:
                    idnumber = "'\(String(describing: i.element.1 as! String))'"
                default:
                    break
                }
            }
            
            if (i.element.0 == "modified") {
                let now = RMServiceClass.getNow()
                let value = String(describing: now)
                set.append(" \(i.element.0) = \(value),")
            } else if (i.element.0 == "modifiedby") {
                let theUser = user ?? RMDefaultUserValues.user_server
                set.append(" \(i.element.0) = '\(theUser)',")
            } else if (i.element.0 != idcolumn) && value != "nil" {
                
                // we are doing this to remove the quotes around the GIS functions (it will not work)
                let c = type(of: i.element.1)
                // Right now we are assuming no optionals, so we will add in each key & then append the next value next.  We will skip that if its optional & nil.
                switch c {
                // Deal with the string type -- we need to wrap it in quotes:
                case is String.Type, is String?.Type:
                    // The sanitized extension variable replaces any quotes with a double quote (via SQL docs):
                    let stringValue = (i.element.1 as! String).sanitized
                    set.append(" \(i.element.0) = '\(stringValue)',")
                // add the GIS stuff
                case is RMGeographyPoint.Type:
                    if let point = i.element.1 as? RMGeographyPoint, point.latitude != 0, point.longitude != 0 {
                        let gisstring = "ST_SetSRID(ST_MakePoint(\(point.longitude),\(point.latitude)),4326)"
                        set.append(" \(i.element.0) = \(gisstring),")
                    }
                // I think we can deal with the following types in the following way:
                case is Int.Type, is Double.Type, is Float.Type:
                    let value = String(describing: i.element.1)
                    set.append(" \(i.element.0) = \(value),")
                    break
                // OPTIONAL VALUES:
                case is Int?.Type:
                    // Make sure the according type is casted to our string describing wont include the optional part:
                    let value = String(describing: i.element.1 as! Int)
                    set.append(" \(i.element.0) = \(value),")
                    break
                case is Float?.Type:
                    let value = String(describing: i.element.1 as! Float)
                    set.append(" \(i.element.0) = \(value),")
                    break
                case is Bool?.Type, is Bool.Type:
                    let boolValue = String(describing: i.element.1 as! Bool)
                    set.append(" \(i.element.0) = \(boolValue),")
                case is Double?.Type:
                    let value = String(describing: i.element.1 as! Double)
                    set.append(" \(i.element.0) = \(value),")
                    break
                    // We will default here.  We will need to wrap other types here in the case switch.
                    //                case is String?.Type:
                    //                    // Its a string, lets cast it
                    //                    let stringValue = "'\((i.element.1 as! String).sanitized)'"
                //                    set.append(" \(i.element.0) = \(stringValue),")
                case is RMGeographyPoint?.Type:
                    let geographypoint = i.element.1 as! RMGeographyPoint
                    let gisstring = "ST_SetSRID(ST_MakePoint(\(geographypoint.longitude),\(geographypoint.latitude)),4326)"
                    set.append(" \(i.element.0) = \(gisstring),")
                default:
                    continue
                }
            }
        }
        
        // Remove out the last comma after looping:
        if set.count > 0 {
            set.removeLast()
        }
        
        // build the sql
        let str = "UPDATE \(schema).\(self.table()) SET \(set) WHERE \"\(idcolumn.lowercased())\" = \(idnumber)"
        
        do {
            //            let response = try sql(str, params: [])
            //            return parseRows(response)[0].data[idcolumn.lowercased()]!
            return try self.execRows(str, params: [])
        } catch {
            LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
        
    }
    
    /**
     Updates a single record with GIS coordinates in a geography type field.
     - parameter record_id: The id of the record you would like to update
     - parameter locationField: This is the geography type field in the database used as the search criteria
     - parameter longitude: The longitude of the reference point for the search
     - parameter latitude: The latitude of the reference point for the search
     - Returns: An array of StORMRow objects with the resulting dataset
     */
    private func updateLocationGIS(schemaIn:String? = "public", record_id: Int, locationField: String, longitude: Double, latitude: Double) throws -> [StORMRow] {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        
        let parms: [String] = [String(record_id), String(longitude), String(latitude)]
        var sqlstatement = "UPDATE \(schema).\(self.table()) "
        sqlstatement.append("SET \(locationField) = ")
        sqlstatement.append("ST_SetSRID(ST_MakePoint($2, $3), 4326) ")
        sqlstatement.append("WHERE id = $1")
        
        return try self.execRows(sqlstatement, params: parms)
        
    }
    
    /**
     Allows custom SQL statements to integrate with the GIS statements.
     - parameter sql: The SQL statement to run with replacement variables
     - Use {{GISFIELDS}} to insert the postgis location field selection as latitide and longitude double fields.
     - Use the {{GISWHERE}} to insert the section of the WHERE clause to limit according to the selection criteria
     - parameter locationField: This is the geography type field in the database used as the search criteria
     - parameter longitude: The longitude of the reference point for the search
     - parameter latitude: The latitude of the reference point for the search
     - parameter distance: The comparison distance in miles
     - Returns: An array of StORMRow objects with the resulting dataset
     */
    func getLocationGISsql(sql: String, locationField: String, longitude: Double, latitude: Double, distance: Double) throws -> [StORMRow] {
        
        var sqlstatement = sql
        //        var gisfields = " "
        //        var giswhere  = " "
        
        // add the location based fields to return lat and lon
        // (note the space in the definition of the field - this assures
        //  the space between characters for the replacement)
        //        gisfields.append("ST_X(\(locationField)::geometry) as longitude, ")
        //        gisfields.append("ST_Y(\(locationField)::geometry) as latitude, ")
        
        // add the localization to the statement
        // (note the space in the definition of the field - this assures
        //  the space between characters for the replacement)
        //        giswhere.append("ST_DWithin(\(locationField), ST_SetSRID(ST_Point(\(longitude), \(latitude)), 4326), \(distance)) ")
        
        let gisfields = RMServiceClass.sharedInstance.getGISFields(locationField: locationField)
        let giswhere  = RMServiceClass.sharedInstance.getGISWhere(locationField: locationField, longitude: longitude, latitude: latitude, distance: distance)
        
        sqlstatement = sqlstatement.replacingOccurrences(of: "{{GISFIELDS}}", with: gisfields)
        sqlstatement = sqlstatement.replacingOccurrences(of: "{{GISWHERE}}", with: giswhere)
        
        print("Built Location SQL: \(sqlstatement)")
        
        return try self.execRows(sqlstatement, params: [])
        
    }
    
    
    /**
     Selects records based on their relative position from a specific point.
     - parameter longitude: The longitude of the reference point for the search
     - parameter latitude: The latitude of the reference point for the search
     - parameter locationField: This is the geography type field in the database used as the search criteria
     - parameter distance: The comparison distance in miles
     - parameter fields: An array of the names of the fields you would like returned in addition to the longitude and latitude fields
     - Returns: An array of StORMRow objects with the resulting dataset
     */
    func getLocationGIS(schemaIn:String? = "public", longitude: Double, latitude: Double, locationField: String, fields: [String], distance: Double) throws -> [StORMRow] {
        
        var schema = "public"
        if schemaIn.isNotNil {
            schema = schemaIn!.lowercased()
        }
        
        var sqlstatement = "SELECT "
        
        // show the fields that are returned (NO *)
        for field in fields {
            sqlstatement.append("\(field), ")
        }
        
        // add the location based fields to return lat and lon
        sqlstatement.append("ST_X(\(locationField)::geometry) as longitude, ")
        sqlstatement.append("ST_Y(\(locationField)::geometry) as latitude ")
        
        // completing the SQL
        sqlstatement.append("FROM \(schema).\(self.table()) ")
        
        // add the localization to the statement
        sqlstatement.append("WHERE ST_DWithin(\(locationField), ST_SetSRID(ST_Point($1, $2), 4326), $3)")
        
        print("Location SQL: \(sqlstatement)")
        
        let parms: [String] = [String(longitude), String(latitude), String(distance)]
        
        return try self.execRows(sqlstatement, params: parms)
        
    }
    
    // Internal function which executes statements, with parameter binding
    // Returns a processed row set
    @discardableResult
    func execRows(_ statement: String, params: [String]) throws -> [StORMRow] {
        let thisConnection = PostgresConnect(
            host:        PostgresConnector.host,
            username:    PostgresConnector.username,
            password:    PostgresConnector.password,
            database:    PostgresConnector.database,
            port:        PostgresConnector.port
        )
        
        thisConnection.open()
        thisConnection.statement = statement
        
        printDebug(statement, params)
        let result = thisConnection.server.exec(statement: statement, params: params)
        
        // set exec message
        errorMsg = thisConnection.server.errorMessage().trimmingCharacters(in: .whitespacesAndNewlines)
        if StORMdebug { LogFile.info("Error msg: \(errorMsg)", logFile: "./StORMlog.txt") }
        if isError() {
            thisConnection.server.close()
            throw StORMError.error(errorMsg)
        }
        
        let resultRows = parseRows(result)
        //        result.clear()
        thisConnection.server.close()
        return resultRows
    }
    
    private func printDebug(_ statement: String, _ params: [String]) {
        if StORMdebug { LogFile.debug("StORM Debug: \(statement) : \(params.joined(separator: ", "))", logFile: "./StORMlog.txt") }
    }
    
    func isError() -> Bool {
        if errorMsg.contains(string: "ERROR") {
            print(errorMsg)
            return true
        }
        return false
    }
}
