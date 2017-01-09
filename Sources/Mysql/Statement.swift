//
//  PacketSerializer.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/10.
//
//

import Foundation

public enum StatementError: Error {
    case argsCountMismatch
    case stmtIdNotSet
    case unknownType(String)
    case nilConnection
    case mySQLPacketToLarge
}

final class Statement {
    
    let prepareResult: PrepareResultPacket
    
    init(prepareResult: PrepareResultPacket) {
        self.prepareResult = prepareResult
    }
    
    func executePacket(params: [Any]) throws -> Bytes {
        if params.count != Int(prepareResult.paramCount) {
            throw StatementError.argsCountMismatch
        }
        
        //let pktLen = 4 + 1 + 4 + 1 //+ 4
        //con?.socket?.packnr = -1
        
        var bytes = [UInt8]()
        
        // command [1 byte]
        bytes.append(Commands.stmtExecute.rawValue)
        
        // statement_id [4 bytes]
        bytes.append(contentsOf: [UInt8].UInt32Array(prepareResult.id))
        
        // flags (0: CURSOR_TYPE_NO_CURSOR) [1 byte]
        bytes.append(0)
        
        // iteration_count (uint32(1)) [4 bytes]
        bytes.append(contentsOf:[1, 0, 0, 0])
        
        if params.count > 0 {
            let nmLen = (params.count + 7)/8 //(args.count + 7)>>3
            var nullBitmap = [UInt8](repeating:0, count: nmLen)
            
            for index in 0..<params.count {
                let mi = Mirror(reflecting: params[index])
                
                //check for null value
                if ((mi.displayStyle == .optional) && (mi.children.count == 0)) || params[index] is NSNull {
                    let nullByte = index >> 3
                    let nullMask = UInt8(UInt(1) << UInt(index-(nullByte<<3)))
                    nullBitmap[nullByte] |= nullMask
                }
            }
            
            //null Mask
            bytes.append(contentsOf: nullBitmap)
            //Types
            bytes.append(1)
            //Data Type
            
            var dataTypes = [UInt8]()
            var args = [UInt8]()
            
            for parameter in params {
                let mi = Mirror(reflecting: parameter)
                
                if ((mi.displayStyle == .optional) && (mi.children.count == 0)) || parameter is NSNull {
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.null.rawValue))
                    continue
                }
                switch parameter {
                case let param as Int64:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.longlong.rawValue))
                    args += [UInt8].Int64Array(param)
                    
                case let param as UInt64:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.longlong.rawValue))
                    args += [UInt8].UInt64Array(param)
                    
                case let param as Int:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.long.rawValue))
                    args += [UInt8].IntArray(param)
                    
                case let param as UInt:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.long.rawValue))
                    args += [UInt8].UIntArray(param)
                    
                case let param as Int32:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.long.rawValue))
                    args += [UInt8].Int32Array(param)
                    
                case let param as UInt32:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.long.rawValue))
                    args += [UInt8].UInt32Array(param)
                    
                case let param as Int16:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.short.rawValue))
                    args +=  [UInt8].Int16Array(Int16(param))
                    
                case let param as UInt16:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.short.rawValue))
                    args += [UInt8].UInt16Array(UInt16(param))
                    
                case let param as Int8:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.tiny.rawValue))
                    args += param.array()
                    
                case let param as UInt8:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.tiny.rawValue))
                    args += param.array()
                    
                case let param as Double:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.double.rawValue))
                    args += [UInt8].DoubleArray(param)
                    
                case let param as Float:
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.float.rawValue))
                    args += [UInt8].FloatArray(param)
                    
                case let param as [UInt8]:
                    if param.count < maxPackAllowed - 1024*1024 {
                        let lenArr = lenEncIntArray(UInt64(param.count))
                        dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.blob.rawValue))
                        args += lenArr
                        args += param
                    } else {
                        throw StatementError.mySQLPacketToLarge
                    }
                    
                case let param as Data:
                    let count = param.count / MemoryLayout<UInt8>.size
                    
                    if count < maxPackAllowed - 1024*1024 {
                        var arr = [UInt8](repeating:0, count: count)
                        param.copyBytes(to: &arr, count: count)
                        
                        let lenArr = lenEncIntArray(UInt64(arr.count))
                        dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.longBlob.rawValue))
                        args += lenArr
                        args += arr
                    } else {
                        throw StatementError.mySQLPacketToLarge
                    }
                    
                case let param as String:
                    if param.characters.count < maxPackAllowed - 1024*1024 {
                        let lenArr = lenEncIntArray(UInt64(param.characters.count))
                        dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.string.rawValue))
                        args += lenArr
                        args += [UInt8](param.utf8)
                    } else {
                        throw StatementError.mySQLPacketToLarge
                    }
                    
                case let param as Date:
                    let arr = [UInt8](param.dateTimeString().utf8)
                    let lenArr = lenEncIntArray(UInt64(arr.count))
                    dataTypes += [UInt8].UInt16Array(UInt16(FieldTypes.string.rawValue))
                    args += lenArr
                    args += arr
                    
                default:
                    throw StatementError.unknownType("\(mi.subjectType)")
                }
            }
            
            bytes += dataTypes
            bytes += args
        }
        
        return bytes
        
        //return (bytes, -1)
    }
}
