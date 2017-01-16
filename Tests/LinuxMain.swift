import XCTest
@testable import SwiftKnexTests

XCTMain([
     testCase(InsertTests.allTests),
     testCase(JoinTests.allTests),
     testCase(MysqlTests.allTests),
     testCase(SelectTests.allTests),
     testCase(TransactionTests.allTests),
     testCase(UpdateTests.allTests),
     testCase(DDLTests.allTests)
])
