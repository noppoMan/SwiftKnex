//
//  Connection.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/09.
//
//

import Foundation

public enum ConnectionError: Error {
    case failedToParseHandshakeOf(String)
    case wrongHandshake
}

// syncronous connection
public final class Connection: ConnectionType {
    public let url: URL
    public let user: String
    public let password: String?
    public let database: String?
    
    private var _isClosed = true
    
    public var isClosed: Bool {
        return _isClosed
    }
    
    var isUsed = false
    
    var isTransacting = false
    
    public var isShowSQLLog = false
    
    let stream: PacketStream
    
    fileprivate let cond = Cond()
    
    public init(url: URL, user: String, password: String? = nil, database: String? = nil) throws {
        self.url = url
        self.user = user
        self.password = password
        self.database = database
        self.stream = try PacketStream(host: url.host ?? "localhost", port: UInt(url.port ?? 3306))
        try self.open()
    }
    
    private func open() throws {
        try stream.open()
        let (handshakeBytes, packnr) = try self.stream.readPacket()
        let hp = try HandshakePacket(bytes: handshakeBytes)
        
        let authPacket = hp.buildAuthPacket(
            user: user,
            password: password,
            database: database
        )
        
        try stream.writePacket(authPacket, packnr: packnr)
        let (bytes, _) = try stream.readPacket()
        
        guard let _ = try OKPacket(bytes: bytes) else {
            fatalError("OK Packet should not be nil")
        }
        
        _isClosed = false
    }
    
    func write(_ cmd: Commands, query: String) throws {
        try stream.writePacket([cmd.rawValue] + query.utf8, packnr: -1)
    }
    
    func write(_ cmd: Commands) throws {
        try stream.writePacket([cmd.rawValue], packnr: -1)
    }
    
    func reserve(){
        cond.mutex.lock()
        isUsed = true
        cond.mutex.unlock()
    }
    
    func release(){
        cond.mutex.lock()
        isUsed = false
        cond.mutex.unlock()
    }
    
    func readHeaderPacket() throws -> (Int, OKPacket?) {
        let (bytes, _) = try stream.readPacket()
        if let okPacket = try OKPacket(bytes: bytes) {
            return (0, okPacket)
        } else {
            let (_num, n) = lenEncInt(bytes)
            if let num = _num, (n - bytes.count) == 0 {
                return (Int(num), nil)
            } else {
                return (0, nil)
            }
        }
    }
    
    func readUntilEOF() throws {
        while true {
            let (bytes, _) = try stream.readPacket()
            if bytes[0] == 0xfe {
                break
            }
        }
    }
    
    public func close() throws {
        try write(.quit)
        stream.close()
        _isClosed = true
    }
}
