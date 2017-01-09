//
//  Caps.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/09.
//
//

import Foundation

let maxPackAllowed = 16777215
let unsignedMask   = 0x200000
let serverMoreResultsExists: UInt16 = 0x0008

enum Client: UInt32 {
    case longPassword    = 0x00000001           // new more secure passwords
    case foundRowns      = 0x00000002           // Found instead of affected rows
    case longFlag        = 0x00000004           // Get all column flags
    case connectWithDB   = 0x00000008           // One can specify db on connect
    case noSchema        = 0x00000010           // Don't allow database.table.column
    case compress        = 0x00000020           // Can use compression protocol
    case odbc            = 0x00000040           // Odbc client
    case localFiles      = 0x00000080           // Can use LOAD DATA LOCAL
    case ignoreSpace     = 0x00000100           // Ignore spaces before '('
    case protocol41      = 0x00000200           // New 4.1 protocol
    case interactive     = 0x00000400           // This is an interactive client
    case ssl             = 0x00000800           // Switch to SSL after handshake
    case ignoreSigpipe   = 0x00001000           // IGNORE sigpipes
    case transactions    = 0x00002000           // Client knows about transactions
    case reserved        = 0x00004000           // Old flag for 4.1 protocol
    case secureConn      = 0x00008000           // New 4.1 authentication
    case multiStatements = 0x00010000           // Enable/disable multi-stmt support
    case multiResults    = 0x00020000           // Enable/disable multi-results
}

enum FieldFlag: UInt16 {
    case notNull       = 0x0001
    case primaryKey    = 0x0002
    case uniqueKey     = 0x0004
    case multiKey      = 0x0008
    case blob          = 0x0010
    case unsigned      = 0x0020
    case zeroFill      = 0x0040
    case binary        = 0x0080
    case `enum`        = 0x0100
    case autoincrement = 0x0200
    case timestamp     = 0x0400
    case set           = 0x0800
}

enum Commands: UInt8  {
    case quit              = 0x01
    case initDB            = 0x02
    case query             = 0x03
    case fieldList         = 0x04
    case createDB          = 0x05
    case dropDB            = 0x06
    case refresh           = 0x07
    case shutdown          = 0x08
    case statistics        = 0x09
    case processInfo       = 0x0a
    case connect           = 0x0b
    case processKill       = 0x0c
    case debug             = 0x0d
    case ping              = 0x0e
    case time              = 0x0f
    case delayedInsert     = 0x10
    case changeUser        = 0x11
    case binlogDump        = 0x12
    case tableDump         = 0x13
    case connectOut        = 0x14
    case registerSlave     = 0x15
    case stmtPrepare       = 0x16
    case stmtExecute       = 0x17
    case stmdSendLongData  = 0x18
    case stmtClose         = 0x19
    case stmtReset         = 0x1a
    case setOption         = 0x1b
    case stmtFetch         = 0x1c
}

enum FieldTypes: UInt8 {
    case decimal    = 0x00
    case tiny       = 0x01 // int8, uint8, bool
    case short      = 0x02 // int16, uint16
    case long       = 0x03 // int32, uint32
    case float      = 0x04 // float32
    case double     = 0x05 // float64
    case null       = 0x06 // nil
    case timestamp  = 0x07 // Timestamp
    case longlong   = 0x08 // int64, uint64
    case int24      = 0x09
    case date       = 0x0a // Date
    case time       = 0x0b // Time
    case datetime   = 0x0c // time.Time
    case year       = 0x0d
    case newdate    = 0x0e
    case varchar    = 0x0f
    case bit        = 0x10
    case newdecimal = 0xf6
    case `enum`     = 0xf7
    case set        = 0xf8
    case tinyBlob   = 0xf9
    case mediumBlob = 0xfa
    case longBlob   = 0xfb
    case blob       = 0xfc // Blob
    case varString  = 0xfd // []byte
    case string     = 0xfe // string
    case geometory  = 0xff
}
