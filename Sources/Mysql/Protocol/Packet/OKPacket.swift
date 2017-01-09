//
//  OKPacket.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

public struct OKPacket {
    let affectedRows: UInt64?
    let insertId: UInt64
    let status: UInt16
    
    init?(bytes: [UInt8]) throws {
        switch bytes[0] {
        case 0x00:
            // 0x00 [1 byte]
            
            // Affected rows [Length Coded Binary]
            let (affectedRows, n) = lenEncInt(Array(bytes[1...bytes.count-1]))
            
            // Insert id [Length Coded Binary]
            let (_insertId, m) = lenEncInt(Array(bytes[1+n...bytes.count-1]))
            let insertId = _insertId ?? 0
            
            let status = UInt16(bytes[1+n+m]) | UInt16(bytes[1+n+m+1]) << 8
            
            self.affectedRows = affectedRows
            self.insertId = insertId
            self.status = status
            
        case 0xff:
            throw createErrorFrom(errorPacket: bytes)
        default:
            return nil
        }
    }
}
