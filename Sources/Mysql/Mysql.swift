@_exported import Prorsum
import CLibreSSL
import Foundation

enum MySQLError: Error {
    case rawError(Int, String)
}

func createErrorFrom(errorPacket bytes :[UInt8]) -> MySQLError {
    if bytes[0] != 0xff {
        return MySQLError.rawError(-1, "EOF encountered")
    }
    
    let errno = bytes[1...3].uInt16()
    var pos = 3
    
    if bytes[3] == 0x23 {
        pos = 9
    }
    var d1 = Array(bytes[pos..<bytes.count])
    d1.append(0)
    let errStr = d1.string()
    
    return MySQLError.rawError(Int(errno), errStr!)
}

func sha1(_ data: [UInt8]) -> [UInt8] {
    var md = [UInt8].init(repeating: 0, count: Int(SHA_DIGEST_LENGTH))
    var d = data
    SHA1(&d, data.count, &md)
    
    return md
}

func encryptPassword(for password: String, scramble: [UInt8]) -> [UInt8]{
    if password.isEmpty {
        return []
    }
    
    let s1 = sha1([UInt8](password.utf8))
    let s2 = sha1(s1)
    
    var scr = scramble
    scr.append(contentsOf: s2)
    
    var s3 = sha1(scr)
    
    for i in 0..<s3.count {
        s3[i] ^= s1[i]
    }
    
    return s3
}

private func escapeData(_ data: [UInt8]) -> String {
    var res = [UInt8]()
    //var resStr = ""
    
    for v in data {
        // let s = Character(UnicodeScalar(v))
        // switch s {
        switch v {
        case 0:
            // case Character("\0"):
            res += [UInt8]("\\0".utf8)
            //    resStr += "\\0"
            break
            
        case 10:
            //case Character("\n"):
            res += [UInt8]("\\n".utf8)
            // resStr += "\\n"
            break
            
        case 92:
            //case Character("\\"):
            res += [UInt8]("\\\\".utf8)
            //  resStr += "\\\\"
            break
            
        case 13:
            //case Character("\r"):
            res += [UInt8]("\\r".utf8)
            //    resStr += "\\r"
            break
            
        case 39:
            //case Character("\'"):
            res += [UInt8]("\\'".utf8)
            //   resStr += "\\'"
            break
            
        case 34:
            //case Character("\""):
            res += [UInt8]("\\\"".utf8)
            //  resStr += "\\\""
            break
            
        case 0x1A:
            //case Character(UnicodeScalar(0x1a)):
            res += [UInt8]("\\Z".utf8)
            //    resStr += "\\Z"
            break
            
        default:
            res.append(v)
            //resStr.append(Character(UnicodeScalar(v)))
        }
    }
    
    //        res.append(0)
    if let str = NSString(bytes: res, length: res.count, encoding: String.Encoding.ascii.rawValue) {
        //        if let str = String(bytes: res, encoding: NSASCIIStringEncoding) {
        #if os(Linux)
            return str.bridge()
        #else
            return str as String
        #endif
    }
    
    //return resStr
    return ""
}

func stringValue(_ val: Any) -> String {
    switch val {
    case is UInt8, is Int8, is Int, is UInt, is UInt16, is Int16, is UInt32, is Int32,
         is UInt64, is Int64, is Float, is Double:
        return "\(val)"
    case is String:
        return "\"\(val)\""
    case is Data:
        let v = val as! Data
        
        let count = v.count / MemoryLayout<UInt8>.size
        
        // create an array of Uint8
        var array = [UInt8](repeating:0, count: count)
        
        // copy bytes into array
        v.copyBytes(to: &array, count:count * MemoryLayout<UInt8>.size)
        
        
        let str = escapeData(array)
        
        return "\"\(str)\""
        
        
    default:
        return ""
    }
}

func skipLenEncStr(_ data: [UInt8]) -> Int {
    var (_num, n) = lenEncInt(data)
    
    guard let num = _num else {
        return 0
    }
    
    if num < 1 {
        return n
    }
    
    n += Int(num)
    
    if data.count >= n {
        return n
    }
    return n
}

func lenEncBin(_ b:[UInt8]) ->([UInt8]?, Int) {
    
    var (_num, n) = lenEncInt(b)
    
    guard let num = _num else {
        return (nil, 0)
    }
    
    if num < 1 {
        
        return (nil, n)
    }
    
    n += Int(num)
    
    if b.count >= n {
        let str = Array(b[n-Int(num)...n-1])
        return (str, n)
    }
    
    return (nil, n)
}


func lenEncStr(_ b: [UInt8]) -> (String?, Int) {
    
    var (_num, n) = lenEncInt(b)
    
    guard let num = _num else {
        return (nil, 0)
    }
    
    if num < 1 {
        
        return ("", n)
    }
    
    n += Int(num)
    
    if b.count >= n {
        var str = Array(b[n-Int(num)...n-1])
        str.append(0)
        return (str.string(), n)
    }
    
    return ("", n)
}

func lenEncIntArray(_ v:UInt64) -> [UInt8] {
    
    if v <= 250 {
        return [UInt8(v & 0xff)]
    }
    else if v <= 0xffff {
        return [0xfc, UInt8(v & 0xff), UInt8((v>>8)&0xff)]
    }
    else if v <= 0xffffff {
        return [0xfd, UInt8(v & 0xff), UInt8((v>>8)&0xff), UInt8((v>>16)&0xff)]
    }
    
    return [0xfe, UInt8(v & 0xff), UInt8((v>>8) & 0xff), UInt8((v>>16) & 0xff), UInt8((v>>24) & 0xff),
            UInt8((v>>32) & 0xff), UInt8((v>>40) & 0xff), UInt8((v>>48) & 0xff), UInt8((v>>56) & 0xff)]
}

func lenEncInt(_ b: [UInt8]) -> (UInt64?, Int) {
    
    if b.count == 0 {
        return (nil, 1)
    }
    
    switch b[0] {
        
    // 251: NULL
    case 0xfb:
        return (nil, 1)
        
    // 252: value of following 2
    case 0xfc:
        return (UInt64(b[1]) | UInt64(b[2])<<8, 3)
        
    // 253: value of following 3
    case 0xfd:
        return (UInt64(b[1]) | UInt64(b[2])<<8 | UInt64(b[3])<<16, 4)
        
    // 254: value of following 8
    case 0xfe:
        return (UInt64(b[1]) | UInt64(b[2])<<8 | UInt64(b[3])<<16 |
            UInt64(b[4])<<24 | UInt64(b[5])<<32 | UInt64(b[6])<<40 |
            UInt64(b[7])<<48 | UInt64(b[8])<<56, 9)
    default:
        break
    }
    
    // 0-250: value of first byte
    return (UInt64(b[0]), 1)
}
