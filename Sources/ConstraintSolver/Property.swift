//
//  Property.swift
//
//
//  Created by John Griffin on 12/12/19.
//

import Foundation

public protocol PropertyProtocol {
    /// The type of value that the variable represents.
    associatedtype Value

    /// Extracts the property from the receiver.
    var property: Property<Value> { get }
}

extension PropertyProtocol {
    public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Property<NewValue> {
        Property<NewValue>(property.variable) { input in
            let middle = self.property.transform(input) as! Value
            let output = transform(middle)
            return output
        }
    }
}

public struct Property<Value> {
    /// variable backing property
    internal let variable: AnyVariable

    /// transforms the variable value in to the property's.
    internal let transform: (Any) -> Any

    /// Create a new variable.
    internal init<T>(_ variable: Variable<T>, _ transform: @escaping (T) -> Value) {
        self.variable = variable.erased
        self.transform = { transform($0 as! T) }
    }

    /// Create a new variable.
    internal init(_ variable: AnyVariable, _ transform: @escaping (Any) -> Value) {
        self.variable = variable
        self.transform = { transform($0) }
    }

    /// A type-erased version of the property.
    internal var erased: AnyProperty {
        AnyProperty(variable: variable, transform: transform)
    }
}

extension Property: PropertyProtocol {
    public var property: Property<Value> { self }
}

// A type-erased, hashable `Property`.
internal struct AnyProperty: Hashable {
    /// The variable backing the property.
    fileprivate let variable: AnyVariable

    /// transforms the variable value in to the property's.
    fileprivate let transform: (Any) -> Any

    /// Create a variable with an existing `Identity`.
    fileprivate init(variable: AnyVariable, transform: @escaping (Any) -> Any) {
        self.variable = variable
        self.transform = transform
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(variable)
    }

    static func == (lhs: AnyProperty, rhs: AnyProperty) -> Bool {
        lhs.variable == rhs.variable
    }
}

/// Test whether the properties have the same identity.
internal func == <Left, Right>(lhs: Property<Left>, rhs: Property<Right>) -> Bool {
    lhs.variable == rhs.variable
}

/// Test whether the properties have the same identity.
internal func == <Value>(lhs: Property<Value>, rhs: AnyProperty) -> Bool {
    lhs.variable == rhs.variable
}

/// Test whether the properties have the same identity.
internal func == <Value>(lhs: AnyProperty, rhs: Property<Value>) -> Bool {
    lhs.variable == rhs.variable
}
