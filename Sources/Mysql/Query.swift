//
//  Query.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/10.
//
//

import Foundation

extension Connection {
    
    private func sqlLog(_ query: String, bindParams: [Any]){
        if isShowSQLLog {
            print("[SwiftKnex.SQLLog] sql: \(query) bindParams: \(bindParams)")
        }
    }
    
    public func query(_ query: String, bindParams params: [Any]) throws -> QueryResult {
        if self.isClosed {
            throw StreamError.alreadyClosed
        }
        
        sqlLog(query, bindParams: params)
        
        let stmt = try prepare(query)
        
        let packet = try stmt.executePacket(params: params)
        
        try stream.writePacket(packet, packnr: -1)
        
        return try readResults(RowDataParser: BinaryRowDataPacket.self)
    }
    
    private func prepare(_ query: String) throws -> Statement {
        if self.isClosed {
            throw StreamError.alreadyClosed
        }
        
        try write(.stmtPrepare, query: query)
        let (bytes, _) = try stream.readPacket()
        
        if bytes[0] != 0x00 {
            throw createErrorFrom(errorPacket: bytes)
        }
        
        guard let prepareResult = try PrepareResultPacket(bytes: bytes) else {
            throw PrepareResultPacketError.failedToParsePrepareResultPacket
        }
        
        if prepareResult.paramCount > 0 {
            try readUntilEOF()
        }
        
        if prepareResult.columnCount > 0 {
            try readUntilEOF()
        }
    
        return Statement(prepareResult: prepareResult)
    }
    
    public func query(_ query: String) throws -> QueryResult {
        if self.isClosed {
            throw StreamError.alreadyClosed
        }
        
        sqlLog(query, bindParams: [])
        
        try write(.query, query: query)
        
        return try readResults(RowDataParser: RowDataPacket.self)
    }
    
    private func readResults(RowDataParser: RowDataParsable.Type) throws -> QueryResult {
        var len: Int, okPacket: OKPacket?
        (len, okPacket) = try readHeaderPacket()
        
        if okPacket != nil {
            let qs = QueryStatus(
                affectedRows: okPacket!.affectedRows ?? 0,
                insertId: okPacket!.insertId
            )
            return .queryStatus(qs)
        }
        
        let columns = try readColumns(count: len)
        let parser = RowDataParser.init(columns: columns)
        var rows: ResultSet = []
        
        while true {
            let (bytes, _) = try stream.readPacket()    
            if let row = try parser.parse(bytes: bytes) {
                rows.append(row)
                continue
            } else {
                if parser.hasMoreResults {
                    continue
                }
            }
            
            break
        }
        
        if rows.isEmpty {
            return .noResults
        }
        
        return .resultSet(rows)
    }
    
    private func readColumns(count: Int) throws -> [Field] {
        if stream.isClosed {
            throw StreamError.alreadyClosed
        }
        
        if count == 0 {
            return []
        }
        
        let parser = FieldParser(count: count)
        while true {
            let (bytes, _) = try stream.readPacket()
            guard let fields = try parser.parse(bytes: bytes) else {
                continue
            }
            
            return fields
        }
    }
    
    public func use(database: String) throws {
        try self.write(.initDB, query: database)
        let (len, _) = try readHeaderPacket()
        
        if len > 0 {
            try readUntilEOF()
            try readUntilEOF()
        }
    }
}
