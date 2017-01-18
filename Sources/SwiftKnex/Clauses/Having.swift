//
//  Having.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/13.
//
//

struct Having: Buildable {
    let condition: ConditionalFilter
}

extension Having {
    func build() throws -> String {
        return try "HAVING \(condition.toQuery())"
    }
}
