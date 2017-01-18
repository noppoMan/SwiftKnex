//
//  TransactionTests.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/16.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class TransactionTests: XCTestCase {
    
    static var allTests : [(String, (TransactionTests) -> () throws -> Void)] {
        return [
            ("testTransactionCommit", testTransactionCommit),
            ("testTransactionRollback", testTransactionRollback)
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
    
    func testTransactionCommit(){
        try! con.knex().transaciton { trx in
            XCTAssertEqual(con.knex().connection.availableConnection, 3)
            _ = try con.knex().insert(into: "test_users", collection: testUserCollection(), trx: trx)
            _ = try con.knex().table("test_users").where("id" == 1).update(sets: ["age": 10], trx: trx)
            _ = try con.knex().table("test_users").where("id" == 2).update(sets: ["age": 20], trx: trx)
            _ = try con.knex().table("test_users").where("id" == 3).update(sets: ["age": 30], trx: trx)
        }
        XCTAssertEqual(con.knex().connection.availableConnection, 4)
        let rows = try! con.knex().table("test_users").where(.in("id", [1, 2, 3])).fetch()
        XCTAssertEqual(rows![0]["age"] as! Int, 10)
        XCTAssertEqual(rows![1]["age"] as! Int, 20)
        XCTAssertEqual(rows![2]["age"] as! Int, 30)
    }
    
    func testTransactionRollback() {
        do {
            try con.knex().transaciton { trx in
                XCTAssertEqual(con.knex().connection.availableConnection, 3)
                _ = try con.knex().insert(into: "test_users", collection: testUserCollection(), trx: trx)
                _ = try con.knex().table("test_users").where("id" == 1).update(sets: ["age": 10], trx: trx)
                _ = try con.knex().table("test_users").where("id" == 2).update(sets: ["age": 20], trx: trx)
                _ = try con.knex().table("test_users").where("id" == 3).update(sets: ["fugaduga": 30], trx: trx)
            }
        } catch {
            XCTAssertEqual(con.knex().connection.availableConnection, 4)
            let rows = try! con.knex().table("test_users").fetch()
            XCTAssert(rows == nil)
        }
    }
}
