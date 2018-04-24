//
//  UserAPI.swift
//
//  Created by Ryan Coyne on 10/30/17.
//

import Foundation
import StORM
import PostgresStORM
import PerfectHTTP
import PerfectLib
import PerfectLocalAuthentication
import PerfectSessionPostgreSQL
import PerfectSession
//import SwiftRandom
import PerfectCrypto
import SwiftGD

//MARK: - User API
/// This UserAPI structure supports all the normal endpoints for a user based login application.
struct UserAPI {
    
    //MARK: - JSON Routes
    /// This json structure supports all the JSON endpoints that you can use in the application.
    struct json {
        static var routes : [[String:Any]] {
            return [["method":"post",   "uri":"/api/v1/login", "handler": login],
                    ["method":"get",    "uri":"/api/v1/logout", "handler":logout],
                    ["method":"post",   "uri":"/api/v1/login/oauth", "handler":oauth.login],
                    ["method":"post",   "uri":"/api/v1/register", "handler":register],
                    ["method":"post",   "uri":"/api/v1/forgotpassword", "handler":forgotPassword],
                    ["method":"post",   "uri":"/api/v1/user/update", "handler":updateProfile],
                    ["method":"post",   "uri":"/api/v1/user/upload", "handler":uploadPicture],
                    ["method":"post",   "uri":"/api/v1/changepassword", "handler":changePassword],
                    ["method":"post",   "uri":"/api/v1/check", "handler":checkEmailOrUsername]
            ]
        }
        //MARK: - Logout
        public static func logout(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                if let _ = request.session?.token {
                    PostgresSessions().destroy(request, response)
                    request.session = PerfectSession()
                    response.request.session = PerfectSession()
                }
                _ = try? response.setBody(json: ["result":"success"])
                response.completed(status: .ok)
            }
        }
        //MARK: - Login: Username/Password OR Email/Password
        public static func login(_ data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                if let s = request.session?.userid, !s.isEmpty {
                    try? response.setBody(json: ["error" : "You are already logged in."])
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)
                }
                if let data = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    if let data = data {
                        if let password = data["password"].stringValue, let username = data["username"].stringValue?.lowercased() {
                            
                            if let acc = try? Account.login(username, password) {
                                
                                request.session?.userid = acc.id
                                try? response.setBody(json: acc.asDictionary)
                                    .setHeader(.contentType, value: "application/json")
                                    .completed(status: .ok)
                                
                            } else {
                                // Failed on login
                                try? response.setBody(json: ["error":"Unable to log in."])
                                    .setHeader(.contentType, value: "application/json")
                                    .completed(status: .forbidden)
                            }
                        } else if let email = data["email"].stringValue, let password = data["password"].stringValue {
                            // Okay they are attempting an email/password login:
                            
                            if let acc = try? Account.loginWithEmail(email, password) {
                                
                                request.session?.userid = acc.id
                                
                                try? response.setBody(json: acc.asDictionary)
                                    .setHeader(.contentType, value: "application/json")
                                    .completed(status: .ok)
                                
                            } else {
                                // Failed on login
                                try? response.setBody(json: ["error":"Unable to log in."])
                                    .setHeader(.contentType, value: "application/json")
                                    .completed(status: .forbidden)
                            }
                        }
                    } else {
                        try? response.setBody(json: ["error":"Unable to cast decoded json to [String:Any]."])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .badRequest)
                    }
                } else {
                    // Encoding failed:
                    try? response.setBody(json: ["error":"Unable to decode json."])
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .badRequest)
                }
            }
        }
        //MARK: - Register:
        public static func register(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                if let i = request.session?.userid, !i.isEmpty {
                    _ = try? response.setBody(json: ["error":"Already logged in"])
                    response.completed(status: .ok)
                    return
                }
            
                if let postBody = request.postBodyString, !postBody.isEmpty {
                    do {
                        let postBodyJSON = try postBody.jsonDecode() as? [String: String] ?? [String: String]()
                        if let u = postBodyJSON["username"], !u.isEmpty,
                            let e = postBodyJSON["email"], !e.isEmpty {
                            let err = Account.register(u.lowercased(), e, .provisional, baseURL: AuthenticationVariables.baseURL)
                            if err != .noError {
                                LocalAuthHandlers.error(request, response, error: "Registration Error: \(err)", code: .badRequest)
                                return
                            } else {
                                
                                // success!
                                // pull the user
                                let thenewuser = Account()
                                let tnu = try? thenewuser.sqlRows("SELECT id FROM account WHERE email = '\(e)'", params: [])
                                
                                let newuser_id = tnu?.first?.data["id"].stringValue
                                
                                if newuser_id.isNotNil {
                                    try? thenewuser.get(newuser_id!)
                                    // call the just created section
                                    UserAPI.UserSuccessfullyCreated(thenewuser)
                                    
                                }
                                
                                _ = try response.setBody(json: ["result":"success", "message":"Check your email for an email from us. It contains instructions to complete your signup!"])
                                response.completed(status: .ok)
                                return
                            }
                        } else {
                            LocalAuthHandlers.error(request, response, error: "Please supply a username and password", code: .badRequest)
                            return
                        }
                    } catch {
                        LocalAuthHandlers.error(request, response, error: "Invalid JSON", code: .badRequest)
                        return
                    }
                } else {
                    LocalAuthHandlers.error(request, response, error: "Registration Error: Insufficient Data", code: .badRequest)
                    return
                }
                
            }
        }
        //MARK: - Change Password
        public static func changePassword(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
                
                let i = request.session!.userid
                let acc = Account()
                do {
                    try acc.get(i)
                        
                    // start chpwd
                    if let postBody = request.postBodyString, !postBody.isEmpty {
                        do {
                            let postBodyJSON = try postBody.jsonDecode() as? [String: String] ?? [String: String]()
                            if let password = postBodyJSON["password"], !password.isEmpty {
                                acc.makePassword(password)
                                try acc.save()
                                _ = try response.setBody(json: ["result":"success", "message":"Congratulations!  You are amazing!  You changed your password!"])
                                response.completed(status: .ok)
                                return
                            } else {
                                LocalAuthHandlers.error(request, response, error: "Please supply a vaid password",
                                                        code: .badRequest)
                                return
                            }
                        } catch {
                            LocalAuthHandlers.error(request, response, error: "Invalid JSON", code: .badRequest)
                            return
                        }
                    } else {
                        LocalAuthHandlers.error(request, response, error: "Change Password Error: Insufficient Data", code: .badRequest)
                        return
                    }
                    // end chpwd
                } catch {
                    LocalAuthHandlers.error(request, response, error: "AccountError", code: .badRequest)
                    return
                }
            }
        }
        
        //MARK: Checing for the existence of username or password
        static func checkEmailOrUsername(data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                let json = try? request.postBodyString?.jsonDecode() as? [String:Any]
                
                if json.isNil {
                    try? response.setBody(json: ["error":"No post body params"])
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .badRequest)
                } else {
                    
                    var responseDic:[String:Any] = [:]
                    if let email = json??["email"].stringValue {
                        responseDic["emailAvailable"] = Account.exists.with.email(email)
                    }
                    
                    if let username = json??["username"].stringValue?.lowercased() {
                        responseDic["usernameAvailable"] = Account.exists.with.username(username)
                    }
                    
                    try? response.setBody(json: responseDic)
                        .setHeader(.contentType, value: "application/json")
                        .completed(status: .ok)
                    
                }
                
            }
        }


        //MARK: - Oauth Structure:
        struct oauth {
            
            static let facebook : FacebookOAuth = FacebookOAuth()
            static let google : GoogleOAuth = GoogleOAuth()
            static let twitter : TwitterOAuth = TwitterOAuth()
            
            public static func createOrLoginUser(_ json : [String:Any] /*, _ request : HTTPRequest*/, _ type: String) throws -> Account {
                var user = Account()
                var json = json
                let findDic:[String:Any] = ["source": type, "remoteid": json["id"].stringValue!]
                try user.find(findDic)
                if user.id.isEmpty {
                    // If we have an email, lets check that too ->
                    if let email = json["email"].stringValue { try user.find(["email":email]) }
                    guard user.id.isEmpty else { /* Here we should check if the user source is equal to the type */
                        // If the type is not equal to the user source (local, facebook, twitter, google)
                        if type != user.source {
                            // Their email is the same, so we dont need to update that here.
                            if json["email"].isNotNil {
                                json.removeValue(forKey: "email")
                            }
                            user.remoteid = json["id"].stringValue!
                            
                            if let _ = json["created"] {
                                json["modified"] = CCXServiceClass.sharedInstance.getNow()
                                json["modifiedby"] = user.id
                            } else {
                                json["created"] = CCXServiceClass.sharedInstance.getNow()
                                json["createdby"] = user.id
                                json["locationAttention"] = true
                            }
                            
                            // Now remove it out since it is in the remoteid:
                            json.removeValue(forKey: "id")
                            user.source = type
                            user.detail = json
                            
                            // add the current location (after we saved the detail)
                            user = UserAPI.addCurrentLocationToUser(user, locationJSON: json)

                            // no need for the GIS save function - the location info is saved in the detail (and another table)
                            try user.save()
                            return user
                            
                        } else {
                            return user
                        }
                    }
                    
                    // Okay we checked for existing accounts, so lets create a new one ->
                    user.makeID()
                    user.usertype = .standard
                    user.source = type
                    
                    if json["id"].isNotNil {
                        user.remoteid = json["id"].stringValue!
                        json.removeValue(forKey: "id")
                    }
                    if json["email"].isNotNil {
                        user.email = json["email"].stringValue!
                        json.removeValue(forKey: "email")
                    }
                    
                    user.detail = json
                    user.detail["created"] = CCXServiceClass.sharedInstance.getNow()
                    user.detail["createdby"] = user.remoteid
                    user.detail["locationAttention"] = true

                    // add the current location (after we saved the detail)
                    user = UserAPI.addCurrentLocationToUser(user, locationJSON: json)
                    
                    // no need for the GIS save function - the location info is saved in the detail (and another table)
                    try user.create()
                    
                    // lets see if we can link stages
                    // do this before we change the user.detail with the isNew element.
                    UserAPI.UserSuccessfullyCreated(user)
                    
                    user.detail["isNew"] = true
                    
                } else {
                    return user
                }
                return user
            }
            
            public static func login(data: [String:Any]) throws -> RequestHandler {
                return {
                    request, response in
                    if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                        if let json = json, json.keys.count == 1, let key = json.first?.key {
                            switch key {
                            case "facebook":
                                
                                if let theTest = try? facebook.verifyCredentials(json) {
                                    if theTest.passed {
                                        // Now we need to either log the user in or create the user, and log them in.
                                        let account = try! self.createOrLoginUser(theTest.data, key)
                                        request.session?.userid = account.id
                                        
                                        try? response.setBody(json: account.asDictionary)
                                            .setHeader(.contentType, value: "application/json")
                                            .completed(status: .ok)
                                        
                                    } else {
                                        // Return an error indicating we failed attempting to use oauth.
                                        try! response.setBody(json: ["error":"Failed OAuth attempt for \(key)"])
                                            .setHeader(.contentType, value: "application/json")
                                            .completed(status: .forbidden)
                                    }
                                }
                            case "google":
                                if let theTest = try? google.verifyCredentials(json) {
                                    if theTest.passed {
                                        
                                        let account = try! self.createOrLoginUser(theTest.data, key)
                                        request.session?.userid = account.id
                                        
                                        try? response.setBody(json: account.asDictionary)
                                            .setHeader(.contentType, value: "application/json")
                                            .completed(status: .ok)
                                    } else {
                                        try! response.setBody(json: ["error":"Failed OAuth attempt for \(key)"])
                                            .setHeader(.contentType, value: "application/json")
                                            .completed(status: .forbidden)
                                    }
                                }
                                //                            case "twitter":
                                //                                if let theTest = try? twitter.verifyCredentials(json) {
                                //                                    if theTest.passed {
                                //
                                //                                        let account = try! self.createOrLoginUser(theTest.data, key)
                                //
                                //                                    } else {
                                //                                        try! response.setBody(json: ["error":"Failed OAuth attempt for \(key)"])
                                //                                            .setHeader(.contentType, value: "application/json")
                                //                                            .completed(status: .forbidden)
                                //                                    }
                            //                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
        
        //MARK: - Update Profile:
        static func updateProfile(data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
                
                if let json = try? request.postBodyString?.jsonDecode() as? [String:Any] {
                    if let json = json {
                        
                        var user = Account()
                        try! user.get(session.userid)
                        
                        if json.isEmpty {
                            try? response.setBody(json: ["error":"Empty json"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .badRequest)
                        }
                        
                        if json["email"].stringValue.isNotNil {
                            user.email = json["email"].stringValue!
                        }
                        
                        if json["username"].stringValue.isNotNil {
                            user.username = json["username"].stringValue!.lowercased()
                        }
                        
                        if json["lastname"].stringValue.isNotNil {
                            user.detail["lastname"] = json["lastname"].stringValue!
                        }
                        
                        if json["firstname"].stringValue.isNotNil {
                            user.detail["firstname"] = json["firstname"].stringValue!
                        }
                        
//                        if !json["detail"].dicValue.isEmpty {
//                            user.detail = json["detail"].dicValue
//                        }
                        
                        // add the location and the location record
                        user = UserAPI.addCurrentLocationToUser(user, locationJSON: json)
                        
                        user.detail["modified"] = CCXServiceClass.sharedInstance.getNow()
                        user.detail["modifiedby"] = session.userid

                        // no need for the GIS save as the location is not saved nin a geo field (it is in detail)
                        try! user.save()
                        
                        try? response.setBody(json: ["result":"success"])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .ok)
                    }
                }
            }
        }
        //MARK: - File Support Functions:
        static func getFilenameProfile()->String {
            
            // name the new file
            var newfilename = UUID().uuidString
            // since we are using the UUID function there is a ~~very~~ slim chance of duplicates
            // if it is a duplicate, select another UUID.
            if doesFileExistProfilePics(filename: newfilename) {
                newfilename = UUID().uuidString
            }
            
            return newfilename
        }
                
        static func doesFileExistProfilePics(filename: String) -> Bool {
            
            var filefound = false
            
            // does it exist?
            var context = ["files":[[String:String]]()]
            let d = Dir(CCXServiceClass.sharedInstance.filesDirectoryProfilePics)
            
            // if the directory does not exist, create it....
            CCXServiceClass.doesDirectoryExist(d)

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
        
//        static func doesFileExist(filename: String) -> Bool {
//            
//            var filefound = false
//            
//            // does it exist?
//            var context = ["files":[[String:String]]()]
//            let d = Dir(CCXServiceClass.sharedInstance.filesDirectory)
//            
//            // if the directory does not exist, create it....
//            CCXServiceClass.doesDirectoryExist(d)
//
//            do {
//                try d.forEachEntry(closure: {
//                    f in
//                    
//                    if f.lowercased() == filename.lowercased() {
//                        filefound = true
//                        return
//                    }
//                    
//                    context["files"]?.append(["name":f])
//                })
//            } catch {
//                print("Searching the directory error: \(error)")
//            }
//            
//            // we didn't see the file, or maybe we did?
//            return filefound
//            
//        }
                
        //MARK: - Update Profile:
        static func uploadPicture(data : [String:Any]) throws -> RequestHandler {
            return {
                request, response in

            // security
            guard let session = request.session, !session.userid.isEmpty else { return response.notLoggedIn() }
            
            var imagetype = "large"
            var newfilename = ""
            var newfilenameadjustedimage = ""
            
            let pp = request.postParams
            for (key, value) in pp {
                switch key {
                case "type":
                    imagetype = value
                default:
                    break
                }
            }
            
            // process the uploads and the parameters
            if let uploads = request.postFileUploads, uploads.count > 0 {
                
                // put the file together
                for upload in uploads {
                    
                    let thisFile = File(upload.tmpFileName)
                    if thisFile.exists {
                        
                        newfilename = CCXServiceClass.getFilename()
                        newfilenameadjustedimage = newfilename
                        newfilenameadjustedimage.append("-small")
                        
                        do {
                            // create the new name with extension
                            newfilename.append(".\(upload.fileName.filePathExtension)")
                            newfilenameadjustedimage.append(".\(upload.fileName.filePathExtension)")
                            
                            // make sure it is not already there (only do this once... )
                            if doesFileExistProfilePics(filename: newfilename) {
                                newfilename = UUID().uuidString
                                newfilename.append(".\(upload.fileName.filePathExtension)")
                                
                                newfilenameadjustedimage = newfilename
                                newfilenameadjustedimage.append("-small")
                                newfilenameadjustedimage.append(".\(upload.fileName.filePathExtension)")
                                
                            }
                            
                            // create the new file name
                            upload.fileName = newfilename
                            let thepath = "\(CCXServiceClass.sharedInstance.filesDirectoryProfilePics)/\(upload.fileName)"
                            print(thepath)

//                            let target = Dir(CCXServiceClass.sharedInstance.filesDirectoryProfilePics)

//                            CCXServiceClass.movePicture(picturename: thisFile, todirectory: target)
                            let _ = try thisFile.moveTo(
                                path: thepath, overWrite: true
                            )
//                            debugPrint("File upload move: \(e)")
                            
                            var smallimagelocation = ""
                            
                            // lets create the small image first
                            let location = URL(fileURLWithPath:"\(CCXServiceClass.sharedInstance.filesDirectoryProfilePics)/\(upload.fileName)")
//                            print("Image location: \(location.absoluteString)")
                            let tmpsmallimage = Image(url: location)
//                            debugPrint(tmpsmallimage)
                            // resize the image
//                            print("Resizing the profile image")
                            if let smallimage = tmpsmallimage?.resizedTo(width:75) {
//                                print("Image resized")
                                let locationsmall = URL(fileURLWithPath:"\(CCXServiceClass.sharedInstance.filesDirectoryProfilePics)/\(newfilenameadjustedimage)")
//                                print("Writing the small image to: \(locationsmall.absoluteString)")
                                if smallimage.write(to: locationsmall) {
                                    // lets add it to the users data
                                    smallimagelocation = EnvironmentVariables.sharedInstance.AWSfileURLProfilePics!
                                    smallimagelocation.append(newfilenameadjustedimage)
                                }
                            }
                        } catch {
                            print(error)
                            try? response.setBody(json: ["error":error.localizedDescription])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .badRequest)
                        }
                    }
                }
            } else {
                
                try? response.setBody(json: ["error":"The file was not uploaded"])
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .badRequest)
            }
            
            // save to the object (the filename)
            var picturesource = EnvironmentVariables.sharedInstance.AWSfileURLProfilePics!
            picturesource.append(newfilename)
            
            // lets update the user
            let c = Account()
            
            let tryy = try? c.get(session.userid)
            if tryy.isNil {
                try? response.setBody(json: ["error":"Could not get user for update on \(imagetype)_picture"])
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .badRequest)
            }
            c.detail["\(imagetype)_picture"] = picturesource
            c.detail["modified"] = CCXServiceClass.sharedInstance.getNow()
            
            if newfilenameadjustedimage.count > 0 {
                // we have the small image!
                c.detail["small_picture"] = "\(EnvironmentVariables.sharedInstance.AWSfileURLProfilePics!)\(newfilenameadjustedimage)"
            }

                var retd:[String:Any] = [:]

            // update the user
            do {
                try c.saveWithGIS(session.userid)
                
                retd["id"] = c.id
                retd["\(imagetype)_picture"] = c.detail["\(imagetype)_picture"]
                retd["small_picture"] = c.detail["small_picture"]

            } catch {
       
                try? response.setBody(json: ["error":"The picture was not uploaded"])
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .badRequest)
            }
                try? response.setBody(json: retd)
                    .setHeader(.contentType, value: "application/json")
                    .completed(status: .ok)

            }
        }
        //MARK: - Forgot Password:
        static func forgotPassword(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                
                let dic = try? request.postBodyString?.jsonDecode() as? [String:Any]
                
                if dic.isNotNil {
                    
                    let dic = dic!!
                    
                    if let email = dic["email"].stringValue {
                        
                        // generate the random (with safety net incase there is an issue)
                        let random = [UInt8](randomCount: 16)
                        var secureToken = "basetoken\(random)"
                        if let base64 = random.encode(.base64),
                            let sectok = String(validatingUTF8: base64) {
                            secureToken = sectok
                        }
                        
                        let account = Account()
                        let theTry:()? = try? account.find(["email":email.lowercased()])
                        if theTry.isNotNil && !account.id.isEmpty {
                            account.passvalidation = secureToken
                        }
                        
                        if (!account.id.isEmpty || account.email != email.lowercased()) && (try? account.save()).isNotNil {
                            
                            // Lets send out the email to reset the password:
                            let h = "<p>To reset your password for your account, please <a href=\"\(baseURL)/verifyAccount/forgotpassword/\(account.passvalidation)\">click here</a></p>"
                            
                            Utility.sendMail(name: account.username, address: email, subject: "Password reset!", html: h, text: "")
                            try? response.setBody(json: ["response":"success"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .ok)
                            
                        } else {
                            // Failed to save the passvalidation.
                            try? response.setBody(json: ["error":"Unknown error"])
                                .setHeader(.contentType, value: "application/json")
                                .completed(status: .badRequest)
                            
                        }
                        
                    } else {
                        try? response.setBody(json: ["error":"You must send in an email to reset your password."])
                            .setHeader(.contentType, value: "application/json")
                            .completed(status: .badRequest)
                    }
                    
                } else {
                    
                    response.unableToDecodeJSON()
                }
            }
        }
        
    }
    //MARK: - Web Handlers:
    /// This json structure supports all the web endpoints that support the application, including forgot password, completion of registration.
    struct web {
        static var routes : [[String:Any]] {
            return [["method":"get", "uri":"/verifyAccount/forgotpassword/{passvalidation}", "handler": forgotpassVerify],
                    ["method":"post", "uri":"/forgotpasswordCompletion", "handler": forgotpasswordCompletion],
                    ["method":"get", "uri":"/verifyAccount/{passvalidation}", "handler": registerVerify],
                    ["method":"post", "uri":"/registrationCompletion", "handler": registerCompletion],
                    ["method":"post", "uri":"/login", "handler":LocalAuthWebHandlers.login],
                    ["method":"get", "uri":"/logout", "handler":LocalAuthWebHandlers.logout],
                    ["method":"get", "uri":"/users", "handler":Handlers.userList],
                    ["method":"get", "uri":"/users/create", "handler":Handlers.userMod],
                    ["method":"get", "uri":"/users/create/edit", "handler":Handlers.userMod],
                    ["method":"post", "uri":"/users/create", "handler":Handlers.userModAction],
                    ["method":"post", "uri":"/users/{id}/edit", "handler":Handlers.userModAction],
                    ["method":"delete", "uri":"/users/{id}/delete", "handler":Handlers.userDelete]]
        }
        //MARK: - Register Verify Page:
        public static func registerVerify(_ data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                let t = request.session?.data["csrf"] as? String ?? ""
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
                var context: [String : Any] = appExtras(request)
                
                if let v = request.urlVariables["passvalidation"], !(v as String).isEmpty {
                    
                    let acc = Account(validation: v)
                    
                    if acc.id.isEmpty {
                        context["msg_title"] = "Account Validation Error."
                        context["msg_body"] = ""
                        response.render(template: "views/msg", context: context)
                        return
                    } else {
                        context["passvalidation"] = v
                        context["csrfToken"] = t
                        response.render(template: "views/registerComplete", context: context)
                    }
                } else {
                    context["msg_title"] = "Account Validation Error."
                    context["msg_body"] = "Code not found."
                    response.render(template: "views/msg", context: context)
                }
            }
        }
        //MARK: - Register Completion Page:
        public static func registerCompletion(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                let t = request.session?.data["csrf"] as? String ?? ""
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
                var context: [String : Any] = appExtras(request)
                
                if let v = request.param(name: "passvalidation"), !(v as String).isEmpty {
                    
                    let acc = Account(validation: v)
                    
                    if acc.id.isEmpty {
                        context["msg_title"] = "Account Validation Error."
                        context["msg_body"] = ""
                        response.render(template: "views/msg", context: context)
                        return
                    } else {
                        
                        if let p1 = request.param(name: "p1"), !(p1 as String).isEmpty,
                            let p2 = request.param(name: "p2"), !(p2 as String).isEmpty,
                            p1 == p2 {
                            acc.makePassword(p1)
                            if acc.usertype == .provisional {
                                acc.usertype = .standard
                            }
                            //                            acc.usertype = .standard
                            acc.detail["isNew"] = true
                            
                            if let _ = acc.detail["created"] {
                                acc.detail["modified"] = CCXServiceClass.sharedInstance.getNow()
                            } else {
                                acc.detail["created"] = CCXServiceClass.sharedInstance.getNow()
                            }
                            
                            do {
                                try acc.save()
                                
                                // check with stages 
                                UserAPI.UserSuccessfullyCreated(acc)
                                
                                request.session?.userid = acc.id
                                context["msg_title"] = "Account Validated and Completed."
                                context["msg_body"] = "<p><a class=\"button\" href=\"/\">Click to continue</a></p>"
                                response.render(template: "views/msg", context: context)
                                
                            } catch {
                                print(error)
                            }
                        } else {
                            context["msg_body"] = "<p>Account Validation Error: The passwords must not be empty, and must match.</p>"
                            context["passvalidation"] = v
                            context["csrfToken"] = t
                            response.render(template: "views/registerComplete", context: context)
                            return
                        }
                        
                    }
                } else {
                    context["msg_title"] = "Account Validation Error."
                    context["msg_body"] = "Code not found."
                    response.render(template: "views/msg", context: context)
                }
            }
        }
        //MARK: - Forgot Password Validation Page:
        public static func forgotpassVerify(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                let t = request.session?.data["csrf"] as? String ?? ""
                
                var context: [String : Any] = appExtras(request)
                
                if let v = request.urlVariables["passvalidation"], !(v as String).isEmpty {
                    
                    let acc = Account(validation: v)
                    
                    if acc.id.isEmpty {
                        context["msg_title"] = "Account Validation Error."
                        context["msg_body"] = ""
                        response.render(template: "views/msg", context: context)
                        return
                    } else {
                        context["passvalidation"] = v
                        context["csrfToken"] = t
                        response.render(template: "views/forgotpasswordComplete", context: context)
                    }
                } else {
                    context["msg_title"] = "Account Validation Error."
                    context["msg_body"] = "Code not found."
                    response.render(template: "views/msg", context: context)
                }
            }
        }
        //MARK: - Forgot Password Completion Page:
        public static func forgotpasswordCompletion(data: [String:Any]) throws -> RequestHandler {
            return {
                request, response in
                let t = request.session?.data["csrf"] as? String ?? ""
                if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
            
                var context: [String : Any] = appExtras(request)
                
                if let v = request.param(name: "passvalidation"), !(v as String).isEmpty {
                    
                    let acc = Account(validation: v)
                    
                    if acc.id.isEmpty {
                        context["msg_title"] = "Account Validation Error."
                        context["msg_body"] = ""
                        response.render(template: "views/msg", context: context)
                        return
                    } else {
                        
                        if let p1 = request.param(name: "p1"), !(p1 as String).isEmpty,
                            let p2 = request.param(name: "p2"), !(p2 as String).isEmpty,
                            p1 == p2 {
                            acc.makePassword(p1)
                            if acc.usertype == .provisional {
                                acc.usertype = .standard
                            }
                            //                        acc.usertype = .standard
                            acc.detail["modified"] = CCXServiceClass.sharedInstance.getNow()
                            acc.passvalidation.removeAll()
                            do {
                                try acc.save()
                                request.session?.userid = acc.id
                                context["msg_title"] = "You successfully changed your password!"
                                //                           context["msg_body"] = "<p><a class=\"button\" href=\"/\">Click to continue</a></p>"
                                response.render(template: "views/msg", context: context)
                                
                            } catch {
                                print(error)
                            }
                        } else {
                            context["msg_body"] = "<p>Account Validation Error: The passwords must not be empty, and must match.</p>"
                            context["passvalidation"] = v
                            context["csrfToken"] = t
                            response.render(template: "views/forgotpasswordComplete", context: context)
                            return
                        }
                        
                    }
                } else {
                    context["msg_title"] = "Account Validation Error."
                    context["msg_body"] = "Code not found."
                    response.render(template: "views/msg", context: context)
                }
            }
        }
        
    }
    
    //MARK: Update current location to the user
    /**
     This function will parse the location from the dictionary, add it to the user detail and add a record in the use location table.
     - parameter user: The user account that should be changed.
     - parameter locationJSON: A dictionary in the following format:
     ["currentlocation":["latitude":33.1234567, "longitude":-77.7654321]]
     - return Account: The user with the added detail section for current location.
     */
    static func addCurrentLocationToUser(_ user: Account, locationJSON: [String:Any]) -> Account {
        
        // did they pass in the location?
        if var loc:[String:Any] = locationJSON["currentlocation"] as? [String : Any], let latitude = loc["latitude"].doubleValue, let longitude = loc["longitude"].doubleValue  {
            do {
                // ok -- we are updating the location
                if loc["distance"].doubleValue.isNotNil {
                    loc.removeValue(forKey: "distance")
                }
                user.detail["currentlocation"] = loc
                try user.saveWithGIS(user.id)
                
                // now lets add a current location record
                let ul = UserLocation()
                ul.geopoint = CCXGeographyPoint(latitude: latitude, longitude: longitude)
                ul.geopointtime = CCXServiceClass.sharedInstance.getNow()
                //MARK:-
                //MARK: CHECK USER ID FOR NEW USERS
                //MARK:-
                ul.user_id = user.id
                try ul.saveWithGIS(user.id)    // note: this is the account table - audit fields are in the detail
                
                // lets see if the user needs something with location
                if let attn = user.detail["locationAttention"].boolValue, attn {

                    // ok -- lets send the welcome capsule
                    var params:[String: Any] = [:]
                    params["userid"] = user.id
                    params["geopoint"] = ["latitude":latitude, "longitude":longitude]
                    
                    //MARK:-
                    //MARK: Fire off the process for the project that performs an ation when the
                    //  location is updated for the current user.
                    //MARK:-
                    
                    // update the useer to return
                    try user.get(user.id)
                }
            } catch {
                // don't really do anything as this should not stop the show :)
            }
        }
        
        return user
        
    }
    
    @discardableResult
    static func UserSuccessfullyCreated(_ user:Account)->[String:Any] {
        
        var returnDict:[String:Any] = [:]
        
        // call stages and return the user associations
        let results = StagesConnecter.sharedInstance.associateUsers(user)
        for (key,value) in results {
            returnDict[key] = value
        }
        
        return returnDict
    }
}


