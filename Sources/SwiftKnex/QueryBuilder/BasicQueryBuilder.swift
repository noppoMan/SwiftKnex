//
//  QueryBuilder.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

struct BasicQueryBuilder: QueryBuildable {
    
    enum QueryType {
        case select
        case delete
    }
    
    let type: QueryType
    
    let table: Table
    
    let condistions: [ConditionConnector]
    
    let limit: Limit?
    
    let orders: [OrderBy]
    
    let group: GroupBy?
    
    let having: Having?
    
    let joins: [Join]
    
    let selectFields: [Field]
    
    let alias: String?
    
    func build() throws -> (String, [Any]) {
        var bindParams = [Any]()
        let (table, params) = try self.table.build()
        bindParams.append(contentsOf: params)
        
        let condistionQuery = try condistions.build()
        try bindParams.append(contentsOf: condistions.bindParams())
        
        let groupQuery = try group != nil ? group!.build() : ""
        var havingQuery = ""
        if let having = self.having {
            havingQuery = try having.build()
            try bindParams.append(contentsOf:  having.condition.toBindParams())
        
        }
        let limitQuery = try limit != nil ? limit!.build() : ""
        
        var sql = ""
        
        switch type {
        case .select:
            let fieldsQuery = selectFields.count > 0 ? selectFields.map({ "\($0)"}).joined(separator: ", ") : "*"
            sql += "SELECT"
            sql += insertSpace(fieldsQuery)
        case .delete:
            sql += "DELETE"
        }
        
        sql += " FROM"
        sql += insertSpace(table)
        sql += try insertSpace(joins.build())
        sql += insertSpace(condistionQuery)
        sql += insertSpace(groupQuery)
        sql += insertSpace(havingQuery)
        sql += insertSpace(orders.build())
        sql += insertSpace(limitQuery)
        
        if let alias = alias {
            return ("(\((sql))) AS \(alias)", bindParams)
        }
        return (sql, bindParams)
    }
}
