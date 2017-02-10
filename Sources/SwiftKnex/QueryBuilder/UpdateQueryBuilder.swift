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
    
    let builder: QueryBuilder
    
    let setValue: SetValue
    
    init(builder: QueryBuilder, setValue: SetValue){
        self.builder = builder
        self.setValue = setValue
    }
    
    func build() throws -> (String, [Any]) {
        guard let table = self.builder.table else {
            throw QueryBuilderError.tableIsNotSet
        }
        
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
        
        let condistionQuery = try builder.condistions.build()
        try bindParams.append(contentsOf: builder.condistions.bindParams())
    
        let groupQuery = try builder.group != nil ? builder.group!.build() : ""
        var havingQuery = ""
        if let having = self.builder.having {
            havingQuery = try having.build()
            try bindParams.append(contentsOf:  having.condition.toBindParams())
        }
        
        let limitQuery = try builder.limit != nil ? builder.limit!.build() : ""
        
        var sql = ""
        sql += "UPDATE"
        sql += try insertSpace(table.build().0)
        try sql += insertSpace(builder.joins.build())
        sql += " SET \(setQuery)"
        sql += insertSpace(condistionQuery)
        sql += insertSpace(groupQuery)
        sql += insertSpace(havingQuery)
        sql += insertSpace(builder.orders.build())
        sql += insertSpace(limitQuery)
        
        return (sql, bindParams)
    }
}