//MARK: Supporting Functions:
func extras(_ request: HTTPRequest) -> [String : Any] {
    
    return [
        "token": request.session?.token ?? "",
        "csrfToken": request.session?.data["csrf"] as? String ?? ""
    ]
    
}

func appExtras(_ request: HTTPRequest) -> [String : Any] {
    var priv = ""
    var isAdmin = false
    
    let id = request.session?.userid ?? ""
    if !id.isEmpty {
        let user = Account()
        try? user.get(id)
        priv = "\(user.usertype)"
        if user.usertype == .admin {
            isAdmin = true
        }
    }
    return [
        "title": CCXServiceClass.sharedInstance.displayTitle,
        "subtitle": CCXServiceClass.sharedInstance.displaySubTitle,
        "logo": CCXServiceClass.sharedInstance.displayLogo,
        "srcset": CCXServiceClass.sharedInstance.displayLogoSrcSet,
        "priv": priv,
        "admin": isAdmin
    ]
    
}
//MARK: - Oauth Support:
typealias JSONOAuthReturn = (passed: Bool, data: [String:Any], foreignuserid : String)
struct FacebookOAuth  {
    func verifyCredentials(_ data : [String:Any]) throws -> JSONOAuthReturn {
        if let access_token = data.facebook["access_token"].stringValue, let userid = data.facebook["id"].stringValue {
            
            var fbdata = getFBData(access_token, fields: ["id", "first_name", "last_name","email", "picture.width(500).height(500).as(large_picture)", "picture.width(75).height(75).as(small_picture)"])
            
            // Overwrite the fbData dictionary to normalize it for the createOrLogin function.
            if let smallpic = fbdata["small_picture"].dicValue["data"].dicValue["url"].stringValue {
                fbdata["small_picture"] = smallpic
            }
            if let largepic = fbdata["large_picture"].dicValue["data"].dicValue["url"].stringValue {
                fbdata["large_picture"] = largepic
            }
            if fbdata["first_name"].isNotNil {
                fbdata["firstname"] = fbdata["first_name"]
                fbdata.removeValue(forKey: "first_name")
            }
            if fbdata["last_name"].isNotNil {
                fbdata["lastname"] = fbdata["last_name"]
                fbdata.removeValue(forKey: "last_name")
            }
            if fbdata["email"].isNotNil {
                fbdata["email_verified"] = true
            }
            
            return (userid == fbdata["id"].stringValue, fbdata, userid)
            
        }
        return (false, [:], "")
    }
    func getFBData(_ accessToken : String, fields : [String]) -> [String:Any] {
        let checkURL = "https://graph.facebook.com/v2.8/me?fields=\(fields.joined(separator: "%2C"))&access_token=\(accessToken)"
        // Okay lets make sure it matches the id passed in:
        return Utility2.makeRequest(.get, checkURL)
    }
}

