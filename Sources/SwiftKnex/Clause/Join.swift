//
//  Join.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

class Join {
    let table: String
    let type: JoinType
    var conditions = [ConditionFilter]()
    
    init(table: String, type: JoinType){
        self.table = table
        self.type = type
    }
    
    public func build() -> String {
        var conds = [String]()
        for cond in conditions {
            let prefix: String
            if conds.count == 0 {
                prefix = "ON"
            } else {
                prefix = "AND"
            }
            conds.append(prefix + " " + cond.toQuery(secure: false))
        }
        
        return "\(type.build()) \(table) \(conds.joined(separator: " "))"
    }
}

enum JoinType {
    case left
    case right
    case inner
    case `default`
}

extension JoinType {
    public func build() -> String {
        switch self {
        case .left:
            return "LEFT JOIN"
            
        case .right:
            return "RIGHT JOIN"
            
        case .inner:
            return "INNER JOIN"
            
        case .default:
             //`\(table)` ON \(filter.toQuery(secure: false))"
            return "JOIN"
        }
    }
}

extension Collection where Self.Iterator.Element == Join {
    func build() -> String  {
        let clauses: [String] = self.map { $0.build() }
        return clauses.joined(separator: " ")
    }
}
