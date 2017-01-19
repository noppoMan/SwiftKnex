//
//  Table.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/18.
//
//

//var alias: String? { get set }
//func `as`(_ alias: String)  -> Self

enum TableType: QueryBuildable  {
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

public struct Table: QueryBuildable, AliasAttacheble {
    
    let type: TableType
    
    public var alias: String?
    
    public init(_ qb: QueryBuilder) {
        self.type = .queryBuilder(qb)
    }
    
    public init(_ name: String) {
        self.type = .string(name)
    }
    
    public func build() throws -> (String, [Any]) {
        let (sql, params) = try type.build()
        
        if let alias = self.alias {
            return ("(\(sql)) AS \(alias)", params)
        }
        
        return (sql, params)
    }
}
