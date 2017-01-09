//
//  PacketStream.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/10.
//
//

import Foundation

typealias PacketStream = TCPStream

extension PacketStream {
    
    func readHeader() throws -> (UInt32, Int) {
        let b = try read(upTo: 3).uInt24()
        let pn = try read(upTo: 1)[0]
        return (b, Int(pn))
    }
    
    func readPacket() throws -> (Bytes, Int) {
        let (len, packnr) = try readHeader()
        var bytes = Bytes()
        while bytes.count < Int(len) {
            bytes.append(contentsOf: try read(upTo: Int(len)))
        }
        
        return (bytes, packnr)
    }
    
    func writeHeader(_ len: UInt32, pn: UInt8) throws {
        try self.write([UInt8].UInt24Array(len) + [pn])
    }
    
    func writePacket(_ bytes: [UInt8], packnr: Int) throws {
        try writeHeader(UInt32(bytes.count), pn: UInt8(packnr + 1))
        try self.write(bytes)
    }
}
