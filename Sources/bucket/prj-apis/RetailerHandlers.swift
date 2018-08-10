
//import SwiftMoment
import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication

extension Handlers {

    static func terminalDelete(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            // Verify Retailer
            Retailer.retailerBounce(request, response)
            
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

    static func terminalAdd(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in

//            let contextAccountID = request.session?.userid ?? ""
//            let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
//            if !contextAuthenticated { response.redirect(path: "/login") }
//
//            // Verify Admin
//            Account.adminBounce(request, response)
//
//            let users = Account.listUsers()
//
//            var context: [String : Any] = [
//                "accountID": contextAccountID,
//                "authenticated": contextAuthenticated,
//                "userlist?":"true",
//                "users": users
//            ]
//            if contextAuthenticated {
//                for i in Handlers.extras(request) {
//                    context[i.0] = i.1
//                }
//            }
//            // add app config vars
//            for i in Handlers.appExtras(request) {
//                context[i.0] = i.1
//            }
//            response.renderMustache(template: request.documentRoot + "/views/users.mustache", context: context)
        }
    }

    static func terminalTransaction(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in

            // Verify Retailer
            Retailer.retailerBounce(request, response)
            
            // pull the terminal information
            var thedata:[String:Any] = [:]
            
            
            
            
            // create the customer code
            let ccode = Retailer().createCustomerCode(thedata)

            // setup the JSON return
            var returnJSON = "{ \"test\":TRUE, \"code\": \"\(ccode)\" }"

            
            
            
            try? response.setBody(json: returnJSON)
            
            // return
            response.completed(status: .ok)
        }
    }

    static func terminalCloseInterval(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in

            // add the close interval here
            
        }
    }

    
}
