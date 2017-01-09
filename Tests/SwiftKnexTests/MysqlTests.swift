//
//  MysqlTest.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class MysqlTests: XCTestCase {
    
    static var allTests : [(String, (MysqlTests) -> () throws -> Void)] {
        return [
            ("testConnection", testConnection),
            ("testQuery", testQuery),
            ("testNoRecord", testNoRecord),
            ("testPreparedStatement", testPreparedStatement)
        ]
    }
    
    func testConnection() {
        let url = URL(string: "mysql://localhost:3306")
        let con = try! Connection(url: url!, user: "root", password: nil)
        XCTAssertEqual(con.isClosed, false)
        try! con.close()
    }
    
    func testQuery() {
        let url = URL(string: "mysql://localhost:3306")
        let con = try! Connection(url: url!, user: "root", password: nil, database: "mysql")
        let result = try! con.query("show tables like 'user'")
        XCTAssertEqual(result.asResultSet()!.count, 1)
        try! con.close()
    }

    func testNoRecord() {
        let url = URL(string: "mysql://localhost:3306")
        let con = try! Connection(url: url!, user: "root", password: nil, database: "mysql")
        let result = try! con.query("show tables like 'foobar'")
        XCTAssertTrue(result.isNoRecord)
        try! con.close()
    }
    
    func testPreparedStatement() {
        let url = URL(string: "mysql://localhost:3306")
        let con = try! Connection(url: url!, user: "root", password: nil, database: "mysql")
        con.isShowSQLLog = true
        let result = try! con.query("select * from user where User = ?", bindParams: ["root"])
        XCTAssertNotEqual(result.asResultSet()!.count, 0)
        try! con.close()
    }
}

