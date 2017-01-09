//
//  ConnectionPool.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

import Foundation

public enum ConnectionPoolError: Error {
    case failedToGetConnectionFromPool
}

public final class ConnectionPool: ConnectionType {
    public let url: URL
    public let user: String
    public let password: String?
    public let database: String?
    public let minPoolSize: UInt
    public let maxPoolSize: UInt
    
    var connections: [Connection]
    
    public var pooledConnectionCount: Int {
        return connections.count
    }
    
    public var availableConnection: Int {
        return connections.filter({ !$0.isUsed }).count
    }
    
    private var _isClosed = true
    
    public var isShowSQLLog = false {
        didSet {
            for c in connections {
                c.isShowSQLLog = isShowSQLLog
            }
        }
    }
    
    public var isClosed: Bool {
        return _isClosed
    }
    
    let cond = Cond()
    
    public init(url: URL, user: String, password: String? = nil, database: String? = nil, minPoolSize: UInt = 1, maxPoolSize: UInt = 5) throws {
        self.url = url
        self.user = user
        self.password = password
        self.database = database
        self.minPoolSize = minPoolSize
        self.maxPoolSize = maxPoolSize
        
        self.connections = try (0..<maxPoolSize).map { _ in
            return try Connection(url: url, user: user, password: password, database: database)
        }
    }
    
    public func query(_ sql: String, bindParams params: [Any]) throws -> QueryResult {
        let con = try getConnection()
        let result = try con.query(sql, bindParams: params)
        
        if !con.isTransacting {
            con.release()
        }
        
        return result
    }
    
    public func query(_ sql: String) throws -> QueryResult {
        let con = try getConnection()
        let result = try con.query(sql)
        
        if !con.isTransacting {
            con.release()
        }
        
        return result
    }
    
    func getConnection(_ retryCount: Int = 0) throws -> Connection {
        // TODO should implement timeout
        if Double(retryCount) > (0.1*10)*5 {
            throw ConnectionPoolError.failedToGetConnectionFromPool
        }
        
        for con in connections {
            if con.isUsed {
                continue
            }
            
            con.reserve()
            return con
        }
        
        cond.mutex.lock()
        _ = cond.wait(timeout: 0.1)
        cond.mutex.unlock()
        
        return try getConnection(retryCount+1)
    }
    
    public func close () throws {
        for c in connections {
            try c.close()
        }
        _isClosed = true
    }
}
