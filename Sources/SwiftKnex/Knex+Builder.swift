//
//  Knex+Condition.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/14.
//
//

extension Knex {
    
    public func select(_ fields: Field...) -> Knex {
        self.selectFields = fields
        return self
    }
    
    public func `where`(_ filter: Filter) -> Knex {
        if condistions.count == 0 {
            condistions.append(.where(filter))
        } else {
            condistions.append(.and(filter))
        }
        return self
    }
    
    public func or(_ filter: Filter) -> Knex {
        condistions.append(.or(filter))
        return self
    }
    
    public func join(_ table: String) -> Knex {
        joins.append(Join(table: table, type: .default))
        return self
    }
    
    public func leftJoin(_ table: String) -> Knex {
        joins.append(Join(table: table, type: .left))
        return self
    }
    
    public func rightJoin(_ table: String) -> Knex {
        joins.append(Join(table: table, type: .right))
        return self
    }
    
    public func innerJoin(_ table: String) -> Knex {
        joins.append(Join(table: table, type: .inner))
        return self
    }
    
    public func on(_ filter: Filter) -> Knex {
        joins.last?.conditions.append(filter)
        return self
    }
    
    public func limit(_ limit: Int) -> Knex {
        if let lim = self.limit {
            self.limit = Limit(limit: limit, offset: lim.offset)
        } else {
            self.limit = Limit(limit: limit)
        }
        return self
    }
    
    public func offset(_ offset: Int) -> Knex {
        if let lim = self.limit {
            self.limit = Limit(limit: lim.limit, offset: offset)
        }
        return self
    }
    
    public func order(by: String, sort: OrderSort = .asc) -> Knex {
        let order = OrderBy(field: by, sort: sort)
        self.orders.append(order)
        return self
    }
    
    public func group(by name: String) -> Knex {
        group = GroupBy(name: name)
        return self
    }
    
    public func having(_ filter: Filter) -> Knex {
        self.having = Having(condition: filter)
        return self
    }
}
