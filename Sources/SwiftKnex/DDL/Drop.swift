//
//  Drop.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

public struct Drop: DDLBuildable {
    
    let table: String
    
    public init(table: String){
        self.table = table
    }
    
    public func toDDL() throws -> String {
        return "DROP TABLE \(pack(key: table))"
    }
}
