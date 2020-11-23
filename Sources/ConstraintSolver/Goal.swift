//
//  Goal.swift
//
//
//  Created by John Griffin on 12/12/19.
//

import Foundation

public typealias Goal = (State) -> Generator<State>

public func makeGoal(_ block: @escaping (State) throws -> (State)) -> Goal {
    { state in
        do {
            let state = try block(state)
            return Generator(values: [state])
        } catch {
            return Generator()
        }
    }
}

public func makeGoal(_ constraint: @escaping Constraint) -> Goal {
    makeGoal { try $0.constrained(constraint) }
}

// MARK: - Equality

/// A goal that's satisfied when a variable equals a value.
public func == <V: VariableProtocol>(variable: V, value: V.Value) -> Goal {
    makeGoal { try $0.unified(variable.variable, value) }
}

/// A goal that's satisfied when a value equals a variable.
public func == <V: VariableProtocol>(value: V.Value, variable: V) -> Goal {
    variable == value
}

/// A goal that's satisfied when two variables are equal.
public func == <V: VariableProtocol>(lhs: V, rhs: V) -> Goal {
    makeGoal { try $0.unified(lhs.variable, rhs.variable) }
}

/// A goal that's satisfied when a property equals a value.
public func == <Value: Equatable>(property: Property<Value>, value: Value) -> Goal {
    makeGoal(equal([property], value: value))
}

/// A goal that's satisfied when a property equals a value.
public func == <Value: Equatable>(value: Value, property: Property<Value>) -> Goal {
    property == value
}

/// A goal that's satisfied when two properties are equal.
public func == <P: PropertyProtocol>(lhs: P, rhs: P) -> Goal where P.Value: Equatable {
    makeGoal(equal([lhs, rhs]))
}

extension Variable {
    /// A goal that's satisfied when a variable is one of a number of values.
    public func `in`<C: Collection>(_ values: C) -> Goal where C.Iterator.Element == Value {
        any(values.map { self == $0 })
    }
}

extension Property where Value: Equatable {
    /// A goal that's satisfied when a property is one of a number of values.
    public func `in`<C: Collection>(_ values: C) -> Goal where C.Iterator.Element == Value {
        any(values.map { self == $0 })
    }
}

// MARK: - Inequality

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(property: Property<Value>, value: Value) -> Goal {
    makeGoal(unequal([property], values: Set([value])))
}

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(value: Value, property: Property<Value>) -> Goal {
    property != value
}

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(variable: Variable<Value>, value: Value) -> Goal {
    variable.property != value
}

/// A goal that's satisfied when a property doesn't equal a value.
public func != <Value: Hashable>(value: Value, variable: Variable<Value>) -> Goal {
    variable.property != value
}

/// A goal that's satisfied when two properties aren't equal.
public func != <Value: Hashable>(lhs: Property<Value>, rhs: Property<Value>) -> Goal {
    makeGoal(unequal([lhs, rhs]))
}

/// A goal that's satisfied when two variables aren't equal.
public func != <Value: Hashable>(lhs: Variable<Value>, rhs: Variable<Value>) -> Goal {
    lhs.property != rhs.property
}

/// A goal that's satisfied when a variable and a property aren't equal.
public func != <Value: Hashable>(lhs: Variable<Value>, rhs: Property<Value>) -> Goal {
    lhs.property != rhs
}

/// A goal that's satisfied when a variable and a property aren't equal.
public func != <Value: Hashable>(lhs: Property<Value>, rhs: Variable<Value>) -> Goal {
    lhs != rhs.property
}

/// A goal that's satisfied when all the properties have different values.
public func distinct<P: PropertyProtocol>(_ properties: [P]) -> Goal where P.Value: Hashable {
    makeGoal(unequal(properties))
}

/// A goal that's satisfied when all the properties have different values.
public func distinct<P: PropertyProtocol>(_ properties: P...) -> Goal where P.Value: Hashable {
    distinct(properties)
}

// MARK: - Logicial Conjunction

/// A goal that succeeds when all of the subgoals succeed.
public func all(_ goals: [Goal]) -> Goal {
    { state in
        let initial = Generator<State>(values: [state])
        return goals.reduce(initial) { $0.flatMap($1) }
    }
}

/// A goal that succeeds when all of the subgoals succeed.
public func all(_ goals: Goal...) -> Goal {
    all(goals)
}

/// A goal that succeeds when both of the subgoals succeed.
public func && (lhs: @escaping Goal, rhs: @escaping Goal) -> Goal {
    all(lhs, rhs)
}

// MARK: - Logicial Disjunction

/// A goal that succeeds when any of the subgoals succeeds.
///
/// This can multiple alternative solutions.
public func any(_ goals: [Goal]) -> Goal {
    { state in
        Generator(interleaving: goals.map { $0(state) })
    }
}

/// A goal that succeeds when any of the subgoals succeeds.
///
/// This can multiple alternative solutions.
public func any(_ goals: Goal...) -> Goal {
    any(goals)
}

/// A goal that succeeds when either of the subgoals succeeds.
///
/// This can multiple alternative solutions.
public func || (lhs: @escaping Goal, rhs: @escaping Goal) -> Goal {
    any(lhs, rhs)
}