struct GoogleOAuth {
    func verifyCredentials(_ data : [String:Any]) throws -> JSONOAuthReturn {
        if let access_token = data.google["access_token"].stringValue, let userid = data.google["id"].stringValue {
            
            var googleData = getGoogleData(access_token, ["family_name","given_name","id","picture"])
            
            var returnedGoogleData : [String:Any] = [:]
            // Lets normalize the dictionary for the createOrLogin user function.
            if !googleData.isEmpty {
                if googleData["sub"].isNotNil {
                    returnedGoogleData["id"] = googleData["sub"]
                }
                if googleData["email"].isNotNil {
                    returnedGoogleData["email"] = googleData["email"]
                }
                if googleData["email_verified"].isNotNil {
                    returnedGoogleData["email_verified"] = googleData["email_verified"]
                }
                if googleData["family_name"] != nil {
                    returnedGoogleData["lastname"] = googleData["family_name"]
                }
                if googleData["given_name"] != nil {
                    returnedGoogleData["firstname"] = googleData["given_name"]
                }
                if let pictureURL = googleData["picture"].stringValue {
                    // Append the other sizes:
                    returnedGoogleData["small_picture"] = pictureURL.appending("?sz=75")
                    returnedGoogleData["large_picture"] = pictureURL.appending("?sz=500")
                }
            }
            
            return (userid == returnedGoogleData["id"].stringValue, returnedGoogleData, userid)
            
        }
        
        return (false,[:], "")
    }
    func getGoogleData(_ accessToken : String, _ fields: [String]) -> [String:Any] {
        
        let url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=\(accessToken)"
        return Utility2.makeRequest(.get, url)
        
    }
}
    
