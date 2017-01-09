//
//  Field.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/10.
//
//

struct Field {
    var tableName: String
    var name: String
    var flags: Flags
    var fieldType: FieldTypes
    var decimals: UInt8
    var origName: String
    var charSetNr: UInt8
    var collation: UInt8
}

struct Flags {
    let flags: UInt16
    
    init(flags: UInt16){
        self.flags = flags
    }
    
    func isUnsigned() -> Bool {
        return self.flags & FieldFlag.unsigned.rawValue == FieldFlag.unsigned.rawValue
    }
}

enum FieldParserError: Error {
    case tooLongColumns(Int)
}

final class FieldParser {
    
    var columns: [Field] = []
    
    let count: Int
    
    init(count: Int){
        self.count = count
    }
    
    func parse(bytes: [UInt8]) throws -> [Field]? {
        //EOF Packet
        if (bytes[0] == 0xfe) && ((bytes.count == 5) || (bytes.count == 1)) {
            if self.count != columns.count {
                throw FieldParserError.tooLongColumns(columns.count)
            }
            
            return columns
        }
        
        //Catalog
        var pos = skipLenEncStr(bytes)
        
        // Database [len coded string]
        var n = skipLenEncStr(Array(bytes[pos..<bytes.count]))
        pos += n
        
        // Table [len coded string]
        var table: String?
        (table, n) = lenEncStr(Array(bytes[pos..<bytes.count]))
        pos += n
        
        // Original table [len coded string]
        n = skipLenEncStr(Array(bytes[pos..<bytes.count]))
        pos += n
        
        // Name [len coded string]
        var name :String?
        (name, n) = lenEncStr(Array(bytes[pos..<bytes.count]))
        pos += n
        
        // Original name [len coded string]
        var origName :String?
        (origName, n) = lenEncStr(Array(bytes[pos..<bytes.count]))
        pos += n
        
        // Filler [uint8]
        pos +=  1
        // Charset [charset, collation uint8]
        let charSetNr = bytes[pos]
        let collation = bytes[pos + 1]
        // Length [uint32]
        pos +=  2 + 4
        
        // Field type [uint8]
        let fieldType = bytes[pos]
        pos += 1
        
        // Flags [uint16]
        let flags = bytes[pos...pos+1].uInt16()
        pos += 2
        
        // Decimals [uint8]
        let decimals = bytes[pos]
        
        //print(flags, fieldType, FieldFlag(rawValue: flags), FieldTypes(rawValue: fieldType))
        
        let f = Field(
            tableName: table ?? "",
            name: name ?? "",
            flags: Flags(flags: flags),
            fieldType: FieldTypes(rawValue: fieldType)!,
            decimals: decimals,
            origName: origName ?? "",
            charSetNr: charSetNr,
            collation: collation
        )
        
        columns.append(f)
        
        return nil
    }
}

