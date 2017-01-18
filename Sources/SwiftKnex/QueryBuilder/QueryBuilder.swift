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
    case unimplementedStatement(QueryType)
    case emptyValues
}

public enum QueryType {
    case select
    case delete
    case update([String: Any])
    case insert([String: Any])
    case batchInsert([[String: Any]])
    case forUpdate([String: Any])
}

public protocol QueryBuildable {
    func build() throws -> (String, [Any])
}

public final class QueryBuilder {
    
    var table: Table?
    
    var condistions = [ConditionConnector]()
    
    var limit: Limit?
    
    var orders = [OrderBy]()
    
    var group: GroupBy?
    
    var having: Having?
    
    var joins = [Join]()
    
    var selectFields = [Field]()
    
    var alias: String?
    
    public init(){}
    
    @discardableResult
    public func table(_ name: String) -> Self {
        self.table = .string(name)
        return self
    }
    
    @discardableResult
    public func table(_ qb: QueryBuilder) -> Self {
        self.table = .queryBuilder(qb)
        return self
    }
    
    @discardableResult
    public func select(_ fields: [Field]) -> Self {
        self.selectFields = fields
        return self
    }
    
    @discardableResult
    public func select(_ fields: Field...) -> Self {
        select(fields)
        return self
    }
    
    @discardableResult
    public func `where`(_ filter: ConditionalFilter) -> Self {
        if condistions.count == 0 {
            condistions.append(.where(filter))
        } else {
            condistions.append(.and(filter))
        }
        return self
    }
    
    @discardableResult
    public func or(_ filter: ConditionalFilter) -> Self {
        condistions.append(.or(filter))
        return self
    }
    
    @discardableResult
    public func join(_ table: String) -> Self {
        joins.append(Join(table: table, type: .default))
        return self
    }
    
    @discardableResult
    public func leftJoin(_ table: String) -> Self {
        joins.append(Join(table: table, type: .left))
        return self
    }
    
    @discardableResult
    public func rightJoin(_ table: String) -> Self {
        joins.append(Join(table: table, type: .right))
        return self
    }
    
    @discardableResult
    public func innerJoin(_ table: String) -> Self {
        joins.append(Join(table: table, type: .inner))
        return self
    }
    
    @discardableResult
    public func on(_ filter: ConditionalFilter) -> Self {
        joins.last?.conditions.append(filter)
        return self
    }
    
    @discardableResult
    public func limit(_ limit: Int) -> Self {
        if let lim = self.limit {
            self.limit = Limit(limit: limit, offset: lim.offset)
        } else {
            self.limit = Limit(limit: limit)
        }
        return self
    }
    
    @discardableResult
    public func offset(_ offset: Int) -> Self {
        if let lim = self.limit {
            self.limit = Limit(limit: lim.limit, offset: offset)
        }
        return self
    }
    
    @discardableResult
    public func order(by: String, sort: OrderSort = .asc) -> Self {
        let order = OrderBy(field: by, sort: sort)
        self.orders.append(order)
        return self
    }
    
    @discardableResult
    public func group(by name: String) -> Self {
        group = GroupBy(name: name)
        return self
    }
    
    @discardableResult
    public func having(_ filter: ConditionalFilter) -> Self {
        self.having = Having(condition: filter)
        return self
    }
    
    public func `as`(_ name: String) -> Self {
        self.alias = name
        return self
    }
    
    public func build(_ type: QueryType) throws -> QueryBuildable {
        guard let table = self.table else {
            throw QueryBuilderError.tableIsNotSet
        }
        
        switch type {
        case .select:
            return BasicQueryBuilder(
                type: .select,
                table: table,
                condistions: condistions,
                limit: limit,
                orders: orders,
                group: group,
                having: having,
                joins: joins,
                selectFields: selectFields,
                alias: alias
            )
            
        case .delete:
            return BasicQueryBuilder(
                type: .delete,
                table: table,
                condistions: condistions,
                limit: limit,
                orders: orders,
                group: group,
                having: having,
                joins: joins,
                selectFields: selectFields,
                alias: alias
            )
            
        case .insert(let values):
            return InsertQueryBuilder(into: table, values: values)
        
        case .batchInsert(let collection):
            return BatchInsertQueryBuilder(into: table, collection: collection)
            
        case .update(let sets):
            return UpdateQueryBuilder(
                table: table,
                condistions: condistions,
                limit: limit,
                orders: orders,
                group: group,
                having: having,
                joins: joins,
                sets: sets
            )
        
        default:
            throw QueryBuilderError.unimplementedStatement(type)
        }
    }
}
