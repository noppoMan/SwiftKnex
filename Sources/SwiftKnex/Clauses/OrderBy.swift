//
//  OrderBy.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/13.
//
//

import Foundation

public enum OrderSort: Buildable {
    case asc
    case desc
}

extension OrderSort {
    public func build() throws -> String {
        switch self {
        case .asc:
            return "ASC"
        case .desc:
            return "DESC"
        }
    }
}

public struct OrderBy {
    let field: String
    let sort: OrderSort
}

extension Collection where Self.Iterator.Element == OrderBy {
    func build() -> String {
        if self.count == 0 {
            return ""
        }
        return "ORDER BY" + self.map({ "\(pack(key: $0.field)) \($0.sort)" }).joined(separator: ", ")
    }
}
