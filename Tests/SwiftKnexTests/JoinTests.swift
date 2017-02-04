//
//  JoinTests.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/16.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class JoinTests: XCTestCase {
    
    static var allTests : [(String, (JoinTests) -> () throws -> Void)] {
        return [
            ("testJoin", testJoin)
        ]
    }
    
    var con: KnexConnection!
    
    override func setUp() {
        con = try! KnexConnection(config: basicKnexConfig())
        dropTable()
        try! con.knex().transaction { trx in
            _ = try! con.knex().execRaw(trx: trx, sql: testUserSchema().toDDL())
            _ = try! con.knex().insert(into: "test_users", collection: testUserCollection(), trx: trx)

            _ = try! con.knex().execRaw(trx: trx, sql: testUserLastLoginSchema().toDDL())
            _ = try! con.knex().insert(into: "test_user_last_logins", collection: testUserLastLoginCollection(), trx: trx)
        }
    }
    
    override func tearDown() {
        dropTable()
        try! con!.close()
    }
    
    func dropTable(){
        try! con.knex().transaction { trx in
            do {
                _ = try con.knex().execRaw(trx: trx, sql: Drop(table: "test_users").toDDL())
            } catch {
                
            }
            
            do {
                _ = try con.knex().execRaw(trx: trx, sql: Drop(table: "test_user_last_logins").toDDL())
            } catch {
            
            }
        }
    }
    
    func testJoin(){
        var rows: ResultSet?
        rows = try! con.knex()
            .table("test_users")
            .join("test_user_last_logins")
            .on("test_users.id" == "test_user_last_logins.user_id")
            .fetch()
        
        XCTAssertEqual(rows!.count, 3)
        
        rows = try! con.knex()
            .table("test_users")
            .leftJoin("test_user_last_logins")
            .on("test_users.id" == "test_user_last_logins.user_id")
            .fetch()
        
        XCTAssertEqual(rows!.count, 7)
        
        rows = try! con.knex()
            .table("test_users")
            .rightJoin("test_user_last_logins")
            .on("test_users.id" == "test_user_last_logins.user_id")
            .fetch()
        
        XCTAssertEqual(rows!.count, 3)
        
        rows = try! con.knex()
            .table("test_users")
            .innerJoin("test_user_last_logins")
            .on("test_users.id" == "test_user_last_logins.user_id")
            .fetch()
        
        XCTAssertEqual(rows!.count, 3)
    }
    
}

