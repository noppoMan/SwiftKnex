//
//  Knex+Write.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

extension Knex {
    
    private func execute(builder: QueryBuilder, connection: Connection) throws -> QueryResult {
        let (sql, bindParams) = builder.build()
        return try connection.query(sql, bindParams: bindParams)
    }
    
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
        
        return try execute(builder: builder, connection: trx ?? connection.getConnection()).asResultSet()
    }
    
    public func insert(into table: String, collection: [[String: Any]], trx: Connection? = nil) throws -> QueryStatus? {
        let builder = BatchInsertQueryBuilder(into: table, collection: collection)
        
        return try execute(builder: builder, connection: trx ?? connection.getConnection()).asQueryStatus()
    }
    
    public func insert(into table: String, values: [String: Any], trx: Connection? = nil) throws -> QueryStatus? {
        let builder = InsertQueryBuilder(into: table, values: values)
        
        return try execute(builder: builder, connection: trx ?? connection.getConnection()).asQueryStatus()
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
        
        return try execute(builder: builder, connection: trx ?? connection.getConnection()).asQueryStatus()
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
        
        return try execute(builder: builder, connection: trx ?? connection.getConnection()).asQueryStatus()
    }
}

