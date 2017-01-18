//
//  Util.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/18.
//
//

import Foundation

func pack(key: String) -> String {
    return key.components(separatedBy: ".").map({ "`\($0)`" }).joined(separator: ".")
}

func pack(value: Any) -> Any {
    switch value {
    case let v as Bool:
        return v ? "1" : "0"
        
    case let v as NSNull:
        return v
        
    case let v as Int:
        return v
        
    case let v as Double:
        return v
        
    case let v as Float:
        return v
        
    case let v as Date:
        return v.dateTimeString()
        
    default:
        return "\(value)"
    }
}

