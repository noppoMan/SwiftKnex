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

import Foundation

extension Date {
    init?(dateString:String?) {
        guard dateString != nil else {
            return nil
        }
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let d = dateStringFormatter.date(from: dateString!) {
            self.init(timeInterval:0, since:d)
            return
        }
        return nil
    }
    
    
    init?(timeString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "HH-mm-ss"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let d = dateStringFormatter.date(from: timeString) {
            self.init(timeInterval:0, since:d)
            return
        }
        return nil
    }
    
    init?(timeStringUsec:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "HH-mm-ss.SSSSSS"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let d = dateStringFormatter.date(from: timeStringUsec) {
            self.init(timeInterval:0, since:d)
            return
        }
        return nil
    }
    
    init?(dateTimeString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let d = dateStringFormatter.date(from: dateTimeString) {
            self.init(timeInterval:0, since:d)
        }
        else {
            return nil
        }
    }
    
    init?(dateTimeStringUsec: String) {
        
        struct statDFT {
            static var dateStringFormatter :  DateFormatter? = nil
            static var token : Int = 0
        }
        
        // TODO once
        statDFT.dateStringFormatter = DateFormatter()
        statDFT.dateStringFormatter!.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        statDFT.dateStringFormatter!.locale = Locale(identifier: "en_US_POSIX")
        
        if let d = statDFT.dateStringFormatter!.date(from: dateTimeStringUsec) {
            self.init(timeInterval:0, since:d)
        }
        else {
            return nil
        }
    }
    
    func dateString() -> String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateStringFormatter.string(from: self)
    }
    
    func timeString() -> String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "hh-mm-ss"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateStringFormatter.string(from: self)
    }
    
    func dateTimeString() -> String {
        struct statDFT {
            static var dateStringFormatter :  DateFormatter? = nil
            static var token : Int = 0
        }
        
        // TODO once
        statDFT.dateStringFormatter = DateFormatter()
        statDFT.dateStringFormatter!.dateFormat = "yyyy-MM-dd HH:mm:ss"
        statDFT.dateStringFormatter!.locale = Locale(identifier: "en_US_POSIX")
        
        return statDFT.dateStringFormatter!.string(from: self)
    }
}
