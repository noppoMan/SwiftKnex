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
    var table: String?
    
    let config: KnexConfig
    
    let connection: ConnectionPool
        
    var condistions = [ConditionConnector]()
    
    var limit: Limit?
    
    var orders = [OrderBy]()
    
    var group: GroupBy?
    
    var having: Having?
    
    var joins = [Join]()
    
    var selectFields = [Field]()
    
    public init(config: KnexConfig, connection: ConnectionPool){
        self.config = config
        self.connection = connection
    }
    
    public func table(from name: String) -> Knex {
        self.table = name
        return self
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
    
}
