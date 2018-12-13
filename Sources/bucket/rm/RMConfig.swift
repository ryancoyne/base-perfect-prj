//
//  CCXConfig.swift
//
//  Created by Ryan Coyne on 10/30/17.
//

import StORM
import PostgresStORM

public class RMConfig: PostgresStORM {
    public var name = ""
    public var val  = ""
    
    public static func getVal(_ key: String, _ def: String) -> String {
        print("RMConfig.swift: Config \(key)")
        let this = RMConfig()
        do {
            try this.get(key)
        } catch {
            print(error)
        }
        if this.val.isEmpty {
            return def
        }
        return this.val
    }
    
    public static func runSetup() {
        do {
            let this = RMConfig()
            try this.setup()

        } catch {
            print(error)
        }

    }
    
    override public func to(_ this: StORMRow) {
        name = this.data["name"] as? String ?? ""
        val = this.data["val"] as? String   ?? ""
    }
    
    public func rows() -> [RMConfig] {
        var rows = [RMConfig]()
        for i in 0..<self.results.rows.count {
            let row = RMConfig()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
}
