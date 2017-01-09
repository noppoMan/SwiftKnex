//
//  main.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

extension Date {
    func toMigrationFileDateTimeString() -> String {
        struct statDFT {
            static var dateStringFormatter :  DateFormatter? = nil
            static var token : Int = 0
        }
        
        // TODO once
        statDFT.dateStringFormatter = DateFormatter()
        statDFT.dateStringFormatter!.dateFormat = "yyyyMMddHHmmss"
        statDFT.dateStringFormatter!.locale = Locale(identifier: "en_US_POSIX")
        
        return statDFT.dateStringFormatter!.string(from: self)
    }
}


enum MigratorError: Error {
    case empty
    case commandNotFound(String)
}

extension MigratorError: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty:
            var text = ""
            text += "Usage: migration [options] [command]"
            text += "\n"
            text += "\n"
            text += "Commands"
            text += "\n"
            text += "  create <name>         Create a named migration file."
            text += "\n"
            return text
            
        case .commandNotFound(let cmd):
            return "The command [\(cmd)] is not found"
        }
    }
}

func exitWith(error: Error) {
    print("\(error)")
    exit(1)
}

guard CommandLine.arguments.count >= 3 else {
    print(MigratorError.empty)
    exit(1)
}

let command = CommandLine.arguments[1]

switch command {
case "create":
    let now = Date().toMigrationFileDateTimeString()
    let fileName = "\(now)_\(CommandLine.arguments[2])"
    
    let root = #file.characters
        .split(separator: "/", omittingEmptySubsequences: false)
        .dropLast(3)
        .map { String($0) }
        .joined(separator: "/")
    
    let templatePath = "\(root)/Templates/Migration-Class.swift.stab"
    
    do {
        let stab = try String(contentsOfFile: templatePath, encoding: .utf8)
        let output = stab.replacingOccurrences(of: "${migrationFileName}", with: fileName)
        
        let pwd = FileManager.default.currentDirectoryPath
        let destination = "\(pwd)/Sources/Migration/\(fileName).swift"
        try output.write(toFile: destination, atomically: true, encoding: .utf8)
        
        print("\n Created \(destination) \n")
        
    } catch {
        exitWith(error: error)
    }
    
default:
    exitWith(error: MigratorError.commandNotFound(command))
}
