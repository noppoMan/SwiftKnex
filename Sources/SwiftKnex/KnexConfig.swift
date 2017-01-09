//
//  KnexConfig.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

public struct KnexMigrationConfig {
    let table: String
    
    public init(table: String = "knex_migrations") {
        self.table = table
    }
}

public struct KnexConfig {
    let host: String
    let port: UInt?
    let user: String
    let password: String?
    let database: String
    let migration: KnexMigrationConfig
    let minPoolSize: UInt
    let maxPoolSize: UInt
    let isShowSQLLog: Bool
    
    public init(host: String, port: UInt? = 3306, user: String, password: String? = nil, database: String, migration: KnexMigrationConfig = KnexMigrationConfig(), minPoolSize: UInt = 1, maxPoolSize: UInt = 5, isShowSQLLog: Bool = false){
        
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.database = database
        self.migration = migration
        self.minPoolSize = minPoolSize
        self.maxPoolSize = maxPoolSize
        self.isShowSQLLog = isShowSQLLog
    }
}
