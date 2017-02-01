//
//  BinaryRowDataPacket.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/12.
//
//

import Foundation

class BinaryRowDataPacket: RowDataParsable {
    
    let columns: [Field]
    
    var hasMoreResults = false
    
    required init(columns: [Field]) {
        self.columns = columns
    }
    
    func parse(bytes: [UInt8]) throws -> Row? {
        if columns.isEmpty {
            return nil
        }

        if bytes[0] != 0x00 {
            if bytes[0] == 0xfe && bytes.count == 5 {
                let flags = Array(bytes[3..<5]).uInt16()
                self.hasMoreResults = flags & serverMoreResultsExists == serverMoreResultsExists
                return nil
            }

            if bytes[0] == 0xff {
                throw createErrorFrom(errorPacket: bytes)
            }

            guard bytes[0] > 0 && bytes[0] < 251 else {
                return nil
            }
        }

        var pos = 1 + (columns.count + 7 + 2)>>3
        let nullBitmap = Array(bytes[1..<pos])
        var row = Row()

        for index in 0..<columns.count {
            let idx = (index+2)>>3
            let shiftval = UInt8((index+2)&7)
            let val = nullBitmap[idx] >> shiftval
            let column = columns[index]

            if (val & 1) == 1 {
                row[column.name] = NSNull()
                continue
            }

            switch column.fieldType {
            case .null:
                row[column.name] = NSNull()

            case .tiny:
                row[column.name] = column.flags.isUnsigned() ? UInt8(bytes[pos..<pos+1]) : Int8(bytes[pos..<pos+1])
                pos += 1

            case .short:
                row[column.name] = column.flags.isUnsigned() ? UInt16(bytes[pos..<pos+2]) : Int16(bytes[pos..<pos+2])
                pos += 2

            case .int24, .long:
                row[column.name] = column.flags.isUnsigned() ? UInt(UInt32(bytes[pos..<pos+4])) : Int(Int32(bytes[pos..<pos+4]))
                pos += 4

            case .longlong:
                row[column.name] = column.flags.isUnsigned() ? UInt64(bytes[pos..<pos+8]) : Int64(bytes[pos..<pos+8])
                pos += 8

            case .float:
                row[column.name] = bytes[pos..<pos+4].float32()
                pos += 4

            case .double:
                row[column.name] = bytes[pos..<pos+8].float64()
                pos += 8

            case .blob, .mediumBlob, .varchar, .varString, .string, .longBlob:
                if column.charSetNr == 63 {
                    let (bres, n) = lenEncBin(Array(bytes[pos..<bytes.count]))
                    row[column.name] = bres
                    pos += n
                }
                else {
                    let (str, n) = lenEncStr(Array(bytes[pos..<bytes.count]))
                    row[column.name] = str
                    pos += n
                }

            case .decimal, .newdecimal, .bit, .`enum`, .set, .geometory, .json:
                let (str, n) = lenEncStr(Array(bytes[pos..<bytes.count]))
                row[column.name] = str
                pos += n

            case .date:
                let (_dlen, n) = lenEncInt(Array(bytes[pos..<bytes.count]))
                guard let dlen = _dlen else {
                    row[column.name] = NSNull()
                    break
                }

                var y = 0, mo = 0, d = 0//, h = 0, m = 0, s = 0, u = 0
                var res : Date?

                switch Int(dlen) {
                case 11:
                    fallthrough
                case 7:
                    fallthrough
                case 4:
                    // 2015-12-02
                    y = Int(bytes[pos+1..<pos+3].uInt16())
                    mo = Int(bytes[pos+3])
                    d = Int(bytes[pos+4])
                    res = Date(dateString: String(format: "%4d-%02d-%02d", arguments: [y, mo, d]))
                default:
                    break
                }

                row[column.name] = res ?? NSNull()

                pos += n + Int(dlen)

            case .time:
                let (_dlen, n) = lenEncInt(Array(bytes[pos..<bytes.count]))
                guard let dlen = _dlen else {
                    row[column.name] = NSNull()
                    break
                }

                var h = 0, m = 0, s = 0, u = 0
                var res : Date?

                switch Int(dlen) {
                case 12:
                    //12:03:15.000 001
                    u = Int(bytes[pos+9..<pos+13].uInt32())
                    //res += String(format: ".%06d", u)
                    fallthrough
                case 8:
                    //12:03:15
                    h = Int(bytes[pos+6])
                    m = Int(bytes[pos+7])
                    s = Int(bytes[pos+8])
                    res = Date(timeStringUsec: String(format: "%02d:%02d:%02d.%06d", arguments: [h, m, s, u]))
                default:
                    res = Date(timeString: "00:00:00")
                    break
                }

                row[column.name] = res ?? NSNull()

                pos += n + Int(dlen)

            case .timestamp, .datetime:
                let (_dlen, n) = lenEncInt(Array(bytes[pos..<bytes.count]))

                guard let dlen = _dlen else {
                    row[column.name] = NSNull()
                    break
                }

                var y = 0, mo = 0, d = 0, h = 0, m = 0, s = 0, u = 0
                //var res = ""

                switch Int(dlen) {
                case 11:
                    u = Int(bytes[pos+8..<pos+12].uInt32())
                    fallthrough
                case 7:
                    h = Int(bytes[pos+5])
                    m = Int(bytes[pos+6])
                    s = Int(bytes[pos+7])
                    fallthrough
                case 4:
                    // 2015-12-02
                    y = Int(bytes[pos+1..<pos+3].uInt16())
                    mo = Int(bytes[pos+3])
                    d = Int(bytes[pos+4])
                    //res = String(format: "%4d-%02d-%02d", arguments: [y, mo, d]) + " " + res
                default:
                    break
                }

                let dstr = String(format: "%4d-%02d-%02d %02d:%02d:%02d.%06d", arguments: [y, mo, d, h, m, s, u])
                row[column.name] = Date(dateTimeStringUsec: dstr) ?? NSNull()

                pos += n + Int(dlen)
            default:
                row[column.name] = NSNull()
            }
        }
        
        return row
    }
}
