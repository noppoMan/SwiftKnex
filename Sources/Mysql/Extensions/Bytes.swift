//Copyright (c) 2015, Marius Corega
//All rights reserved.
//
//Permission is granted to anyone to use this software for any purpose,
//including commercial applications, and to alter it and redistribute it freely.
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions are met:
//
//* Redistributions of source code must retain the above copyright notice, this
//list of conditions and the following disclaimer.
//
//* Redistributions in binary form must reproduce the above copyright notice,
//this list of conditions and the following disclaimer in the documentation
//and/or other materials provided with the distribution.
//
//* Neither the name of the {organization} nor the names of its
//contributors may be used to endorse or promote products derived from
//this software without specific prior written permission.
//    
//    * If you use this software in a product, an acknowledgment in the product
//documentation is required.Altered source versions must be plainly marked
//as such, and must not be misrepresented as being the original software.
//This notice may not be removed or altered from any source or binary distribution.
//
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Foundation

func arrayOfBytes<T: Integer>(_ value: T, length totalBytes: Int = MemoryLayout<T>.size) -> Array<UInt8> {
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytesPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(valuePointer))
    var bytes = Array<UInt8>(repeating: 0, count: totalBytes)
    for j in 0 ..< min(MemoryLayout<T>.size, totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
    }
    
    valuePointer.deinitialize()
    valuePointer.deallocate(capacity: 1)
    
    return bytes
}

extension Int8 {
    init(_ arr:ArraySlice<UInt8>) {
        var val:Int8 = 0
        let arrr = Array(arr)
        memccpy(&val, arrr, 1, 1)
        self = val
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}

extension UInt8 {
    init(_ arr:ArraySlice<UInt8>) {
        self = UInt8(arr[arr.startIndex])
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}


extension Int16 {
    init(_ arr:ArraySlice<UInt8>) {
        self = Int16(arr[arr.startIndex + 1])<<8 | Int16(arr[arr.startIndex])
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}

extension UInt16 {
    init(_ arr:ArraySlice<UInt8>) {
        self = UInt16(arr[arr.startIndex + 1])<<8 | UInt16(arr[arr.startIndex])
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}

extension UInt32 {
    init(_ arr:ArraySlice<UInt8>) {
        var res : UInt32 = 0
        for i in 0..<4 {
            res |= UInt32(arr[arr.startIndex + i]) << UInt32(i*8)
        }
        self = res
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}

extension UInt {
    init(_ arr:ArraySlice<UInt8>) {
        var res : UInt = 0
        for i in 0..<4 {
            res |= UInt(arr[arr.startIndex + i]) << UInt(i*8)
        }
        self = res
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}

extension Int {
    init(_ arr:ArraySlice<UInt8>) {
        var res : Int = 0
        for i in 0..<4 {
            res |= Int(arr[arr.startIndex + i]) << Int(i*8)
        }
        //self = res
        self = Int(arr[arr.startIndex + 3])<<24 | Int(arr[arr.startIndex + 2])<<16 | Int(arr[arr.startIndex + 1])<<8 | Int(arr[arr.startIndex])
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}

extension Int32 {
    init(_ arr:ArraySlice<UInt8>) {
        var res : Int32 = 0
        for i in 0..<4 {
            res |= Int32(arr[arr.startIndex + i]) << Int32(i*8)
        }
        self = res
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}

extension Int64 {
    init(_ arr:ArraySlice<UInt8>) {
        var res : Int64 = 0
        for i in 0..<8 {
            res |= Int64(arr[arr.startIndex + i]) << Int64(i*8)
        }
        self = res
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}

extension UInt64 {
    init(_ arr:ArraySlice<UInt8>) {
        var res : UInt64 = 0
        for i in 0..<8 {
            res |= UInt64(arr[arr.startIndex + i]) << UInt64(i*8)
        }
        self = res
    }
    
    func array() ->[UInt8] {
        return arrayOfBytes(self)
    }
}


extension Sequence where Iterator.Element == UInt8 {
    func uInt16() -> UInt16 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        return UInt16(arr[1])<<8 | UInt16(arr[0])
    }
    
    func int16() -> Int16 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        return Int16(arr[1])<<8 | Int16(arr[0])
    }
    
    
    func uInt24() -> UInt32 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        return UInt32(arr[2])<<16 | UInt32(arr[1])<<8 | UInt32(arr[0])
    }
    
