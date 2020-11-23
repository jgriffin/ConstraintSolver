
import Foundation

public struct Variable<Value: Equatable> {
    internal var erased: AnyVariable
    internal let bijections: [AnyVariable: Bijection]

    public init() {
        self.init(AnyVariable(Value.self))
    }

    internal init(_ erased: AnyVariable, bijections: [AnyVariable: Bijection] = [:]) {
        self.erased = erased
        self.bijections = bijections
    }
}

extension Variable: VariableProtocol {
    public var property: Property<Value> { Property(self) { $0 } }
    public var variable: Variable<Value> { self }
}

internal class AnyVariable: Hashable {
    internal struct Basis: Equatable {
        typealias Key = String
        let source: AnyVariable
        let key: Key
    }

    internal let basis: Basis?
    internal let equal: (Any, Any) -> Bool

    internal init<Value: Equatable>(_: Value.Type) {
        basis = nil
        equal = { ($0 as! Value) == ($1 as! Value) }
    }

    internal init<Value: Equatable>(_: Value.Type,
                                    _ source: AnyVariable,
                                    key: String)
    {
        basis = Basis(source: source, key: key)
        equal = { ($0 as! Value) == ($1 as! Value) }
    }

    func hash(into hasher: inout Hasher) {
        guard let basis = self.basis else {
            hasher.combine(ObjectIdentifier(self))
            return
        }
        hasher.combine(basis.source)
        hasher.combine(basis.key)
    }

    static func == (lhs: AnyVariable, rhs: AnyVariable) -> Bool {
        if let lhs = lhs.basis, let rhs = rhs.basis {
            return lhs.source == rhs.source && lhs.key == rhs.key
        } else {
            return lhs === rhs
        }
    }
}

/// Test whether the variables have the same identity.
internal func == <Left, Right>(lhs: Variable<Left>, rhs: Variable<Right>) -> Bool {
    lhs.erased == rhs.erased
}
