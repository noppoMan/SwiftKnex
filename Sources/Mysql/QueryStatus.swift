//
//  QueryStatus.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

public struct QueryStatus {
    public let affectedRows: UInt64
    public let insertId: UInt64
    
    public init(affectedRows: UInt64, insertId: UInt64) {
        self.affectedRows = affectedRows
        self.insertId = insertId
    }
    
    public init() {
        self.affectedRows = 0
        self.insertId = 0
    }
}
