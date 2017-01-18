//
//  Table.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/18.
//
//

enum Table: QueryBuildable {
    case string(String)
    case queryBuilder(QueryBuilder)
    
    func build() throws -> (String, [Any]) {
        switch self {
        case .string(let table):
            return (pack(key: table), [])
            
        case .queryBuilder(let qb):
            let (sql, params) = try qb.build(.select).build()
            return ("(\(sql))", params)
        }
    }
}
