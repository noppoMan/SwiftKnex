//
//  BatchInsertQueryBuilder.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

import Foundation

struct BatchInsertQueryBuilder: QueryBuilder {
    
    let table: String
    
    let collection: [[String: Any]]
    
    init(into table: String, collection: [[String: Any]]){
        self.table = table
        self.collection = collection
    }
    
    func build() -> (String, [Any]) {
        // TODO should throws Error
        guard let fields = collection.max(by: { $0.0.count < $0.1.count }) else {
            return ("INSERT INTO \(table)", [])
        }
        
        let fieldQuery = fields.keys.map({ pack(key: $0) }).joined(separator: ", ")
        var placeHolders = [String]()
        for _ in 0..<collection.count {
            let placeHolder = "(\(fields.map({ _ in "?" }).joined(separator: ",")))"
            placeHolders.append(placeHolder)
        }
        
        var params = [Any]()
        for dict in collection {
            fields.forEach {
                if let value = dict[$0.key] {
                    params.append(pack(value: value))
                } else {
                    params.append(pack(value: NSNull()))
                }
            }
        }
        
        var sql = ""
        sql += "INSERT INTO"
        sql += " \(table)"
        sql += " (\(fieldQuery))"
        sql += " VALUES"
        sql += " " + placeHolders.joined(separator: ",")
        sql += ";"
        
        return (sql, params)
    }
    
}

