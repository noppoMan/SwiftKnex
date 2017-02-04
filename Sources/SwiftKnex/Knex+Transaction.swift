//
//  Knex+Transaction.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

extension Knex {
    
    public func transaction(_ callback: (Connection) throws -> Void) throws {
        try self.connection.transaction { trx in
            try callback(trx)
        }
    }
    
}
