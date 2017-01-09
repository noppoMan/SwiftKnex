//
//  PrepareResultPacket.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

enum PrepareResultPacketError: Error {
    case failedToParsePrepareResultPacket
}

public struct PrepareResultPacket {
    let id: UInt32
    let columnCount: UInt16
    let paramCount: UInt16
    
    init?(bytes: [UInt8]) throws {
        guard let byte = bytes.first else {
            return nil
        }
        
        switch byte {
        case 0x00:
            // statement id [4 bytes]
            let id = bytes[1..<5].uInt32()
            
            // Column count [16 bit uint]
            let columnCount = bytes[5..<7].uInt16()
            
            // Param count [16 bit uint]
            let paramCount = bytes[7..<9].uInt16()
            
            self.id = id
            self.columnCount = columnCount
            self.paramCount = paramCount
            
        default:
            throw createErrorFrom(errorPacket: bytes)
        }
        
    }
}
