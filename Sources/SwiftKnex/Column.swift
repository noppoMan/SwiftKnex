//
//  Column.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

public struct Column: Field, ExpressibleByStringLiteral {
    
    let value: String
    
    public var alias: String?
    
    public init(_ value: String){
        self.value = pack(key: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public func build() -> String {
        if let alias = alias {
            return "\(value) AS \(alias)"
        } else {
            return "\(value)"
        }
    }
}

extension Column {
    public var description: String {
        return build()
    }
}

public func col(_ value: String) -> Column {
    return Column(value)
}
