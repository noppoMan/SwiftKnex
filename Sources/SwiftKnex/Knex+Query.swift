//
//  Knex+Write.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

extension Knex {
    public func fetch(trx: Connection? = nil) throws -> ResultSet? {
        return try execute(.select, trx).asResultSet()
    }
    
    public func insert(into table: String, collection: [[String: Any]], trx: Connection? = nil) throws -> QueryStatus? {
        queryBuilder.table(table)
        
        
        //queryBuilder.where(("id" == 1 && ("id" == 1)) || ("id" == 1))
        
        return try execute(.batchInsert(collection), trx).asQueryStatus()
    }
    
    public func insert(into table: String, values: [String: Any], trx: Connection? = nil) throws -> QueryStatus? {
        queryBuilder.table(table)
        return try execute(.insert(values), trx).asQueryStatus()
    }
    
    public func update(sets: [String: Any], trx: Connection? = nil) throws -> QueryStatus? {
        return try execute(.update(sets), trx).asQueryStatus()
    }
    
    public func delete(trx: Connection? = nil) throws -> QueryStatus? {
        return try execute(.delete, trx).asQueryStatus()
    }
    
    private func execute(_ type: QueryType, _ trx: Connection?) throws -> QueryResult {
        let (sql, bindParams) = try queryBuilder.build(type).build()
        
        let result: QueryResult
        if let trx = trx {
            result = try trx.query(sql, bindParams: bindParams)
        } else {
            result = try connection.query(sql, bindParams: bindParams)
        }
        
        return result
    }
}