struct TwitterOAuth {
    func verifyCredentials(_ data : [String:Any]) throws -> JSONOAuthReturn {
        if let access_token = data.twitter["access_token"].stringValue, let userid = data.twitter["id"].stringValue {
            
            let twitterData = self.getTwitterData(access_token)
            
            print(twitterData)
            
            // We need to go and fetch the user data. For now we will send it in from the frontend.
            return (false,[:],userid)
            
        }
        return (false,[:], "")
    }
    func getTwitterData(_ accessToken : String) -> [String:Any] {
        
        //       let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
        
        let url = "https://api.twitter.com/oauth2/token"
        
        let postBody = try? ["token_type" : "bearer", "access_token" : "\(accessToken)"].jsonEncodedString()
        if postBody.isEmptyOrNil {
            return [:]
        }
        //        var request = NSMutableURLRequest(url: URL(string: url)!)
        //        request.setValue("Authorization", forHTTPHeaderField: "Basic \(accessToken)")
        //        request.setValue("Content-Type", forHTTPHeaderField: "application/x-www-form-urlencoded;charset=UTF-8")
        //        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("Authorization", forHTTPHeaderField: "Basic \(accessToken)")
        request.addValue("Content-Type", forHTTPHeaderField: "application/x-www-form-urlencoded;charset=UTF-8")
        request.httpMethod = "POST"
        
        request.httpBody = postBody!.data(using: .utf8)
        
        //exchange(authorizationCode: AuthorizationCode(code: accessToken, redirectURL: ""))
        
        
        return [:]
        
        //      return Utility.makeRequest(.post, url, body: postBody!, encoding: "UTF-8", bearerToken: "")
    }
}
extension Account {
    var asDictionary : [String:Any] {
        
        var dic = self.results.rows.first?.data ?? [:]
        
        switch self.source {
        case "local":
            if self.detail["isNew"].isNotNil {
                self.detail.removeValue(forKey: "isNew")
                dic["detail"].dicValue.removeValue(forKey: "isNew")
                dic["isNew"] = true
                try! self.save()
            }
        default:
            if self.detail["isNew"].isNotNil, self.detail["isNew"].boolValue == true {
                dic["isNew"] = true
            }
        }
        
        // Remove out the keys that we dont need:
        if dic.count == 1 || dic.isEmpty {
            let addinIsnew = dic.count == 1
            try? self.find(["id":self.id])
            dic = self.results.rows.first?.data ?? [:]
            if addinIsnew {
                dic["isNew"] = true
            }
        }
        // Remove out the password & pass validation:
        dic.removeValue(forKey: "password")
        dic.removeValue(forKey: "passvalidation")
        
        // Get all the users friends:
        let sqlStatement = ""
        let friends = try? self.sqlRows("", params: [])
        
        return dic
    }
    class func loginWithEmail(_ email : String, _ password : String) throws -> Account {
        if let digestBytes = password.digest(.sha256),
            let hexBytes = digestBytes.encode(.hex),
            let hexBytesStr = String(validatingUTF8: hexBytes) {
            
            let acc = Account()
            let criteria = ["email":email,"password":hexBytesStr]
            do {
                try acc.find(criteria)
                if acc.usertype == .provisional {
                    throw OAuth2ServerError.loginError
                }
                return acc
            } catch {
                print(error)
                throw OAuth2ServerError.loginError
            }
        } else {
            throw OAuth2ServerError.loginError
        }
    }
    
    public static func adminBounce(_ request: HTTPRequest, _ response: HTTPResponse) {
        let user = Account()
        do {
            try user.get(request.session?.userid ?? "")
            if user.usertype != .admin {
                response.redirect(path: "/")
            }
        } catch {
            print(error)
        }
    }
    
}
