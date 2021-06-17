//
//  QueryTests.swift
//  
//
//  Created by sudo.park on 2021/06/13.
//

import XCTest

@testable import SqliteStorage



class QueryTests: XCTestCase { }


// MARK: - test query to statement

extension QueryTests {
    
    func testQuery_convertToStatement_fromBuilder() {
        // given
        let builder = QueryBuilder(table: "Some").select(.all)
        let unit: QueryExpression.Condition = .init(key: "k", operation: .equal, value: "v")
        
        // when
        let query = builder
            .where(unit)
            .orderBy("k2", isAscending: false)
            .limit(100)
            
        let stmt = try? query.asStatement()
        
        // then
        XCTAssertEqual(stmt, "SELECT * FROM Some WHERE k = 'v' ORDER BY k2 DESC LIMIT 100;")
    }
    
    func testQuery_convertToStatement_fromBuilderWithSomeColumns() {
        // given
        
        // when
        let query = QueryBuilder(table: "Some").select(.some(["c1", "c2"]))
        let stmt = try? query.asStatement()
        
        // then
        XCTAssertEqual(stmt, "SELECT c1, c2 FROM Some;")
    }
    
    func testQuery_convertToSelectStatement_fromTable() {
        // given
        let table = DummyTable()
        
        // when
        let queries: [SingleQuery<DummyTable>] = [
            table.selectAll(),
            table.selectAll()
                .where { $0.k1 == 1 && $0.k2 > 2 },
            table.selectAll()
                .where { ($0.k1 == 1 && $0.k2 > 2) || $0.k1.notIn([2, 3, 4]) },
            table.selectSome{ [$0.k1, $0.k2] },
            table.selectSome{ [$0.k2] }
                .where{ $0.k2 != 100 }
        ]
        let statements = queries.compactMap{ try? $0.asStatement() }
        
        // then
        XCTAssertEqual(statements, [
            "SELECT * FROM Dummy;",
            "SELECT * FROM Dummy WHERE k1 = 1 AND k2 > 2;",
            "SELECT * FROM Dummy WHERE (k1 = 1 AND k2 > 2) OR k1 NOT IN (2, 3, 4);",
            "SELECT k1, k2 FROM Dummy;",
            "SELECT k2 FROM Dummy WHERE k2 != 100;",
        ])
    }
    
    func testQuery_convertToUpdateStatement_fromTable() {
        // given
        let table = DummyTable()
        
        // when
        let queries: [SingleQuery<DummyTable>] = [
            table.update{ [$0.k1 == 10, $0.k2 > 10, $0.k2 == 100] },
            table.update{ [$0.k2 == 10] }
                .where{ $0.k2 > 10 }
        ]
        let statements = queries.compactMap{ try? $0.asStatement() }
        
        // then
        XCTAssertEqual(statements, [
            "UPDATE Dummy SET k1 = 10, k2 = 100;",
            "UPDATE Dummy SET k2 = 10 WHERE k2 > 10;",
        ])
    }
    
    func testQuery_convertToDeleteStatement_fromTable() {
        // given
        let table = DummyTable()
        
        // when
        let queries: [SingleQuery<DummyTable>] = [
            table.delete(),
            table.delete().where{ $0.k2 == 100 }
        ]
        let statements = queries.compactMap{ try? $0.asStatement() }
        
        // then
        XCTAssertEqual(statements, [
            "DELETE FROM Dummy;",
            "DELETE FROM Dummy WHERE k2 = 100;"
        ])
    }
}


extension QueryTests {
    
    struct DummyModel {
        let k1: Int
        let k2: String
    }
    
    struct DummyTable: Table {
        
        static var tableName: String { "Dummy" }
        
        enum Columns: String, TableColumn {
            
            case k1
            case k2
            
            var dataType: ColumnDataType {
                switch self {
                case .k1: return .integer([])
                case .k2: return .text([])
                }
            }
        }
        
        typealias Model = DummyModel
        typealias ColumnType = Columns
        
        func serialize(model: QueryTests.DummyModel) throws -> [StorageDataType?] {
            return [model.k1, model.k2]
        }
        
        func deserialize(cursor: OpaquePointer?) throws -> QueryTests.DummyModel {
            guard let cursor = cursor else {
                throw SQLiteErrors.step("deserialize")
            }
            let int: Int = try cursor[0].unwrap()
            let str: String = try cursor[1].unwrap()
            return .init(k1: int, k2: str)
        }
    }
}
