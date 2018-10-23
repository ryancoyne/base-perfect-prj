//
//  BadgeTable.swift
//

import Foundation
import PostgresStORM

final class FriendsTableViews {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }

    static let sharedInstance = FriendsTableViews()
    let tbl = Friends()

    let friendView1     = 1.00
    let friendFunction1 = 1.00
    let friendFunction2 = 1.00
    let friendFunction3 = 1.00
    let friendFunction4 = 1.00
    let friendFunction5 = 1.00
    let friendFunction6 = 1.00

    //MARK:-
    //MARK: create the table
    func create() {
    
        // make sure the table level is correct
        let config = Config()

        var thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr1 = try? config.sqlRows(thesql, params: ["view_\(tbl.table())_1"])
        if tr1.isNotNil, let tr = tr1 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != friendView1 {
                    // update to the new installation
                    self.updateFriendView1(currentlevel: testval!)
                }
            } else {
            
                do {
                    try tbl.sqlRows(self.createFriendView1(), params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }

                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('view_\(tbl.table())_1','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr2 = try? config.sqlRows(thesql, params: ["function_\(tbl.table())_1"])
        if tr2.isNotNil, let tr = tr2 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != friendFunction1 {
                    // update to the new installation
                    self.updateFriendFunction1(currentlevel: testval!)
                }
            } else {
            
                do {
                    try tbl.sqlRows(self.createFriendFunction1(), params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }

                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('function_\(tbl.table())_1','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr3 = try? config.sqlRows(thesql, params: ["function_\(tbl.table())_2"])
        if tr3.isNotNil, let tr = tr3 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != friendFunction2 {
                    // update to the new installation
                    self.updateFriendFunction2(currentlevel: testval!)
                }
            } else {
                do {
                    try tbl.sqlRows(self.createFriendFunction2(), params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }

                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('function_\(tbl.table())_2','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr4 = try? config.sqlRows(thesql, params: ["function_\(tbl.table())_3"])
        if tr4.isNotNil, let tr = tr4 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != friendFunction3 {
                    // update to the new installation
                    self.updateFriendFunction3(currentlevel: testval!)
                }
            } else {
                
                do {
                    try tbl.sqlRows(self.createFriendFunction3(), params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }

                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('function_\(tbl.table())_3','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr5 = try? config.sqlRows(thesql, params: ["function_\(tbl.table())_4"])
        if tr5.isNotNil, let tr = tr5 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != friendFunction4 {
                    // update to the new installation
                    self.updateFriendFunction4(currentlevel: testval!)
                }
            } else {
            
                do {
                    try tbl.sqlRows(self.createFriendFunction4(), params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }

                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('function_\(tbl.table())_4','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr6 = try? config.sqlRows(thesql, params: ["function_\(tbl.table())_5"])
        if tr6.isNotNil, let tr = tr6 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != friendFunction5 {
                    // update to the new installation
                    self.updateFriendFunction5(currentlevel: testval!)
                }
            } else {
            
                do {
                    try tbl.sqlRows(self.createFriendFunction5(), params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }
                
                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('function_\(tbl.table())_5','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }
            }
        }
        
        thesql = "SELECT val, name FROM config WHERE name = $1"
        let tr7 = try? config.sqlRows(thesql, params: ["function_\(tbl.table())_6"])
        if tr7.isNotNil, let tr = tr7 {
            if tr.count > 0 {
                let testval = Double(tr[0].data["val"] as! String)
                if testval != friendFunction6 {
                    // update to the new installation
                    self.updateFriendFunction6(currentlevel: testval!)
                }
            } else {
            
                do {
                    try tbl.sqlRows(self.createFriendFunction6(), params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }

                do {
                    // new one - set the default 1.00
                    thesql = "INSERT INTO config(name,val) VALUES('function_\(tbl.table())_6','1.00')"
                    try config.sqlRows(thesql, params: [])
                } catch {
                    print("Error in FriendsTableViews.create(): \(error)")
                }
            }
        }

    }

    private func updateFriendView1(currentlevel: Double) {
        
        let tbl = Friends()
        
        // PERFORM THE UPDATE ACCORDING TO REQUIREMENTS
        print("UPDATE VIEW \(tbl.table().capitalized) 1.  Current Level \(currentlevel), Required Level: \(friendView1)")
        
    }
    
    private func updateFriendFunction1(currentlevel: Double) {
        
        let tbl = Friends()
        
        // PERFORM THE UPDATE ACCORDING TO REQUIREMENTS
        print("UPDATE FUNCTION \(tbl.table().capitalized) 1.  Current Level \(currentlevel), Required Level: \(friendFunction1)")
        
    }
    
    private func updateFriendFunction2(currentlevel: Double) {
        
        let tbl = Friends()
        
        // PERFORM THE UPDATE ACCORDING TO REQUIREMENTS
        print("UPDATE FUNCTION \(tbl.table().capitalized) 2.  Current Level \(currentlevel), Required Level: \(friendFunction2)")
        
    }
    
    private func updateFriendFunction3(currentlevel: Double) {
        
        let tbl = Friends()
        
        // PERFORM THE UPDATE ACCORDING TO REQUIREMENTS
        print("UPDATE FUNCTION \(tbl.table().capitalized) 3.  Current Level \(currentlevel), Required Level: \(friendFunction3)")
        
    }
    
    private func updateFriendFunction4(currentlevel: Double) {
        
        let tbl = Friends()
        
        // PERFORM THE UPDATE ACCORDING TO REQUIREMENTS
        print("UPDATE FUNCTION \(tbl.table().capitalized) 4.  Current Level \(currentlevel), Required Level: \(friendFunction4)")
        
    }
    
    private func updateFriendFunction5(currentlevel: Double) {
        
        let tbl = Friends()
        
        // PERFORM THE UPDATE ACCORDING TO REQUIREMENTS
        print("UPDATE FUNCTION \(tbl.table().capitalized) 5.  Current Level \(currentlevel), Required Level: \(friendFunction5)")
        
    }
    
    private func updateFriendFunction6(currentlevel: Double) {
        
        let tbl = Friends()
        
        // PERFORM THE UPDATE ACCORDING TO REQUIREMENTS
        print("UPDATE FUNCTION \(tbl.table().capitalized) 6.  Current Level \(currentlevel), Required Level: \(friendFunction6)")
        
    }
    
    private func createFriendView1()-> String {
        
        let createsql = "CREATE VIEW friends_invited AS SELECT id, user_id, friend_id FROM friend WHERE (accepted = 0) AND (invited > 0); "
        
        print(createsql)
        
        return createsql
    }
    
    private func createFriendFunction1()-> String {
        
        var createsql = ""
        
        createsql.append("CREATE OR REPLACE FUNCTION friends_true(parm1 text, parm2 text) ")
        createsql.append("RETURNS TABLE (id integer, user_id text, friend_id text) ")
        createsql.append("AS ")
        createsql.append("$body$ ")
        
        createsql.append("SELECT id, user_id, friend_id ")
        createsql.append("FROM friend ")
        createsql.append("WHERE ((user_id = $1 AND friend_id = $2) ")
        createsql.append("OR (user_id = $2 AND friend_id = $1)) ")
        createsql.append("AND (accepted > 0) ")
        
        createsql.append("$body$ ")
        createsql.append("LANGUAGE sql; ")
        
        print(createsql)
        
        return createsql
    }
    
    private func createFriendFunction2()-> String {
        
        var createsql = ""
        
        createsql.append("CREATE OR REPLACE FUNCTION friends_rejected(parm1 text, parm2 text) ")
        createsql.append("RETURNS TABLE (id integer, user_id text, friend_id text) ")
        createsql.append("AS ")
        createsql.append("$body$ ")
        
        createsql.append("SELECT id, user_id, friend_id ")
        createsql.append("FROM friend ")
        createsql.append("WHERE ((user_id = $1 AND friend_id = $2) ")
        createsql.append("OR (user_id = $2 AND friend_id = $1)) ")
        createsql.append("AND (rejected > 0) ")
        
        createsql.append("$body$ ")
        createsql.append("LANGUAGE sql; ")
        
        print(createsql)
        
        return createsql
    }
    
    private func createFriendFunction3()-> String {
        
        var createsql = ""
        
        createsql.append("CREATE OR REPLACE FUNCTION friends_pending_all(parm1 text) ")
        createsql.append("RETURNS TABLE (id integer, user_id text, friend_id text) ")
        createsql.append("AS ")
        createsql.append("$body$ ")
        createsql.append("SELECT id, user_id, friend_id FROM friend ")
        createsql.append("WHERE (invited > 0) AND (friend_id = $1) ")
        createsql.append("AND (rejected ISNULL OR NOT (rejected > 0)) ")
        createsql.append("AND (accepted ISNULL OR NOT (accepted > 0)) ")
        createsql.append("$body$ ")
        createsql.append("LANGUAGE sql; ")
        
        print(createsql)
        
        return createsql
    }
    
    private func createFriendFunction4()-> String {
        
        var createsql = ""
        
        createsql.append("CREATE OR REPLACE FUNCTION friends_pending(parm1 text, parm2 text) ")
        createsql.append("RETURNS TABLE (id integer, user_id text, friend_id text) ")
        createsql.append("AS ")
        createsql.append("$body$ ")
        createsql.append("SELECT id, user_id, friend_id FROM friend ")
        createsql.append("WHERE ((user_id = $1) AND (friend_id = $2)) ")
        createsql.append("AND (invited > 0)AND (rejected ISNULL OR NOT (rejected > 0)) ")
        createsql.append("AND (accepted ISNULL OR NOT (accepted > 0)) ")
        createsql.append("$body$ ")
        createsql.append("LANGUAGE sql; ")
        
        print(createsql)
        
        return createsql
    }
    
    private func createFriendFunction5()-> String {
        
        var createsql = ""
        
        createsql.append("CREATE OR REPLACE FUNCTION friends_in_table(parm1 text, parm2 text) ")
        createsql.append("RETURNS boolean ")
        createsql.append("AS ")
        createsql.append("$body$ ")
        createsql.append("BEGIN ")
        createsql.append("PERFORM id FROM friend ")
        createsql.append("WHERE ((user_id = $1) AND (friend_id = $2)) OR ((user_id = $2) AND (friend_id = $1)); ")
        createsql.append("RETURN FOUND; ")
        createsql.append("END ")
        createsql.append("$body$ ")
        createsql.append("LANGUAGE plpgsql; ")
        
        print(createsql)
        
        return createsql
    }
    
    private func createFriendFunction6()-> String {
        
        var createsql = ""
        
        createsql.append("CREATE OR REPLACE FUNCTION friends_true_all(parm1 text) ")
        createsql.append("RETURNS TABLE (id integer, user_id text, friend_id text) ")
        createsql.append("AS ")
        createsql.append("$body$ ")
        createsql.append("SELECT id, user_id, friend_id ")
        createsql.append("FROM friend ")
        createsql.append("WHERE (user_id = $1 OR friend_id = $1) ")
        createsql.append("AND (accepted > 0) ")
        createsql.append("AND (rejected ISNULL OR NOT (rejected > 0)) ")
        createsql.append("$body$ ")
        createsql.append("LANGUAGE sql; ")
        
        print(createsql)
        
        return createsql
    }
}
