//
//  PropertyTests.swift
//
//
//  Created by John Griffin on 12/12/19.
//

@testable import ConstraintSolver
import XCTest

class PropertyTests: XCTestCase {
    func testIdentity() {
        let length1 = Variable<String>().map(\.count)
        let length2 = length1
        let length3 = Variable<String>().map(\.count)
        XCTAssertTrue(length1 == length2)
        XCTAssertFalse(length1 == length3)
        XCTAssertFalse(length2 == length3)
    }

    func testTypeErasure() {
        let property = Variable<String>().map(\.count)
        XCTAssertTrue(property.erased == property)
        XCTAssertEqual(property.erased, property.erased)
    }
}
