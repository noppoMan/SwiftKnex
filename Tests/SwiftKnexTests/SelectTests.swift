//
//  SelectTests.swift
//  SwiftKnex
//
//  Created by Yuki Takei on 2017/01/15.
//
//

import XCTest
@testable import SwiftKnex
import Foundation

class SelectTests: XCTestCase {
    
    static var allTests : [(String, (SelectTests) -> () throws -> Void)] {
        return [
            ("testWehre", testWehre),
            ("testTypeSafeFetch", testTypeSafeFetch),
            ("testOrderBy", testOrderBy),
            ("testLimitOffset", testLimitOffset),
            ("testGroupBy", testGroupBy),
            ("testHaving", testHaving)
        ]
    }
    
    var con: KnexConnection!
    
    override func setUp() {
        con = try! KnexConnection(config: basicKnexConfig())
        dropTable()
        try! con.knex().transaction { trx in
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
    
    func testWehre() {
        var rows: ResultSet?
        rows = try! con.knex().table("test_users").where("email" == "jack@example.com").fetch()
        XCTAssert(rows!.count == 1)
        
        rows = try! con.knex().table("test_users").where("age" > 80).fetch()
        XCTAssert(rows!.count == 1)
        
        rows = try! con.knex().table("test_users").where("age" >= 43).fetch()
        XCTAssert(rows!.count == 3)
        
        rows = try! con.knex().table("test_users").where("age" < 20).fetch()
        XCTAssert(rows!.count == 2)
        
        rows = try! con.knex().table("test_users").where("age" <= 23).fetch()
        XCTAssert(rows!.count == 3)
        
        rows = try! con.knex().table("test_users").where("age" != 23).fetch()
        XCTAssert(rows!.count == 6)
        
        rows = try! con.knex().table("test_users").where(.like("email", "jac%")).fetch()
        XCTAssert(rows!.count == 2)
        
        rows = try! con.knex().table("test_users").where(.in("name", ["Tonny", "Ray", "Julia"])).fetch()
        XCTAssert(rows!.count == 3)
        
        rows = try! con.knex().table("test_users").where(.notIn("name", ["Tonny", "Ray", "Julia"])).fetch()
        XCTAssert(rows!.count == 4)
        
        rows = try! con.knex().table("test_users").where(.between("age", 10, 30)).fetch()
        XCTAssert(rows!.count == 4)
        
        rows = try! con.knex().table("test_users").where(.notBetween("age", 10, 30)).fetch()
        XCTAssert(rows!.count == 3)
        
        rows = try! con.knex().table("test_users").where(.isNull("country")).fetch()
        XCTAssert(rows!.count == 2)
        
        rows = try! con.knex().table("test_users").where(.isNotNull("country")).fetch()
        XCTAssert(rows!.count == 5)
        
        rows = try! con.knex().table("test_users").where("name" == "Jack").where("country" == "USA").fetch()
        XCTAssert(rows!.count == 1)
        
        rows = try! con.knex().table("test_users").where("country" == "Japan").or("country" == "USA").fetch()
        XCTAssert(rows!.count == 4)
        
        
        rows = try! con.knex().table("test_users").where(("country" == "USA" && "name" == "Jack") || "country" == "Japan").fetch()
        XCTAssert(rows!.count == 2)
        
        let t = Table(QueryBuilder().table("test_users").where("country" == "USA")).as("table1")
        rows = try! con.knex().table(t).fetch()
        
        XCTAssert(rows!.count == 3)
        
        rows = try! con.knex().table("test_users").where(.in("id", QueryBuilder().select(col("id")).table("test_users").where("country" == "USA"))).fetch()
        
        XCTAssert(rows!.count == 3)
        
        rows = try! con.knex().table("test_users").where(.notIn("id", QueryBuilder().select(col("id")).table("test_users").where("country" == "USA"))).fetch()
        
        XCTAssert(rows!.count == 4)
    }
    
    func testTypeSafeFetch(){
        let users: [User] = try! con.knex().table("test_users").where("country" == "USA").fetch()
        XCTAssertEqual(users.map({ $0.id }), [1, 2, 6])
    }
    
    func testOrderBy(){
        var rows: ResultSet?
        rows = try! con.knex().table("test_users").order(by: "age", sort: .asc).fetch()
        XCTAssertEqual(rows![0]["age"] as! Int, 15)
        
        rows = try! con.knex().table("test_users").order(by: "age", sort: .desc).fetch()
        XCTAssertEqual(rows![0]["age"] as! Int, 81)
    }
    
    func testGroupBy(){
        var rows: ResultSet?
        rows = try! con.knex().select(count("id").as("count"), col("country")).table("test_users").group(by: "country").fetch()
        
        rows?.forEach {
            guard let country = $0["country"] as? String else {
                return
            }
            
            switch country {
            case "USA":
                XCTAssertEqual($0["count"] as! Int64, 3)
                
            case "Japan":
                XCTAssertEqual($0["count"] as! Int64, 1)
                
            case "China":
                XCTAssertEqual($0["count"] as! Int64, 1)
            default:
                break
            }
        }
    }
    
    func testHaving(){
        var rows: ResultSet?
        rows = try! con.knex().select(count("id").as("count"), col("country")).table("test_users").group(by: "country").having("count" > 2).fetch()
        
        rows?.forEach {
            guard let country = $0["country"] as? String else {
                return
            }
            
            switch country {
            case "USA":
                XCTAssertEqual($0["count"] as! Int64, 3)
            default:
                break
            }
        }
    }
    
    func testLimitOffset(){
        var rows: ResultSet?
        rows = try! con.knex().table("test_users").limit(3).fetch()
        XCTAssert(rows!.count == 3)
        
        rows = try! con.knex().table("test_users").limit(3).offset(6).fetch()
        XCTAssert(rows!.count == 1)
    }
    
}
