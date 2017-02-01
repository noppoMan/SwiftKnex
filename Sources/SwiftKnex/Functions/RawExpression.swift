//
//  RawExpression.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/02/01.
//
//

public struct RawExpression: Field {
    
    public var alias: String?
    
    public private (set) var function: String
    
    init(_ function: String) {
        self.function = function
    }
    
    public func build() -> String {
        if let alias = alias {
            return "\(function) AS " + pack(key: alias)
        } else {
            return function
        }
    }
}

extension RawExpression {
    public var description: String {
        return build()
    }
}

public func raw(_ value: String) -> RawExpression {
    return RawExpression(value)
}
