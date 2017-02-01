//
//  Where.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

import Foundation

public enum Operator: String {
    case equal = "="
    case notEqual = "!="
    case greaterThan = ">"
    case greaterThanEqual = ">="
    case smallerThan = "<"
    case smallerThanEqual = "<="
}

public enum ConditionalFilterError: Error {
    case unrecognizedFilter
}

public protocol FilterQueryBuildable {
    func toBindParams() throws -> [Any]
    func toQuery(secure: Bool) throws -> String
}

public indirect enum ConditionalFilter {
    // basics
    case withOperator(field: String, op: Operator, value: Any)
    case like(String, String)
    case `in`(String, Any)
    case notIn(String, Any)
    case between(String, Any, Any)
    case notBetween(String, Any, Any)
    case isNull(String)
    case isNotNull(String)
    
    // comparison
    case andComparison(ConditionalFilter, ConditionalFilter)
    case orComparison(ConditionalFilter, ConditionalFilter)
    
    // raw
    case raw(String, [Any])
}

extension ConditionalFilter: FilterQueryBuildable {
    public func toBindParams() throws -> [Any] {
        switch self {
        case .withOperator(_, op: _, let value):
            return [pack(value: value)]
            
        case .like(_, let value):
            return [pack(value: value)]
            
        case .in(_, let value):
            switch value {
            case let values as [Any]:
                return values.map({ pack(value: $0) })
            case let qb as QueryBuilder:
                let (_, params) = try qb.build(.select).build()
                return params
            default:
                break
            }
            
        case .notIn(_, let value):
            switch value {
            case let values as [Any]:
                return values.map({ pack(value: $0) })
            case let qb as QueryBuilder:
                let (_, params) = try qb.build(.select).build()
                return params
            default:
                break
            }
            
        case .between(_, let from, let to):
            return [pack(value: from), pack(value: to)]
            
        case .notBetween(_, let from, let to):
            return [pack(value: from), pack(value: to)]
            
        case .isNull(_):
            return []
            
        case .isNotNull(_):
            return []
            
        case .andComparison(let aFilter, let bFilter):
            return try aFilter.toBindParams() + bFilter.toBindParams()
            
        case .orComparison(let aFilter, let bFilter):
            return try aFilter.toBindParams() + bFilter.toBindParams()
            
        case .raw(_, let params):
            return params
        }
        throw ConditionalFilterError.unrecognizedFilter
    }
    
    public func toQuery(secure: Bool = true) throws -> String {
        switch self {
        case .withOperator(let field, let op, let value):
            if !secure {
                return "\(pack(key: field)) \(op.rawValue) \(value)"
            }
            return "\(pack(key: field)) \(op.rawValue) ?"
            
        case .like(let field, let value):
            if !secure {
                return "\(pack(key: field)) LIKE \(value)"
            }
            return "\(pack(key: field)) LIKE ?"
            
        case .in(let field, let value):
            switch value {
            case let values as [Any]:
                if secure {
                    let placeHolders = (0..<values.count).map({ _ in "?" }).joined(separator: ", ")
                    return "\(pack(key: field)) IN (\(placeHolders))"
                }
                let params = values.map({ "\(pack(value: $0))" }).joined(separator: ", ")
                return "\(pack(key: field)) IN (\(params))"
                
            case let qb as QueryBuilder:
                let (sql, _) = try qb.build(.select).build()
                return "\(pack(key: field)) IN (\(sql))"
            
            default:
                break
            }
            
        case .notIn(let field, let value):
            switch value {
            case let values as [Any]:
                if secure {
                    let placeHolders = (0..<values.count).map({ _ in "?" }).joined(separator: ", ")
                    return "\(pack(key: field)) NOT IN (\(placeHolders))"
                }
                let params = values.map({ "\(pack(value: $0))" }).joined(separator: ", ")
                return "\(pack(key: field)) NOT IN (\(params))"
                
            case let qb as QueryBuilder:
                let (sql, _) = try qb.build(.select).build()
                return "\(pack(key: field)) NOT IN (\(sql))"
                
            default:
                break
            }
            
        case .between(let field, let from, let to):
            if !secure {
                return "\(pack(key: field)) BETWEEN \(from) AND \(to)"
            }
            return "\(pack(key: field)) BETWEEN ? AND ?"
            
        case .notBetween(let field, let from, let to):
            if !secure {
                return "\(pack(key: field)) NOT BETWEEN \(from) AND \(to)"
            }
            return "\(pack(key: field)) NOT BETWEEN ? AND ?"
            
        case .isNull(let field):
            return "\(pack(key: field)) IS NULL"
            
        case .isNotNull(let field):
            return "\(pack(key: field)) IS NOT NULL"
            
        case .andComparison(let aFilter, let bFilter):
            return try "(\(aFilter.toQuery()) AND \(bFilter.toQuery()))"
            
        case .orComparison(let aFilter, let bFilter):
            return try "(\(aFilter.toQuery()) OR \(bFilter.toQuery()))"
            
        case .raw(let query, _):
            return query
        }
        throw ConditionalFilterError.unrecognizedFilter
    }
}

