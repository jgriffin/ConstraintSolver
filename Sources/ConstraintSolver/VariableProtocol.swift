//
//  VariableProtocol.swift
//
//
//  Created by John Griffin on 12/12/19.
//

import Foundation

internal typealias Bijection = (State) throws -> State

private func biject<From: Equatable, To: Equatable>(
    _ lhs: AnyVariable, _ rhs: AnyVariable,
    _ transform: @escaping (From) -> To
) -> Bijection {
    { state in
        guard let value = state.value(of: lhs) else { return state }
        return try state.unified(rhs, transform(value as! From))
    }
}

public protocol VariableProtocol: PropertyProtocol where Value: Equatable {
    /// Extracts the variable from the receiver.
    var variable: Variable<Value> { get }
}

extension VariableProtocol {
    /// Create a new variable that's related to this one by a transformation.
    public func bimap<A: Equatable>(
        forward: @escaping (Value) -> A,
        backward: @escaping (A) -> Value
    ) -> Variable<A> {
        let source = variable.erased
        let a = AnyVariable(A.self)
        let bijections = [
            a: biject(source, a, forward),
            source: biject(a, source, backward),
        ]
        return Variable<A>(a, bijections: bijections)
    }

    /// Create a new variable that's related to this one by a transformation.
    ///
    /// - important: The `identity` must uniquely identify this bimap so that
    ///              Logician will know that the new variables are the same if
    ///              it's executed multiple times.
    ///
    /// - parameters:
    ///   - identity: A string that uniquely identifies this bimap.
    ///   - forward: A block that maps this value into two values.
    ///   - backward: A block that maps two values back into the this value.
    public func bimap2<A: Hashable, B: Hashable>(
        identity: String,
        forward: @escaping (Value) -> (A, B),
        backward: @escaping ((A, B)) -> Value
    ) -> (Variable<A>, Variable<B>) {
        let source = variable.erased
        let a = AnyVariable(A.self, source, key: "\(identity).0")
        let b = AnyVariable(B.self, source, key: "\(identity).1")
        let unifySource: Bijection = { state in
            guard let a = state.value(of: a), let b = state.value(of: b) else {
                return state
            }
            return try state.unified(source, backward((a as! A, b as! B)))
        }
        let bijections = [
            a: biject(source, a) { forward($0).0 },
            b: biject(source, b) { forward($0).1 },
            source: unifySource,
        ]
        return (
            Variable<A>(a, bijections: bijections),
            Variable<B>(b, bijections: bijections)
        )
    }

//    /// Create a new variable that's related to this one by a transformation.
//    ///
//    /// - note: The location of this bimap in the source code determines its
//    ///         identity. If you need it to live in multiple locations, you need
//    ///         to specify an explicit identity.
//    ///
//    /// - parameters:
//    ///   - identity: A string that uniquely identifies this bimap.
//    ///   - forward: A block that maps this value into two values.
//    ///   - backward: A block that maps two values back into the this value.
//    public func bimap2<A: Hashable, B: Hashable>(
//        file: StaticString = #file,
//        line: Int = #line,
//        function: StaticString = #function,
//        forward: @escaping (Value) -> (A, B),
//        backward: @escaping ((A, B)) -> Value
//    ) -> (Variable<A>, Variable<B>) {
//        let identity = "\(file):\(line):\(function)"
//        return bimap2(identity: identity, forward: forward, backward: backward)
//    }

