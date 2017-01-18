//
//  Having.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/13.
//
//

struct Having {
    let condition: Filter
}

extension Having {
    func build() -> String {
        return "HAVING \(condition.toQuery())"
    }
}
