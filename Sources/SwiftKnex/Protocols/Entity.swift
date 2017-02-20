//
//  Entity.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/18.
//
//


public protocol Serializable {
    func serialize() throws -> [String: Any]
}

public protocol Entity {
    init(row: Row) throws
}
