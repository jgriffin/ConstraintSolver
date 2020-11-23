//
//  Context.swift
//
//
//  Created by John Griffin on 12/12/19.
//

import Foundation

internal struct Context<Key: Hashable, Value> {
    private class Node<Key: Hashable, Value> {
        let keys: Set<Key> // keys pointing to this node
        let value: Value?

        init(keys: Set<Key>, value: Value?) {
            self.keys = keys
            self.value = value
        }
    }

    private var values: [Key: Node<Key, Value>] = [:]

    subscript(_ key: Key) -> Value? {
        get { values[key]?.value }
        set { updateValue(newValue, forKey: key) }
    }

    mutating func removeValue(forKey key: Key) {
        values.removeValue(forKey: key)
    }

    @discardableResult
    mutating func updateValue(_ newValue: Value?, forKey key: Key) -> Value? {
        updateValue(forKey: key) { _ in newValue }
    }

    @discardableResult
    mutating func updateValue(forKey key: Key,
                              transform: (Value?) throws -> Value?) rethrows -> Value?
    {
        let oldNode = values[key]
        let oldValue = oldNode?.value
        let newValue = try transform(oldValue)

        let allKeys = oldNode?.keys ?? Set([key])

        let newNode = Node(keys: allKeys, value: newValue)
        for key in allKeys {
            values[key] = newNode
        }
        return oldValue
    }

    mutating func merge(_ key1: Key, _ key2: Key,
                        combine: (Value?, Value?) throws -> Value?) rethrows
    {
        let node1 = values[key1]
        let node2 = values[key2]
        let newValue = try combine(node1?.value, node2?.value)
        let allKeys = (node1?.keys ?? Set())
            .union(node2?.keys ?? Set())
            .union([key1, key2])

        let node = Node(keys: allKeys, value: newValue)
        for key in allKeys {
            values[key] = node
        }
    }
}
