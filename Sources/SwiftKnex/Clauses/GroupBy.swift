//
//  GroupBy.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/13.
//
//

struct GroupBy: Buildable {
    let name: String
}

extension GroupBy {
    func build() throws -> String {
        return "GROUP BY \(pack(key: name))"
    }
}
