//
//  HandShake.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/10.
//
//

struct HandshakePacket {
    var protoVersion: UInt8
    var serverVersion: String
    var connId: UInt32
    var scramble: [UInt8]
    var capFlags: UInt16
    var lang: UInt8?
    var status: UInt16?
    var scramble2: [UInt8]?
    
    init(bytes: Bytes) throws {
        var pos = 0
        let protoVersion = bytes[pos]
        pos += 1
        
        guard let serverVersion = bytes[pos..<bytes.count].string() else {
            throw ConnectionError.failedToParseHandshakeOf("server_version")
        }
        
        pos += (serverVersion.utf8.count) + 1
        let connId = bytes[pos...pos+4].uInt32()
        pos += 4
        var scramble = Array(bytes[pos..<pos+8])
        pos += 8 + 1
        let capFlags = bytes[pos...pos+2].uInt16()
        pos += 2
        
        if bytes.count > pos {
            pos += 1 + 2 + 2 + 1 + 10
            let c = Array(bytes[pos..<pos+12])
            scramble.append(contentsOf:c)
        }
        
        self.protoVersion = protoVersion
        self.serverVersion = serverVersion
        self.connId = connId
        self.scramble = scramble
        self.capFlags = capFlags
        self.lang = nil
        self.status = nil
        self.scramble2 = nil
    }
}

extension HandshakePacket {
    func buildAuthPacket(user: String, password: String?, database: String?) -> Bytes {
        var flags = Client.protocol41.rawValue |
            Client.longPassword.rawValue |
            Client.transactions.rawValue |
            Client.secureConn.rawValue |
            Client.localFiles.rawValue |
            Client.multiStatements.rawValue |
            Client.multiResults.rawValue
        
        flags &= UInt32(capFlags) | 0xffff0000
        
        if database != nil {
            flags |= Client.connectWithDB.rawValue
        }
        
        let encryptedPassword: [UInt8]
        if let password = password {
            encryptedPassword = encryptPassword(for: password, scramble: scramble)
        } else {
            encryptedPassword = []
        }
        
        var bytes = [UInt8]()
        
        bytes.append(contentsOf: [UInt8].UInt32Array(UInt32(flags)))
        
        bytes.append(contentsOf: [UInt8].UInt32Array(16777215))
        
        bytes.append(UInt8(33))
        
        bytes.append(contentsOf: [UInt8](repeating:0, count: 23))
        
        bytes.append(contentsOf: user.utf8)
        bytes.append(0)
        
        bytes.append(UInt8(encryptedPassword.count))
        bytes.append(contentsOf: encryptedPassword)
        
        if let database = database {
            bytes.append(contentsOf: database.utf8)
        }
        bytes.append(0)
        
        bytes.append(contentsOf: "mysql_native_password".utf8)
        bytes.append(0)
        
        return bytes
    }
}

