//
//  UpdateTests.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/16.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class UpdateTests: XCTestCase {
    
    static var allTests : [(String, (UpdateTests) -> () throws -> Void)] {
        return [
            ("testUpdateById", testUpdateById)
        ]
    }
    
    var con: KnexConnection!
    
    override func setUp() {
        con = try! KnexConnection(config: basicKnexConfig())
        dropTable()
        try! con.knex().transaciton { trx in
            _ = try! con.knex().execRaw(trx: trx, sql: testUserSchema().toDDL())
            _ = try! con.knex().insert(into: "test_users", collection: testUserCollection(), trx: trx)
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
    
    func testUpdateById(){
        let res: QueryStatus?
        res = try! con.knex().table("test_users").where("id" == 1).update(sets: ["age": 30, "email": "foo@example.com"])
        XCTAssertEqual(res!.affectedRows, 1)
    }
}
