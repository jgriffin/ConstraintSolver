//
//  Solve.swift
//
//
//  Created by John Griffin on 12/12/19.
//

import Foundation

public func solve<Value>(_ block: (Variable<Value>) -> Goal) -> Generator<Value> {
    let variable = Variable<Value>()
    return block(variable)(State())
        .flatMap { $0.value(of: variable) }
}

public func solve<Value>(_ block: (inout [Variable<Value>]) -> Goal) -> Generator<[Value]> {
    var variables: [Variable<Value>] = []
    return block(&variables)(State())
        .flatMap { state in
            var values: [Value] = []
            for v in variables {
                if let v = state.value(of: v) {
                    values.append(v)
                } else {
                    return nil
                }
            }
            return values
        }
}
