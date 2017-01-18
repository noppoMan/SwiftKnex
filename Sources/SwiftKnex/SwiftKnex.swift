@_exported import Mysql
import Foundation

public final class KnexConnection {
    let config: KnexConfig
    
    let connection: ConnectionPool
    
    public init(config: KnexConfig) throws {
        self.config = config
        self.connection = try ConnectionPool(
            url: URL(string: "mysql://\(config.host):\(config.port ?? 3306)")!,
            user: config.user,
            password: config.password,
            database: config.database,
            minPoolSize: config.minPoolSize,
            maxPoolSize: config.maxPoolSize
        )
        if config.isShowSQLLog {
            connection.isShowSQLLog = true
        }
    }
    
    public func knex() -> Knex {
        return Knex(config: config, connection: connection)
    }
    
    public func close() throws {
        try connection.close()
    }
}

public final class Knex {
    
    let config: KnexConfig
    
    let connection: ConnectionPool
    
    let queryBuilder = QueryBuilder()
    
    public init(config: KnexConfig, connection: ConnectionPool){
        self.config = config
        self.connection = connection
    }
    
    public func execRaw(trx: Connection? = nil, sql: String, prams: [Any] = []) throws -> QueryResult {
        let result: QueryResult
        if let trx = trx {
            result = try trx.query(sql, bindParams: prams)
        } else {
            result = try connection.query(sql, bindParams: prams)
        }
        
        return result
    }
    
    public func table(_ name: String) -> Self {
        queryBuilder.table(name)
        return self
    }
    
    public func select(_ fields: Field...) -> Self {
        queryBuilder.select(fields)
        return self
    }
    
    public func `where`(_ filter: ConditionalFilter) -> Self {
        queryBuilder.where(filter)
        return self
    }
    
    public func or(_ filter: ConditionalFilter) -> Self {
        queryBuilder.or(filter)
        return self
    }
    
    public func join(_ table: String) -> Self {
        queryBuilder.join(table)
        return self
    }
    
    public func leftJoin(_ table: String) -> Self {
        queryBuilder.leftJoin(table)
        return self
    }
    
    public func rightJoin(_ table: String) -> Self {
        queryBuilder.rightJoin(table)
        return self
    }
    
    public func innerJoin(_ table: String) -> Self {
        queryBuilder.innerJoin(table)
        return self
    }
    
    public func on(_ filter: ConditionalFilter) -> Self {
        queryBuilder.on(filter)
        return self
    }
    
    public func limit(_ limit: Int) -> Self {
        queryBuilder.limit(limit)
        return self
    }
    
    public func offset(_ offset: Int) -> Self {
        queryBuilder.offset(offset)
        return self
    }
    
    public func order(by: String, sort: OrderSort = .asc) -> Self {
        queryBuilder.order(by: by, sort: sort)
        return self
    }
    
    public func group(by name: String) -> Self {
        queryBuilder.group(by: name)
        return self
    }
    
    public func having(_ filter: ConditionalFilter) -> Self {
        queryBuilder.having(filter)
        return self
    }
    
}
