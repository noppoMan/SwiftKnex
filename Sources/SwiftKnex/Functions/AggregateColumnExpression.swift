public struct AggregateColumnExpression: Field {

    public var alias: String?
    
    public private (set) var function: AggregateFunction
    
    init(_ function: AggregateFunction) {
        self.function = function
    }
    
    public func build() -> String {
        if let alias = alias {
            return "\(function.build()) AS " + pack(key: alias)
        } else {
            return function.build()
        }
    }

    public enum AggregateFunction {
        case avg(field: Field)
        case max(field: Field)
        case min(field: Field)
        case sum(field: Field)
        case last(field: Field)
        case first(field: Field)
        case count(field: Field)
        case countDistinct(field: Field)
//        case ucase(field: Field)
//        case lcase(field: Field)
        case round(field: Field, to: Int)
        case mid(field: Field, start: Int, length: Int)
        case len(field: Field)
        
        public func build() -> String {
            switch self {
            case .avg(let field):
                return "AVG(" + field.build() + ")"
            case .max(let field):
                return "MAX(" + field.build() + ")"
            case .min(let field):
                return "MIN(" + field.build() + ")"
            case .sum(let field):
                return "SUM(" + field.build() + ")"
            case .last(let field):
                return "LAST(" + field.build() + ")"
            case .first(let field):
                return "FIRST(" + field.build() + ")"
            case .count(let field):
                return "COUNT(" + field.build() + ")"
            case .countDistinct(let field):
                return "COUNT(DISTINCT(" + field.build() + "))"
//            case .ucase(let field):
//                return try queryBuilder.substitutions[QueryBuilder.QuerySubstitutionNames.ucase.rawValue] + "(" + field.build() + ")"
//            case .lcase(let field):
//                return try queryBuilder.substitutions[QueryBuilder.QuerySubstitutionNames.lcase.rawValue] + "(" + field.build() + ")"
            case .round(let field, let decimal):
                return "ROUND(" + field.build() + ", \(decimal))"
            case .mid(let field, let start, let length):
                return "MID(" + field.build() + ", \(start), \(length))"
            case .len(let field):
                return "LEN(" + field.build() + ")"
            }
        }
    }
}

extension AggregateColumnExpression: CustomStringConvertible {
    public var description: String {
        return build()
    }
}

public func avg(_ field: String) -> AggregateColumnExpression {
    return avg(col(field))
}

public func avg(_ field: Field) -> AggregateColumnExpression {
    return AggregateColumnExpression(.avg(field: field))
}

public func max(_ field: String) -> AggregateColumnExpression {
    return max(col(field))
}

public func max(_ field: Field) -> AggregateColumnExpression {
    return AggregateColumnExpression(.max(field: field))
}

public func min(_ field: String) -> AggregateColumnExpression {
    return min(col(field))
}

public func min(_ field: Field) -> AggregateColumnExpression {
    return AggregateColumnExpression(.min(field: field))
}

public func sum(_ field: String) -> AggregateColumnExpression {
    return sum(col(field))
}

public func sum(_ field: Field) -> AggregateColumnExpression {
    return AggregateColumnExpression(.sum(field: field))
}

public func last(_ field: String) -> AggregateColumnExpression {
    return last(col(field))
}

public func last(_ field: Field) -> AggregateColumnExpression {
    return AggregateColumnExpression(.last(field: field))
}

public func first(_ field: String) -> AggregateColumnExpression {
    return first(count(field))
}

public func first(_ field: Field) -> AggregateColumnExpression {
    return AggregateColumnExpression(.first(field: field))
}

public func count(_ field: String) -> AggregateColumnExpression {
    return count(col(field))
}

public func count(_ field: Field) -> AggregateColumnExpression {
    return AggregateColumnExpression(.count(field: field))
}

public func countDistinct(_ field: String) -> AggregateColumnExpression {
    return countDistinct(col(field))
}

public func countDistinct(_ field: Field) -> AggregateColumnExpression {
    return AggregateColumnExpression(.countDistinct(field: field))
}

public func len(_ field: AggregateColumnExpression) -> AggregateColumnExpression {
    return AggregateColumnExpression(.len(field: field))
}

//public func ucase(_ field: AggregateColumnExpression) -> AggregateColumnExpression {
//    return AggregateColumnExpression(.ucase(field: field))
//}
//
//public func lcase(_ field: AggregateColumnExpression) -> AggregateColumnExpression {
//    return AggregateColumnExpression(.lcase(field: field))
//}

public func round(_ field: AggregateColumnExpression, to decimal: Int) -> AggregateColumnExpression {
    return AggregateColumnExpression(.round(field: field, to: decimal))
}

public func mid(_ field: AggregateColumnExpression, start: Int, length: Int) -> AggregateColumnExpression {
    return AggregateColumnExpression(.mid(field: field, start: start, length: length))
}
