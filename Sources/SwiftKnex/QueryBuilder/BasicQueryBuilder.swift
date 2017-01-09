//
//  QueryBuilder.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

struct BasicQueryBuilder: QueryBuilder {
    
    enum QueryType {
        case select
        case delete
    }
    
    let type: QueryType
    
    let table: String
    
    let condistions: [ConditionConnector]
    
    let limit: Limit?
    
    let orders: [OrderBy]
    
    let group: GroupBy?
    
    let having: Having?
    
    let joins: [Join]
    
    let selectFields: [Field]
    
    func build() -> (String, [Any]) {
        let condistionQuery = condistions.build()
        var bindParams = condistions.bindParams()
        let groupQuery = group != nil ? group!.build() : ""
        var havingQuery = ""
        if let having = self.having {
            havingQuery = having.build()
            bindParams.append(contentsOf:  having.condition.toBindParams())
        }
        let limitQuery = limit != nil ? limit!.build() : ""
        
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
        sql += insertSpace(joins.build())
        sql += insertSpace(condistionQuery)
        sql += insertSpace(groupQuery)
        sql += insertSpace(havingQuery)
        sql += insertSpace(orders.build())
        sql += insertSpace(limitQuery)
        sql += ";"
        
        return (sql, bindParams)
    }
}
