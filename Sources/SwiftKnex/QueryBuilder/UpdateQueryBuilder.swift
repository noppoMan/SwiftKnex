//
//  UpdateQueryBuilder.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

struct UpdateQueryBuilder: QueryBuilder {
    
    let table: String
    
    let condistions: [ConditionConnector]
    
    let limit: Limit?
    
    let orders: [OrderBy]
    
    let group: GroupBy?
    
    let having: Having?
    
    let joins: [Join]
    
    let sets: [String: Any]
    
    func build() -> (String, [Any]) {
        let setQuery = sets.map({ "\($0.key) = ?" }).joined(separator: ", ")
        var bindParams = sets.map({ $0.value })
        
        let condistionQuery = condistions.build()
        bindParams.append(contentsOf: condistions.bindParams())
    
        let groupQuery = group != nil ? group!.build() : ""
        var havingQuery = ""
        if let having = self.having {
            havingQuery = having.build()
            bindParams.append(contentsOf:  having.condition.toBindParams())
        }
        
        let limitQuery = limit != nil ? limit!.build() : ""
        
        var sql = ""
        sql += "UPDATE"
        sql += insertSpace(table)
        sql += insertSpace(joins.build())
        sql += " SET \(setQuery)"
        sql += insertSpace(condistionQuery)
        sql += insertSpace(groupQuery)
        sql += insertSpace(havingQuery)
        sql += insertSpace(orders.build())
        sql += insertSpace(limitQuery)
        sql += ";"
        
        return (sql, bindParams)
    }
}
