//
//  State.swift
//
//
//  Created by John Griffin on 12/12/19.
//

import Foundation

public enum Error: Swift.Error {
    case UnificationError
}

public struct State {
    fileprivate struct Info {
        /// The value of the variables
        var value: Any?

        /// Mapping from a key to the derived variable.
        /// All variables that share the same basis must be unified.
        var derived: [AnyVariable.Basis.Key: AnyVariable] = [:]

        /// Functions that unify variables from bijections.
        var bijections: [AnyVariable: Bijection] = [:]

        init(_ bijections: [AnyVariable: Bijection] = [:]) {
            self.bijections = bijections
        }
    }

    // MARK: context and values

    fileprivate var context = Context<AnyVariable, Info>()

    private var constraints: [Constraint] = []
}

extension State { // values
    public func value<Value>(of property: Property<Value>) -> Value? {
        value(of: property.variable)
            .map { property.transform($0) as! Value }
    }

    internal func value(of variable: AnyVariable) -> Any? {
        context[variable]?.value
    }

    public func value<Value>(of variable: Variable<Value>) -> Value? {
        try! bijecting(variable)
            .value(of: variable.erased)
            .map { $0 as! Value }
    }
}

extension State { // constraints
    internal mutating func constrain(_ constraint: @escaping Constraint) throws {
        try constraint(self)
        constraints.append(constraint)
    }

    internal func constrained(_ constraint: @escaping Constraint) throws -> State {
        var state = self
        try state.constrain(constraint)
        return state
    }

    private func verifyConstraints() throws {
        for constraint in constraints {
            try constraint(self)
        }
    }
}

extension State { // bijecting
    fileprivate func bijecting<Value>(_ variable: Variable<Value>) throws -> State {
        // We've already gone through this for this variable
        if context[variable.erased] != nil { return self }

        if variable.bijections.isEmpty { return self }

        var state = self

        let source = variable.erased.basis?.source ??
            variable.bijections.keys.first { $0 != variable.erased }!
        let unifySource = variable.bijections[source]!

        var info = state.context[source] ?? Info()
        for (variable, bijection) in variable.bijections {
            if variable == source { continue }

            info.bijections[variable] = bijection
            if let key = variable.basis?.key {
                if let existing = info.derived[key] {
                    // Since variable is new, it can't have a value. So just
                    // assume the existing variable's info.
                    state.context.merge(existing, variable) { lhs, _ in lhs }
                } else {
                    info.derived[key] = variable
                    state.context[variable] = Info([source: unifySource])
                }
            } else {
                state.context[variable] = Info([source: unifySource])
            }
        }

        state.context[source] = info

        for bijection in variable.bijections.values {
            state = try bijection(state)
        }
        try state.verifyConstraints()

        return state
    }
}

extension State { // unifying
    // mutating unify

    public mutating func unify<Value>(_ variable: Variable<Value>, _ value: Value) throws {
        self = try unified(variable, value)
    }

    internal mutating func unify(_ variable: AnyVariable, _ value: Any) throws {
        self = try unified(variable, value)
    }

    public mutating func unify<Value>(_ lhs: Variable<Value>, _ rhs: Variable<Value>) throws {
        self = try unified(lhs, rhs)
    }

    internal mutating func unify(_ lhs: AnyVariable, _ rhs: AnyVariable) throws {
        self = try unified(lhs, rhs)
    }

    // bijecting unified

    public func unified<Value>(_ variable: Variable<Value>, _ value: Value) throws -> State {
        try bijecting(variable)
            .unified(variable.erased, value)
    }

    public func unified<Value>(_ lhs: Variable<Value>, _ rhs: Variable<Value>) throws -> State {
        try bijecting(lhs)
            .bijecting(rhs)
            .unified(lhs.erased, rhs.erased)
    }

    // unified

    internal func unified(_ variable: AnyVariable, _ value: Any) throws -> State {
        var state = self

        var info = state.context[variable] ?? Info()
        if let oldValue = info.value {
            if !variable.equal(oldValue, value) {
                throw Error.UnificationError
            }
        } else {
            info.value = value
            state.context[variable] = info

            for unify in info.bijections.values {
                state = try unify(state)
            }

            try state.verifyConstraints()
        }
        return state
    }

    internal func unified(_ lhs: AnyVariable, _ rhs: AnyVariable) throws -> State {
        let equal = lhs.equal

        var state = self
        var unify: [(AnyVariable, AnyVariable)] = []
        try state.context.merge(lhs, rhs) { lhs, rhs in
            if let left = lhs?.value, let right = rhs?.value, !equal(left, right) {
                throw Error.UnificationError
            }

            var info = Info()
            info.value = lhs?.value ?? rhs?.value
            info.bijections = Self.merge(lhs?.bijections, rhs?.bijections) { a, _ in a }
            info.derived = Self.merge(lhs?.derived, rhs?.derived) { a, b in
                unify.append((a, b))
                return a
            }
            return info
        }

        for (a, b) in unify {
            try state.unify(a, b)
        }

        let info = state.context[lhs]!
        for bijection in info.bijections.values {
            state = try bijection(state)
        }

        try state.verifyConstraints()
        return state
    }

    private static func merge<Key, Value>(_ a: [Key: Value]?, _ b: [Key: Value]?,
                                          combine: (Value, Value) -> Value) -> [Key: Value]
    {
        var result: [Key: Value] = [:]
        var allKeys = Set<Key>()
        if let a = a?.keys { allKeys.formUnion(a) }
        if let b = b?.keys { allKeys.formUnion(b) }
        for key in allKeys {
            let a = a?[key]
            let b = b?[key]
            if let a = a, let b = b {
                result[key] = combine(a, b)
            } else {
                result[key] = a ?? b
            }
        }
        return result
    }
}
