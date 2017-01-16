//
//  Create.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

import Foundation

public struct Create: DDLBuildable {
    
    let table: String
    
    let builder: Schema.Buiulder
    
    public init(table: String, fields: [Schema.Field]){
        self.table = table
        self.builder = Schema.Buiulder(table, fields)
    }
    
    public func index(name: String? = nil, columns: [String], unique: Bool = false) -> Create {
        builder.index(name: name, columns: columns, unique: unique)
        return self
    }
    
    public func hasTimestamps(forCreated: String = "created_at", forUpdated: String = "updated_at") -> Create {
        builder.hasTimestamps(Schema.TimeStampFields(forCreated: forCreated, forUpdated: forUpdated))
        return self
    }
    
    public func engine(_ engine: Schema.MYSQLEngine) -> Create {
        builder.engine(engine)
        return self
    }
    
    public func charset(_ char: Schema.Charset) -> Create {
        builder.charset(char)
        return self
    }
    
    public func toDDL() throws -> String {
        let fieldDefiniations = builder.buildFields()
        let indexes = builder.buildIndexes()
        let primaryKey = try builder.buildPrimaryKey()
        
        var ddl = ""
        ddl += "CREATE TABLE"
        ddl += "\(pack(key: table))"
        ddl += "(\n"
        ddl += fieldDefiniations.joined(separator: ", \n")
        
        if let pri = primaryKey {
            ddl += ","
            ddl += "\n"
            ddl += "\(pri)"
        } else {
            ddl += "\n"
        }
        
        if indexes.count > 0 {
            ddl += ","
            ddl += "\n"
        }
        
        ddl += indexes.joined(separator: ",\n")
        ddl += "\n"
        ddl += ")"
        ddl += "ENGINE=\(builder.engine) DEFAULT CHARSET=\(builder.charset ?? .utf8)"
        ddl += ";"
        return ddl
    }
}

