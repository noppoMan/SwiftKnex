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

public enum Filter {
    case withOperator(field: String, op: Operator, value: Any)
    case like(field: String, value: String)
    case `in`(field: String, values: [Any])
    case notIn(field: String, values: [Any])
    case between(field: String, from: Any, to: Any)
    case notBetween(field: String, from: Any, to: Any)
    case isNull(field: String)
    case isNotNull(field: String)
    case raw(String)
}

extension Filter {
    func toBindParams() -> [Any] {
        switch self {
        case .withOperator(field: _, op: _, value: let value):
            return [pack(value: value)]
            
        case .like(field: _, value: let value):
            return [pack(value: value)]
            
        case .in(field: _, values: let values):
            return values.map({ pack(value: $0) })
            
        case .notIn(field: _, values: let values):
            return values.map({ pack(value: $0) })
            
        case .between(field: _, from: let from, to: let to):
            return [pack(value: from), pack(value: to)]
            
        case .notBetween(field: _, from: let from, to: let to):
            return [pack(value: from), pack(value: to)]
            
        case .isNull(field: _):
            return []
            
        case .isNotNull(field: _):
            return []
            
        case .raw(query: _):
            return []
        }
    }
    
    func toQuery(secure: Bool = true) -> String {
        switch self {
        case .withOperator(field: let field, op: let op, value: let value):
            if !secure {
                return "\(pack(key: field)) \(op.rawValue) \(value)"
            }
            return "\(pack(key: field)) \(op.rawValue) ?"
            
        case .like(field: let field, value: let value):
            if !secure {
                return "\(pack(key: field)) LIKE \(value)"
            }
            return "\(pack(key: field)) LIKE ?"
            
        case .in(field: let field, values: let values):
            if !secure {
                let params = values.map({ "\(pack(value: $0))" }).joined(separator: ", ")
                return "\(pack(key: field)) IN(\(params))"
            }
            let placeHolders = (0..<values.count).map({ _ in "?" }).joined(separator: ", ")
            return "\(pack(key: field)) IN(\(placeHolders))"
            
        case .notIn(field: let field, values: let values):
            if !secure {
                let params = values.map({ "\(pack(value: $0))" }).joined(separator: ", ")
                return "\(pack(key: field)) NOT IN(\(params))"
            }
            
            let placeHolders = (0..<values.count).map({ _ in "?" }).joined(separator: ", ")
            return "\(pack(key: field)) NOT IN(\(placeHolders))"
            
        case .between(field: let field, from: let from, to: let to):
            if !secure {
                return "\(pack(key: field)) BETWEEN \(from) AND \(to)"
            }
            return "\(pack(key: field)) BETWEEN ? AND ?"
            
        case .notBetween(field: let field, from:  let from, to: let to):
            if !secure {
                return "\(pack(key: field)) NOT BETWEEN \(from) AND \(to)"
            }
            return "\(pack(key: field)) NOT BETWEEN ? AND ?"
            
        case .isNull(field: let field):
            return "\(pack(key: field)) IS NULL"
            
        case .isNotNull(field: let field):
            return "\(pack(key: field)) IS NOT NULL"
            
        case .raw(query: let query):
            return query
        }
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

public func >(key: String, pred: Any) -> Filter {
    return .withOperator(field: key, op: .greaterThan, value: pred)
}

public func >=(key: String, pred: Any) -> Filter {
    return .withOperator(field: key, op: .greaterThanEqual, value: pred)
}

public func <(key: String, pred: Any) -> Filter {
    return .withOperator(field: key, op: .smallerThan, value: pred)
}

public func <=(key: String, pred: Any) -> Filter {
    return .withOperator(field: key, op: .smallerThanEqual, value: pred)
}

public func ==(key: String, pred: Any) -> Filter {
    return .withOperator(field: key, op: .equal, value: pred)
}

public func !=(key: String, pred: Any) -> Filter {
    return .withOperator(field: key, op: .notEqual, value: pred)
}

public enum ConditionConnector {
    case `where`(Filter)
    case and(Filter)
    case or(Filter)
}

extension Collection where Self.Iterator.Element == ConditionConnector {
    
    public func bindParams() -> [Any] {
        var params = [Any]()
        
        for c in self {
            switch c {
            case .where(let clause):
                params.append(contentsOf: clause.toBindParams())
                
            case .and(let clause):
                params.append(contentsOf: clause.toBindParams())
                
            case .or(let clause):
                params.append(contentsOf: clause.toBindParams())
            }
        }
        
        return params
    }
    
    public func build() -> String  {
        let clauses: [String] = self.map({
            switch $0 {
            case .where(let clause):
                return "WHERE \(clause.toQuery())"
                
            case .and(let clause):
                return "AND \(clause.toQuery())"
                
            case .or(let clause):
                return "OR \(clause.toQuery())"
            }
        })
        
        return clauses.joined(separator: " ")
    }
}
