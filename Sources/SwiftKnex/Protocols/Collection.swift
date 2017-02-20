//
//  Collection.swift
//  SwiftJNChatApp
//
//  Created by Yuki Takei on 2017/02/20.
//
//

public protocol CollectionSerializable {
    func serialize() throws -> [[String: Any]]
}

public protocol CollectionType {
    init(rows: ResultSet) throws
}

