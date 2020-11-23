//
//  Goal+custom.swift
//  Logic
//
//  Created by John Griffin on 12/13/19.
//

import Foundation

// MARK: passing constraints

public typealias ConstraintCheck2<Value> = (Value, Value) -> Bool

public prefix func ! <Value>(_ inner: @escaping ConstraintCheck2<Value>) -> ConstraintCheck2<Value> {
    { lhs, rhs in !inner(lhs, rhs) }
}

public func passing<P: PropertyProtocol>(_ lhs: P, _ rhs: P,
                                         _ test: @escaping ConstraintCheck2<P.Value>) -> Constraint
{
    { state in
        guard let lhsValue = state.value(of: lhs.property),
            let rhsValue = state.value(of: rhs.property)
        else {
            return
        }
        guard test(lhsValue, rhsValue) else {
            throw Error.UnificationError
        }
    }
}

public func passing<P: PropertyProtocol>(_ property: P, _ value: P.Value,
                                         _ test: @escaping ConstraintCheck2<P.Value>) -> Constraint
{
    { state in
        guard let propertyValue = state.value(of: property.property) else {
            return
        }
        guard test(propertyValue, value) else {
            throw Error.UnificationError
        }
    }
}

// MARK: passing -> Goal

public func passing<P: PropertyProtocol>(_ lhs: P, _ rhs: P,
                                         _ test: @escaping ConstraintCheck2<P.Value>) -> Goal
{
    makeGoal(passing(lhs, rhs, test))
}

public func passing<P: PropertyProtocol>(_ property: P, _ value: P.Value,
                                         _ test: @escaping ConstraintCheck2<P.Value>) -> Goal
{
    makeGoal(passing(property, value, test))
}

// MARK: new helpers

public func within<Value>(_ distance: Value) -> ConstraintCheck2<Value>
    where Value: SignedNumeric & Comparable
{
    { lhs, rhs in abs(lhs - rhs) <= distance }
}
