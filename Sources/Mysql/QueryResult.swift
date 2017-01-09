//
//  QueryResult.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

public enum QueryResult {
    case resultSet(ResultSet)
    case queryStatus(QueryStatus)
    case noResults
}

extension QueryResult {
    public var isNoRecord: Bool {
        switch self {
        case .noResults:
            return true
        default:
            return false
        }
    }
    
    public func asResultSet() -> ResultSet? {
        switch self {
        case .resultSet(let rows):
            return rows
        default:
            return nil
        }
    }
    
    public func asQueryStatus() -> QueryStatus? {
        switch self {
        case .queryStatus(let status):
            return status
        default:
            return nil
        }
    }
}
