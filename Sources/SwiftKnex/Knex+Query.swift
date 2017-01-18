//
//  Knex+Write.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

extension Knex {
    
    public func fetch(trx: Connection? = nil) throws -> ResultSet? {
        guard let table = self.table else {
            throw QueryBuilderError.tableIsNotSet
        }
        
        let builder = BasicQueryBuilder(
            type: .select,
            table: table,
            condistions: condistions,
            limit: limit,
            orders: orders,
            group: group,
            having: having,
            joins: joins,
            selectFields: selectFields
        )
        
        let (sql, bindParams) = builder.build()
        
        let result: QueryResult
        if let trx = trx {
            result = try trx.query(sql, bindParams: bindParams)
        } else {
            result = try connection.query(sql, bindParams: bindParams)
        }
        
        return result.asResultSet()
    }
    
    public func insert(into table: String, collection: [[String: Any]], trx: Connection? = nil) throws -> QueryStatus? {
        let builder = BatchInsertQueryBuilder(into: table, collection: collection)
        
        let (sql, bindParams) = builder.build()
        
        let result: QueryResult
        if let trx = trx {
            result = try trx.query(sql, bindParams: bindParams)
        } else {
            result = try connection.query(sql, bindParams: bindParams)
        }
        
        return result.asQueryStatus()
    }
    
    public func insert(into table: String, values: [String: Any], trx: Connection? = nil) throws -> QueryStatus? {
        let builder = InsertQueryBuilder(into: table, values: values)
        
        let (sql, bindParams) = builder.build()
        
        let result: QueryResult
        if let trx = trx {
            result = try trx.query(sql, bindParams: bindParams)
        } else {
            result = try connection.query(sql, bindParams: bindParams)
        }
        
        return result.asQueryStatus()
    }
    
    public func update(sets: [String: Any], trx: Connection? = nil) throws -> QueryStatus? {
        guard let table = self.table else {
            throw QueryBuilderError.tableIsNotSet
        }
        
        let builder = UpdateQueryBuilder(
            table: table,
            condistions: condistions,
            limit: limit,
            orders: orders,
            group: group,
            having: having,
            joins: joins,
            sets: sets
        )
        
        let (sql, bindParams) = builder.build()
        
        let result: QueryResult
        if let trx = trx {
            result = try trx.query(sql, bindParams: bindParams)
        } else {
            result = try connection.query(sql, bindParams: bindParams)
        }
        
        return result.asQueryStatus()
    }
    
    public func delete(trx: Connection? = nil) throws -> QueryStatus? {
        guard let table = self.table else {
            throw QueryBuilderError.tableIsNotSet
        }
        
        let builder = BasicQueryBuilder(
            type: .delete,
            table: table,
            condistions: condistions,
            limit: limit,
            orders: orders,
            group: group,
            having: having,
            joins: joins,
            selectFields: selectFields
        )
        
        let (sql, bindParams) = builder.build()
        
        let result: QueryResult
        if let trx = trx {
            result = try trx.query(sql, bindParams: bindParams)
        } else {
            result = try connection.query(sql, bindParams: bindParams)
        }
        
        return result.asQueryStatus()
    }
}

