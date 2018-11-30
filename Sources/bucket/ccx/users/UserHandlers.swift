
//import SwiftMoment
import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication

extension Handlers {

    static func userDelete(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.SecurityCheck() else { response.badSecurityToken; return }

            if (request.session?.userid ?? "").isEmpty { response.completed(status: .notAcceptable); return }
            
            // Verify Admin
            Account.adminBounce(request, response)
            
            let user = Account()
            
            if let id = request.urlVariables["id"] {
                try? user.get(id)
                
                // cannot delete yourself
                if user.id == (request.session?.userid ?? "") {
                    errorJSON(request, response, msg: "You cannot delete yourself.")
                    return
                }
                let usersCount = Account()
                try? usersCount.findAll()
                if usersCount.results.cursorData.totalRecords <= 1 {
                    errorJSON(request, response, msg: "You cannot delete yourself.")
                    return
                }
                
                if user.id.isEmpty {
                    errorJSON(request, response, msg: "Invalid User")
                } else {
                    try? user.delete()
                }
            }
            
            response.setHeader(.contentType, value: "application/json")
            var resp = [String: Any]()
            resp["error"] = "None"
            do {
                try response.setBody(json: resp)
            } catch {
                print("error setBody: \(error)")
            }
            response.completed(status: .ok)
            return
        }
    }

    static func userList(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.SecurityCheck() else { response.badSecurityToken; return }

            let contextAccountID = request.session?.userid ?? ""
            let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
            if !contextAuthenticated { response.redirect(path: "/login"); response.completed(); return }
            
            // Verify Admin
            Account.adminBounce(request, response)
            
            let users = Account.listUsers()
            
            var context: [String : Any] = [
                "accountID": contextAccountID,
                "authenticated": contextAuthenticated,
                "userlist?":"true",
                "users": users
            ]
            if contextAuthenticated {
                for i in Handlers.extras(request) {
                    context[i.0] = i.1
                }
            }
            // add app config vars
            for i in Handlers.appExtras(request) {
                context[i.0] = i.1
            }
            response.renderMustache(template: request.documentRoot + "/views/users.mustache", context: context)
            response.completed()
            return
        }
    }

    static func userMod(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.SecurityCheck() else { response.badSecurityToken; return }

            let contextAccountID = request.session?.userid ?? ""
            let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
            if !contextAuthenticated { response.redirect(path: "/login"); response.completed(); return }
            
            // Verify Admin
            Account.adminBounce(request, response)
            
            let user = Account()
            var action = "Create"
            
            if let id = request.urlVariables["id"] {
                try? user.get(id)
                
                if user.id.isEmpty {
                    redirectRequest(request, response, msg: "Invalid User", template: request.documentRoot + "/views/user.mustache")
                }
                
                action = "Edit"
            }
            
            
            var context: [String : Any] = [
                "accountID": contextAccountID,
                "authenticated": contextAuthenticated,
                "usermod?":"true",
                "action": action,
                "username": user.username,
                "firstname": user.detail["firstname"] ?? "",
                "lastname": user.detail["lastname"] ?? "",
                "email": user.email,
                "id": user.id
            ]
            
            switch user.usertype {
            case .standard:
                context["usertypestandard"] = " selected=\"selected\""
            case .admin:
                context["usertypeadmin"] = " selected=\"selected\""
            case .admin1:
                context["usertypeadmin1"] = " selected=\"selected\""
            case .admin2:
                context["usertypeadmin2"] = " selected=\"selected\""
            case .admin3:
                context["usertypeadmin3"] = " selected=\"selected\""
            case .inactive:
                context["usertypeinactive"] = " selected=\"selected\""
            default:
                context["usertypeprovisional"] = " selected=\"selected\""
            }
            
            if contextAuthenticated {
                for i in Handlers.extras(request) {
                    context[i.0] = i.1
                }
            }
            // add app config vars
            for i in Handlers.appExtras(request) {
                context[i.0] = i.1
            }
            response.renderMustache(template: request.documentRoot + "/views/users.mustache", context: context)
            response.completed()
            return
        }
    }

    static func userModAction(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            // check for the security token - this is the token that shows the request is coming from CloudFront and not outside
            guard request.SecurityCheck() else { response.badSecurityToken; return }

            let contextAccountID = request.session?.userid ?? ""
            let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
            if !contextAuthenticated { response.redirect(path: "/login"); response.completed(); return }
            
            // Verify Admin
            Account.adminBounce(request, response)
            
            let user = Account()
            var msg = ""
            
            if let id = request.urlVariables["id"] {
                try? user.get(id)
                
                if user.id.isEmpty {
                    redirectRequest(request, response, msg: "Invalid User", template: request.documentRoot + "/views/user.mustache")
                }
            }
            
            
            if let firstname = request.param(name: "firstname"), !firstname.isEmpty,
                let lastname = request.param(name: "lastname"), !lastname.isEmpty,
                let email = request.param(name: "email"), !email.isEmpty,
                let username = request.param(name: "username"), !username.isEmpty{
                user.username = username.lowercased()
                user.detail["firstname"] = firstname
                user.detail["lastname"] = lastname
                user.email = email
                
                
                if let pwd = request.param(name: "pw"), !pwd.isEmpty {
                    user.makePassword(pwd)
                }
                
                switch request.param(name: "usertype") ?? "" {
                case "standard":
                    user.usertype = .standard
                case "admin":
                    user.usertype = .admin
                case "admin1":
                    user.usertype = .admin1
                case "admin2":
                    user.usertype = .admin2
                case "admin3":
                    user.usertype = .admin3
                case "inactive":
                    user.usertype = .inactive
                default:
                    user.usertype = .provisional
                }
                
                if user.id.isEmpty {
                    user.makeID()
                    user.detail["created"] = CCXServiceClass.getNow()
                    
                    try? user.create()
                    
                    // lets see if we can link stages
                    UserAPI.UserSuccessfullyCreated(user)
                    
                } else {
                    user.detail["modified"] = CCXServiceClass.getNow()
                    try? user.save()
                }
                
            } else {
                msg = "Please enter the user's first and last name, as well as a valid email."
                redirectRequest(request, response, msg: msg, template: request.documentRoot + "/views/users.mustache", additional: [
                    "usermod?":"true",
                    ])
            }
            
            
            let users = Account.listUsers()
            
            var context: [String : Any] = [
                "accountID": contextAccountID,
                "authenticated": contextAuthenticated,
                "userlist?":"true",
                "users": users,
                "msg": msg
            ]
            if contextAuthenticated {
                for i in Handlers.extras(request) {
                    context[i.0] = i.1
                }
            }
            // add app config vars
            for i in Handlers.appExtras(request) {
                context[i.0] = i.1
            }
            
            response.renderMustache(template: request.documentRoot + "/views/users.mustache", context: context)
            response.completed()
            return
        }
    }

    
}
