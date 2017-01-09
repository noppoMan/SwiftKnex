//
//  Transaction.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

extension Connection {
    public func transaction(_ callback: (Connection) throws -> Void) throws {
        isUsed = true
        _ = try query("START TRANSACTION;")
        isTransacting = true
        
        do {
            try callback(self)
            _ = try query("COMMIT;")
            release()
        } catch {
            do {
                _ = try query("ROLLBACK;")
            } catch {
                release()
                throw error
            }
            release()
            throw error
        }
    }
}

extension ConnectionPool {
    
    public func transaction(_ callback: (Connection) throws -> Void) throws {
        let con = try getConnection()
        try con.transaction(callback)
    }
    
}
