//
//  DDLBuildable.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

public protocol DDLBuildable {
    func toDDL() throws -> String
}
