//
//  ConstraintTests.swift
//  Logician
//
//  Created by Matt Diephouse on 9/17/16.
//  Copyright © 2016 Matt Diephouse. All rights reserved.
//

@testable import ConstraintSolver
import XCTest

private func succeed(
    _ constraint: Constraint,
    file: StaticString = #file,
    line: UInt = #line,
    _ block: (inout State) throws -> Void
) {
    var state = State()
    try! block(&state)
    do {
        try constraint(state)
    } catch {
        XCTFail("Constraint failed unexpectedly", file: file, line: line)
    }
}

private func fail(
    _ constraint: Constraint,
    file: StaticString = #file,
    line: UInt = #line,
    _ block: (inout State) throws -> Void
) {
    var state = State()
    try! block(&state)
    do {
        try constraint(state)
        XCTFail("Constraint succeeded unexpectedly", file: file, line: line)
    } catch {}
}

class ConstraintEqualTests: XCTestCase {
    func testSuccessWithValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = equal([x, y], value: 4)

        succeed(constraint) { _ in }

        succeed(constraint) {
            try! $0.unify(x, 4)
        }

        succeed(constraint) {
            try! $0.unify(y, 4)
        }

        succeed(constraint) {
            try! $0.unify(x, 4)
            try! $0.unify(y, 4)
        }
    }

    func testFailureWithValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = equal([x, y], value: 4)

        fail(constraint) {
            try! $0.unify(x, 5)
        }

        fail(constraint) {
            try! $0.unify(y, 5)
        }

        fail(constraint) {
            let z = Variable<Int>()
            try! $0.unify(z, 5)
            try! $0.unify(x, z)
        }
    }

    func testSuccessWithoutValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = equal([x, y])

        succeed(constraint) { _ in }

        succeed(constraint) {
            try! $0.unify(x, 5)
        }

        succeed(constraint) {
            try! $0.unify(y, 5)
        }

        succeed(constraint) {
            try! $0.unify(x, 5)
            try! $0.unify(y, 5)
        }

        succeed(constraint) {
            let z = Variable<Int>()
            try! $0.unify(x, z)
            try! $0.unify(y, z)
        }

        succeed(constraint) {
            let z = Variable<Int>()
            try! $0.unify(x, z)
            try! $0.unify(y, z)
            try! $0.unify(z, 5)
        }
    }

    func testFailureWithoutValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = equal([x, y])

        fail(constraint) {
            try! $0.unify(x, 2)
            try! $0.unify(y, 7)
        }

        fail(constraint) {
            let z = Variable<Int>()
            try! $0.unify(z, 2)
            try! $0.unify(x, z)
            try! $0.unify(y, 7)
        }
    }

    static var allTests: [(String, (ConstraintEqualTests) -> () throws -> Void)] {
        [
            ("testSuccessWithValue", testSuccessWithValue),
            ("testFailureWithValue", testFailureWithValue),
            ("testSuccessWithoutValue", testSuccessWithoutValue),
            ("testFailureWithoutValue", testFailureWithoutValue),
        ]
    }
}

class ConstraintUnequalTests: XCTestCase {
    func testSuccessWithValue() {
        let x = Variable<Int>()
        let constraint = unequal([x], values: [42])

        succeed(constraint) { _ in }

        succeed(constraint) {
            try! $0.unify(x, 5)
        }

        succeed(constraint) {
            let y = Variable<Int>()
            try! $0.unify(x, y)
        }

        succeed(constraint) {
            let y = Variable<Int>()
            try! $0.unify(x, y)
            try! $0.unify(y, 5)
        }
    }

    func testFailureWithValue() {
        let x = Variable<Int>()
        let constraint = unequal([x], values: [42])

        fail(constraint) {
            try! $0.unify(x, 42)
        }

        fail(constraint) {
            let y = Variable<Int>()
            try! $0.unify(x, y)
            try! $0.unify(y, 42)
        }
    }

    func testSuccessWithoutValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = unequal([x, y])

        succeed(constraint) { _ in }

        succeed(constraint) {
            try! $0.unify(x, 5)
        }

        succeed(constraint) {
            try! $0.unify(y, 5)
        }

        succeed(constraint) {
            try! $0.unify(x, 6)
            try! $0.unify(y, 5)
        }
    }

    func testFailureWithoutValue() {
        let x = Variable<Int>()
        let y = Variable<Int>()
        let constraint = unequal([x, y])

        fail(constraint) {
            try! $0.unify(x, 42)
            try! $0.unify(y, 42)
        }

        fail(constraint) {
            try! $0.unify(x, y)
            try! $0.unify(y, 42)
        }
    }

    static var allTests: [(String, (ConstraintUnequalTests) -> () throws -> Void)] {
        [
            ("testSuccessWithValue", testSuccessWithValue),
            ("testFailureWithValue", testFailureWithValue),
            ("testSuccessWithoutValue", testSuccessWithoutValue),
            ("testFailureWithoutValue", testFailureWithoutValue),
        ]
    }
}
