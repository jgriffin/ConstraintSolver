//
//  Constraint.swift
//
//
//  Created by John Griffin on 12/12/19.
//

import Foundation

public typealias Constraint = (State) throws -> Void

public func equal<P: PropertyProtocol>(_ properties: [P],
                                       value: P.Value? = nil) -> Constraint where P.Value: Equatable
{
    let properties = properties.map(\.property)

    return { state in
        var value = value
        for p in properties {
            guard let p = state.value(of: p) else { continue }

            if value == nil {
                value = p
            }
            if value != p {
                throw Error.UnificationError
            }
        }
    }
}

public func unequal<P: PropertyProtocol>(_ properties: [P],
                                         values: Set<P.Value> = []) -> Constraint
{
    let properties = properties.map(\.property)
    return { state in
        var values = values
        for p in properties {
            guard let p = state.value(of: p) else { continue }

            if values.contains(p) {
                throw Error.UnificationError
            }
            values.insert(p)
        }
    }
}
