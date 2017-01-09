//
//  Knex+Read.swift
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
}