    /// Create a new variable that's related to this one by a transformation.
    ///
    /// - important: The `identity` must uniquely identify this bimap so that
    ///              Logician will know that the new variables are the same if
    ///              it's executed multiple times.
    ///
    /// - parameters:
    ///   - identity: A string that uniquely identifies this bimap.
    ///   - forward: A block that maps this value into two values.
    ///   - backward: A block that maps two values back into the this value.
    public func bimap5<A: Hashable, B: Hashable, C: Hashable, D: Hashable, E: Hashable>(
        identity: String,
        forward: @escaping (Value) -> (A, B, C, D, E),
        backward: @escaping ((A, B, C, D, E)) -> Value
    ) -> (Variable<A>, Variable<B>, Variable<C>, Variable<D>, Variable<E>) {
        let source = variable.erased
        let a = AnyVariable(A.self, source, key: "\(identity).0")
        let b = AnyVariable(B.self, source, key: "\(identity).1")
        let c = AnyVariable(C.self, source, key: "\(identity).2")
        let d = AnyVariable(D.self, source, key: "\(identity).3")
        let e = AnyVariable(E.self, source, key: "\(identity).4")
        let unifySource: Bijection = { state in
            guard let a = state.value(of: a), let b = state.value(of: b),
                let c = state.value(of: c), let d = state.value(of: d),
                let e = state.value(of: e)
            else {
                return state
            }
            return try state.unified(source, backward((a as! A, b as! B, c as! C, d as! D, e as! E)))
        }
        let bijections = [
            a: biject(source, a) { forward($0).0 },
            b: biject(source, b) { forward($0).1 },
            c: biject(source, c) { forward($0).2 },
            d: biject(source, d) { forward($0).3 },
            e: biject(source, e) { forward($0).4 },
            source: unifySource,
        ]
        return (
            Variable<A>(a, bijections: bijections),
            Variable<B>(b, bijections: bijections),
            Variable<C>(c, bijections: bijections),
            Variable<D>(d, bijections: bijections),
            Variable<E>(e, bijections: bijections)
        )
    }

    /// Create a new variable that's related to this one by a transformation.
    ///
    /// - important: The `identity` must uniquely identify this bimap so that
    ///              Logician will know that the new variables are the same if
    ///              it's executed multiple times.
    ///
    /// - parameters:
    ///   - identity: A string that uniquely identifies this bimap.
    ///   - forward: A block that maps this value into two values.
    ///   - backward: A block that maps two values back into the this value.
    public func bimap6<A: Hashable, B: Hashable, C: Hashable, D: Hashable, E: Hashable, F: Hashable>(
        identity: String,
        forward: @escaping (Value) -> (A, B, C, D, E, F),
        backward: @escaping ((A, B, C, D, E, F)) -> Value
    ) -> (Variable<A>, Variable<B>, Variable<C>, Variable<D>, Variable<E>, Variable<F>) {
        let source = variable.erased
        let a = AnyVariable(A.self, source, key: "\(identity).0")
        let b = AnyVariable(B.self, source, key: "\(identity).1")
        let c = AnyVariable(C.self, source, key: "\(identity).2")
        let d = AnyVariable(D.self, source, key: "\(identity).3")
        let e = AnyVariable(E.self, source, key: "\(identity).4")
        let f = AnyVariable(F.self, source, key: "\(identity).5")
        let unifySource: Bijection = { state in
            guard let a = state.value(of: a), let b = state.value(of: b),
                let c = state.value(of: c), let d = state.value(of: d),
                let e = state.value(of: e), let f = state.value(of: f)
            else {
                return state
            }
            return try state.unified(source, backward((a as! A, b as! B, c as! C, d as! D, e as! E, f as! F)))
        }
        let bijections = [
            a: biject(source, a) { forward($0).0 },
            b: biject(source, b) { forward($0).1 },
            c: biject(source, c) { forward($0).2 },
            d: biject(source, d) { forward($0).3 },
            e: biject(source, e) { forward($0).4 },
            f: biject(source, f) { forward($0).5 },
            source: unifySource,
        ]
        return (
            Variable<A>(a, bijections: bijections),
            Variable<B>(b, bijections: bijections),
            Variable<C>(c, bijections: bijections),
            Variable<D>(d, bijections: bijections),
            Variable<E>(e, bijections: bijections),
            Variable<F>(f, bijections: bijections)
        )
    }

//    /// Create a new variable that's related to this one by a transformation.
//    ///
//    /// - note: The location of this bimap in the source code determines its
//    ///         identity. If you need it to live in multiple locations, you need
//    ///         to specify an explicit identity.
//    ///
//    /// - parameters:
//    ///   - identity: A string that uniquely identifies this bimap.
//    ///   - forward: A block that maps this value into two values.
//    ///   - backward: A block that maps two values back into the this value.
//    public func bimap5<A: Hashable, B: Hashable, C: Hashable, D: Hashable, E: Hashable>(
//        file: StaticString = #file,
//        line: Int = #line,
//        function: StaticString = #function,
//        forward: @escaping (Value) -> (A, B, C, D, E),
//        backward: @escaping ((A, B, C, D, E)) -> Value
//    ) -> (Variable<A>, Variable<B>, Variable<C>, Variable<D>, Variable<E>) {
//        let identity = "\(file):\(line):\(function)"
//        return bimap5(identity: identity, forward: forward, backward: backward)
//    }
}
