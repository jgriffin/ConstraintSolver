//
//  Generator.swift
//
//
//  Created by John Griffin on 12/12/19.
//

import Foundation

public class Generator<Value>: IteratorProtocol {
    private var iterator: AnyIterator<Value>

    public init(values: [Value] = []) {
        iterator = AnyIterator(values.makeIterator())
    }

    public init(_ block: @escaping () -> Value?) {
        iterator = AnyIterator(block)
    }

    public init(interleaving generators: [Generator<Value>]) {
        var generators = generators

        iterator = AnyIterator {
            while let s = generators.first {
                generators.remove(at: 0)
                if let result = s.next() {
                    generators.append(s)
                    return result
                }
            }
            return nil
        }
    }

    public func next() -> Value? {
        iterator.next()
    }

    public func allValues() -> [Value] {
        var values: [Value] = []
        while let v = next() {
            values.append(v)
        }
        return values
    }

    public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Generator<NewValue> {
        Generator<NewValue> {
            self.next().map(transform)
        }
    }

    func flatMap<NewValue>(_ transform: @escaping (Value) -> NewValue?) -> Generator<NewValue> {
        Generator<NewValue> {
            while let input = self.next() {
                if let result = transform(input) {
                    return result
                }
            }
            return nil
        }
    }

    func flatMap(_ transform: @escaping (Value) -> Generator<Value>) -> Generator<Value> {
        var inner = next().map(transform)
        return Generator<Value> {
            while let i = inner {
                if let result = i.next() {
                    return result
                }
                inner = self.next().map(transform)
            }
            return nil
        }
    }
}
