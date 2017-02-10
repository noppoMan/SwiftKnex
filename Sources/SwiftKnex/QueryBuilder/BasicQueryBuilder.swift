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
    
    let builder: QueryBuilder
    
    init(type: QueryType, builder: QueryBuilder) {
        self.type = type
        self.builder = builder
    }
    
    func build() throws -> (String, [Any]) {
        guard let _table = self.builder.table else {
            throw QueryBuilderError.tableIsNotSet
        }
        
        var bindParams = [Any]()
        let (table, params) = try _table.build()
        bindParams.append(contentsOf: params)
        
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
        
        switch type {
        case .select:
            let fieldsQuery = builder.selectFields.count > 0 ? builder.selectFields.map({ "\($0)"}).joined(separator: ", ") : "*"
            sql += "SELECT"
            sql += insertSpace(fieldsQuery)
        case .delete:
            sql += "DELETE"
        }
        
        sql += " FROM"
        sql += insertSpace(table)
        sql += try insertSpace(builder.joins.build())
        sql += insertSpace(condistionQuery)
        sql += insertSpace(groupQuery)
        sql += insertSpace(havingQuery)
        sql += insertSpace(builder.orders.build())
        sql += insertSpace(limitQuery)
        
        return (sql, bindParams)
    }
}
