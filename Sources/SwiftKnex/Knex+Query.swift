//
//  Knex+Write.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

extension Knex {
    
    public func fetch<T: CollectionType>(trx: Connection? = nil) throws -> T? {
        guard let rows = try execute(.select, trx).asResultSet() else {
            return nil
        }
        return try T(rows: rows)
    }
    
    public func fetch<T: Entity>(trx: Connection? = nil) throws -> [T] {
        let rows = try execute(.select, trx).asResultSet()
        return try rows?.map { try T(row: $0) } ?? []
    }
    
    public func fetch(trx: Connection? = nil) throws -> ResultSet? {
        return try execute(.select, trx).asResultSet()
    }
    
    public func insert(into table: String, collection: [Serializable], trx: Connection? = nil) throws -> QueryStatus {
        queryBuilder.table(table)
        
        return try execute(.batchInsert(collection.map({ try $0.serialize() })), trx).asQueryStatus() ?? QueryStatus()
    }
    
    public func insert(into table: String, collection: [[String: Any]], trx: Connection? = nil) throws -> QueryStatus {
        queryBuilder.table(table)
        
        return try execute(.batchInsert(collection), trx).asQueryStatus() ?? QueryStatus()
    }
    
    public func insert(into table: String, values: Serializable, trx: Connection? = nil) throws -> QueryStatus {
        queryBuilder.table(table)
        return try execute(.insert(values.serialize()), trx).asQueryStatus() ?? QueryStatus()
    }
    
    public func insert(into table: String, values: [String: Any], trx: Connection? = nil) throws -> QueryStatus {
        queryBuilder.table(table)
        return try execute(.insert(values), trx).asQueryStatus() ?? QueryStatus()
    }
    
    public func update(sets: [String: Any], trx: Connection? = nil) throws -> QueryStatus {
        return try execute(.update(sets), trx).asQueryStatus() ?? QueryStatus()
    }
    
    public func update(query: String, params: [Any] = [], trx: Connection? = nil) throws -> QueryStatus {
        return try execute(.updateRaw(query: query, params: params), trx).asQueryStatus() ?? QueryStatus()
    }
    
    public func delete(trx: Connection? = nil) throws -> QueryStatus {
        return try execute(.delete, trx).asQueryStatus() ?? QueryStatus()
    }
    
    private func execute(_ type: QueryType, _ trx: Connection?) throws -> QueryResult {
        let (sql, bindParams) = try queryBuilder.build(type).build()
        
        let result: QueryResult
        if let trx = trx {
            result = try trx.query(sql+";", bindParams: bindParams)
        } else {
            result = try connection.query(sql+";", bindParams: bindParams)
        }
        
        return result
    }
}

