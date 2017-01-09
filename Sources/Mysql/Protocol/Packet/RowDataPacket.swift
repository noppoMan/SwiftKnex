//
//  RowDataPacket.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

import Foundation

class RowDataPacket: RowDataParsable {
    
    let columns: [Field]
    
    var hasMoreResults = false
    
    required init(columns: [Field]) {
        self.columns = columns
    }
    
    func parse(bytes: [UInt8]) throws -> Row? {
        if (bytes[0] == 0xfe) && (bytes.count == 5) {
            let flags = Array(bytes[3..<5]).uInt16()
            self.hasMoreResults = flags & serverMoreResultsExists == serverMoreResultsExists
            return nil
        }
        
        if bytes[0] == 0xff {
            throw createErrorFrom(errorPacket: bytes)
        }
        
        var row = Row()
        var pos = 0
        
        for index in 0...columns.count-1 {
            let (name, n) = lenEncStr(Array(bytes[pos..<bytes.count]))
            pos += n
            
            let column = columns[index]
            
            if let value = name {
                switch column.fieldType {
                case .varString:
                    row[column.name] = value
                    
                case .longlong:
                    row[column.name] = column.flags.isUnsigned() ? UInt64(value) : Int64(value)
                    
                case .int24:
                    row[column.name] = column.flags.isUnsigned() ? UInt(value) : Int(value)
                    
                case .short:
                    row[column.name] = column.flags.isUnsigned() ? UInt16(value) : Int16(value)
                    
                case .tiny:
                    row[column.name] = column.flags.isUnsigned() ? UInt8(value) : Int8(value)
                    
                case .double:
                    row[column.name] = Double(value)
                    
                case .float:
                    row[column.name] = Float(value)
                    
                case .date:
                    row[column.name] = Date(dateString: String(value))
                    
                case .time:
                    row[column.name] = Date(timeString: String(value))
                    
                case .datetime:
                    row[column.name] = Date(dateTimeString: String(value))
                    
                case .timestamp:
                    row[column.name] = Date(dateTimeString: String(value))
                    
                case .null:
                    row[column.name] = NSNull()
                    
                default:
                    row[column.name] = NSNull()
                    
                }
            } else {
                row[column.name] = NSNull()
            }
        }
        
        return row
    }
}