extension Date {
    func dateTimeString() -> String {
        struct statDFT {
            static var dateStringFormatter :  DateFormatter? = nil
            static var token : Int = 0
        }
        
        // TODO once
        statDFT.dateStringFormatter = DateFormatter()
        statDFT.dateStringFormatter!.dateFormat = "yyyy-MM-dd HH:mm:ss"
        statDFT.dateStringFormatter!.locale = Locale(identifier: "en_US_POSIX")
        
        return statDFT.dateStringFormatter!.string(from: self)
    }
}

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
        
    case let v as [String: Any]:
        do {
            let data = try JSONSerialization.data(withJSONObject: v, options: [])
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
        
    default:
        return "\(value)"
    }
}

public func || (lhs: ConditionalFilter, rhs: ConditionalFilter) -> ConditionalFilter {
    return .orComparison(lhs, rhs)
}

public func && (lhs: ConditionalFilter, rhs: ConditionalFilter) -> ConditionalFilter {
    return .andComparison(lhs, rhs)
}

public func >(key: String, pred: Any) -> ConditionalFilter {
    return .withOperator(field: key, op: .greaterThan, value: pred)
}

public func >=(key: String, pred: Any) -> ConditionalFilter {
    return .withOperator(field: key, op: .greaterThanEqual, value: pred)
}

public func <(key: String, pred: Any) -> ConditionalFilter {
    return .withOperator(field: key, op: .smallerThan, value: pred)
}

public func <=(key: String, pred: Any) -> ConditionalFilter {
    return .withOperator(field: key, op: .smallerThanEqual, value: pred)
}

public func ==(key: String, pred: Any) -> ConditionalFilter {
    return .withOperator(field: key, op: .equal, value: pred)
}

public func !=(key: String, pred: Any) -> ConditionalFilter {
    return .withOperator(field: key, op: .notEqual, value: pred)
}

public enum ConditionConnector {
    case `where`(ConditionalFilter)
    case and(ConditionalFilter)
    case or(ConditionalFilter)
}

extension Collection where Self.Iterator.Element == ConditionConnector {
    
    public func bindParams() throws -> [Any] {
        var params = [Any]()
        
        for c in self {
            switch c {
            case .where(let clause):
                try params.append(contentsOf: clause.toBindParams())
                
            case .and(let clause):
                try params.append(contentsOf: clause.toBindParams())
                
            case .or(let clause):
                try params.append(contentsOf: clause.toBindParams())
            }
        }
        
        return params
    }
    
    public func build() throws -> String  {
        let clauses: [String] = try self.map({
            switch $0 {
            case .where(let clause):
                return try "WHERE \(clause.toQuery())"
                
            case .and(let clause):
                return try "AND \(clause.toQuery())"
                
            case .or(let clause):
                return try "OR \(clause.toQuery())"
            }
        })
        
        return clauses.joined(separator: " ")
    }
}
