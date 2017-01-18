//
//  UpdateQueryBuilder.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

struct UpdateQueryBuilder: QueryBuildable {
    
    let table: Table
    
    let condistions: [ConditionConnector]
    
    let limit: Limit?
    
    let orders: [OrderBy]
    
    let group: GroupBy?
    
    let having: Having?
    
    let joins: [Join]
    
    let sets: [String: Any]
    
    func build() throws -> (String, [Any]) {
        let setQuery = sets.map({ "\($0.key) = ?" }).joined(separator: ", ")
        var bindParams = sets.map({ $0.value })
        
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
        sql += "UPDATE"
        sql += try insertSpace(table.build().0)
        try sql += insertSpace(joins.build())
        sql += " SET \(setQuery)"
        sql += insertSpace(condistionQuery)
        sql += insertSpace(groupQuery)
        sql += insertSpace(havingQuery)
        sql += insertSpace(orders.build())
        sql += insertSpace(limitQuery)
        
        return (sql, bindParams)
    }
}
