//
//  Raw.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

public struct Raw: DDLBuildable {
    let ddl: String
    
    public init(ddl: String){
        self.ddl = ddl
    }
    
    public func toDDL() -> String {
        return ddl
    }
}
