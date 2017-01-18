//
//  InsertTests.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class InsertTests: XCTestCase {
    
    static var allTests : [(String, (InsertTests) -> () throws -> Void)] {
        return [
            ("testInsert", testInsert),
            ("testBatchInsert", testBatchInsert),
            ("testTypeSafeInsert", testTypeSafeInsert)
        ]
    }
    
    var con: KnexConnection!
    
    override func setUp() {
        con = try! KnexConnection(config: basicKnexConfig())
        dropTable()
        try! con.knex().transaciton { trx in
            _ = try! con.knex().execRaw(trx: trx, sql: testUserSchema().toDDL())
        }
    }
    
    override func tearDown() {
        dropTable()
        try! con!.close()
    }
    
    func dropTable(){
        do {
            _ = try con.knex().execRaw(sql: Drop(table: "test_users").toDDL())
        } catch {
            // Skip
        }
    }
    
    func testInsert(){
        let res: QueryStatus?
        res = try! con.knex().insert(into: "test_users", values: [
            "email": "test@example.com",
            "name": "test-user",
            "age": 32
        ])
        XCTAssertEqual(res!.insertId, 1)
    }
    
    func testBatchInsert(){
        let res: QueryStatus?
        
        res = try! con.knex().insert(into: "test_users", collection: [
            [
                "email": "test@example.com",
                "name": "test-user",
                "age": 32
            ],
            [
                "email": "test2@example.com",
                "name": "test-user2",
                "age": 32,
                "country": "Japan"
            ]
        ])
        XCTAssertEqual(res!.affectedRows, 2)
    }
    
    func testTypeSafeInsert() {
        let user = User(id: 1, name: "new-user", email: "new-user@example.com", age: 30, country: nil)
        let res = try! con.knex().insert(into: "test_users", values: user)
        XCTAssertEqual(res!.insertId, 1)
    }
}
