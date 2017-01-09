//
//  QueryBuilder.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

func insertSpace(_ str: String) -> String {
    if str.isEmpty {
        return ""
    }
    return " " + str
}

public enum QueryBuilderError: Error {
    case tableIsNotSet
}

protocol QueryBuilder {
    func build() -> (String, [Any])
}
