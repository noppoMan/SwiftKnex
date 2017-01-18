//
//  InsertQueryBuilder.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//


struct InsertQueryBuilder: Buildable {
    
    let table: String
    
    let values: [String: Any]
    
    init(into table: String, values: [String: Any]){
        self.table = table
        self.values = values
    }
    
    func build() -> (String, [Any]) {
        let fieldQuery = values.keys.map({ pack(key: $0) }).joined(separator: ", ")
        let placeHolders = (0..<values.keys.count).map({ _ in "?" }).joined(separator: ", ")
        
        var sql = ""
        sql += "INSERT INTO"
        sql += " \(table)"
        sql += " (\(fieldQuery))"
        sql += " VALUES"
        sql += " (\(placeHolders))"
        sql += ";"
        
        return (sql, values.values.map({ pack(value: $0) }))
    }
    
}
