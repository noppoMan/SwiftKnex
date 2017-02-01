//
//  UpdateQueryBuilder.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

struct UpdateQueryBuilder: QueryBuildable {
    
    enum SetValue {
        case raw(query: String, params: [Any])
        case dictionary([String: Any])
    }
    
    let table: Table
    
    let condistions: [ConditionConnector]
    
    let limit: Limit?
    
    let orders: [OrderBy]
    
    let group: GroupBy?
    
    let having: Having?
    
    let joins: [Join]
    
    let setValue: SetValue
    
    func build() throws -> (String, [Any]) {
        let setQuery: String
        var bindParams: [Any]
        switch setValue {
        case .dictionary(let sets):
            setQuery = sets.map({ "\($0.key) = ?" }).joined(separator: ", ")
            bindParams = sets.map({ $0.value })
            
        case .raw(query: let query, params: let params):
            setQuery = query
            bindParams = params
        }
        
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
        
        print("----------------------------------")
//        
//        bindParams.map({
//            
//        })
        
        print(bindParams)
        
        return (sql, bindParams)
    }
}