    func int32() -> Int32 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        
        return Int32(arr[3])<<24 | Int32(arr[2])<<16 | Int32(arr[1])<<8 | Int32(arr[0])
    }
    
    func uInt32() -> UInt32 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        
        return UInt32(arr[3])<<24 | UInt32(arr[2])<<16 | UInt32(arr[1])<<8 | UInt32(arr[0])
    }
    
    func uInt64() -> UInt64 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        
        var res : UInt64 = 0
        
        for i in 0..<arr.count {
            res |= UInt64(arr[i]) << UInt64(i*8)
        }
        
        return res
    }
    
    func int64() -> Int64 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        
        var res : Int64 = 0
        
        for i in 0..<arr.count {
            res |= Int64(arr[i]) << Int64(i*8)
        }
        
        return res
    }
    
    func float32() -> Float32 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        
        var f:Float32 = 0.0
        
        memccpy(&f, arr, 4, 4)
        
        return f
    }
    
    func float64() -> Float64 {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        
        var f:Float64 = 0.0
        
        memccpy(&f, arr, 8, 8)
        
        return f
    }
    
    func string() -> String? {
        let arr = self.map { (elem) -> UInt8 in
            return elem
        }
        
        guard (arr.count > 0) && (arr[arr.count-1] == 0) else {
            return ""
        }
        
        return String(cString: UnsafePointer<UInt8>(arr))
    }
    
    static func UInt24Array(_ val: UInt32) -> [UInt8]{
        
        
        var byteArray = [UInt8](repeating: 0, count: 3)
        
        for i in 0...2 {
            byteArray[i] = UInt8(0x0000FF & val >> UInt32((i) * 8))
        }
        
        return byteArray
    }
    
    static func DoubleArray(_ val: Double) -> [UInt8]{
        var d = val
        var arr = [UInt8](repeating:0, count: 8)
        memccpy(&arr, &d, 8, 8)
        return arr
    }
    
    static func FloatArray(_ val: Float) -> [UInt8]{
        var d = val
        var arr = [UInt8](repeating: 0, count: 4)
        memccpy(&arr, &d, 4, 4)
        return arr
    }
    
    static func Int32Array(_ val: Int32) -> [UInt8]{
        var byteArray = [UInt8](repeating:0, count: 4)
        
        for i in 0...3 {
            byteArray[i] = UInt8(0x0000FF & val >> Int32((i) * 8))
        }
        
        return byteArray
        
    }
    
    static func Int64Array(_ val: Int64) -> [UInt8]{
        var byteArray = [UInt8](repeating:0, count: 8)
        
        for i in 0...7 {
            byteArray[i] = UInt8(0x0000FF & val >> Int64((i) * 8))
        }
        
        return byteArray
    }
    
    
    static func UInt32Array(_ val: UInt32) -> [UInt8]{
        var byteArray = [UInt8](repeating:0, count: 4)
        
        for i in 0...3 {
            byteArray[i] = UInt8(0x0000FF & val >> UInt32((i) * 8))
        }
        
        return byteArray
    }
    
    static func Int16Array(_ val: Int16) -> [UInt8]{
        var byteArray = [UInt8](repeating:0, count: 2)
        
        for i in 0...1 {
            byteArray[i] = UInt8(0x0000FF & val >> Int16((i) * 8))
        }
        
        return byteArray
    }
    
    static func UInt16Array(_ val: UInt16) -> [UInt8]{
        var byteArray = [UInt8](repeating:0, count: 2)
        
        for i in 0...1 {
            byteArray[i] = UInt8(0x0000FF & val >> UInt16((i) * 8))
        }
        
        return byteArray
    }
    
    
    static func IntArray(_ val: Int) -> [UInt8]{
        var byteArray = [UInt8](repeating:0, count: 4)
        
        for i in 0...3 {
            byteArray[i] = UInt8(0x0000FF & val >> Int((i) * 8))
        }
        
        return byteArray
    }
    
    static func UIntArray(_ val: UInt) -> [UInt8]{
        var byteArray = [UInt8](repeating:0, count: 4)
        
        for i in 0...3 {
            byteArray[i] = UInt8(0x0000FF & val >> UInt((i) * 8))
        }
        
        return byteArray
    }
    
    static func UInt64Array(_ val: UInt64) -> [UInt8]{
        var byteArray = [UInt8](repeating:0, count: 8)
        
        for i in 0...7 {
            byteArray[i] = UInt8(0x0000FF & val >> UInt64((i) * 8))
        }
        
        return byteArray
    }
    
}
