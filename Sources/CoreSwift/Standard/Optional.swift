extension Optional {
    /// Returns `true` if the Optional is a `some` value.
    @inlinable
    public var isSome: Bool {
        switch self {
        case .some:
            return true
        case .none:
            return false
        }
    }

    /// Returns `true` if the Optional is a `none` value.
    @inlinable
    public var isNone: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }

    /// Returns the contained `some` value.
    /// Raise fatalError if the value is a none with a custom fatal error message provided by message.
    ///
    /// - Parameter message: A custom fatal error message provided by message.
    /// - Returns: Returns the contained `some` value.
    @inlinable
    public func expect(_ message: @autoclosure () -> String) -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            fatalError(message())
        }
    }

    /// Calls the given closure if the Optional is a `some` value.
    ///
    /// ```swift
    /// let foo: String? = "foobar"
    /// foo.ifPresent { print($0) } // prints "foobar".
    /// let bar: String? = nil
    /// bar.ifPresent { print($0) } // prints nothing.
    /// ```
    ///
    /// - Parameter body: A closure that takes `Wrapped` value.
    @inlinable
    public func ifPresent(_ body: (Wrapped) throws -> Void) rethrows {
        switch self {
        case .none:
            break
        case let .some(value):
            try body(value)
        }
    }

    /// Make computed properties much easier, like:
    ///
    /// ```swift
    /// // Without `withPresenting`...
    /// class Foo {
    ///     private var _bar: String?
    ///     var bar: String {
    ///         if let bar = _bar {
    ///             return bar
    ///         }
    ///         let bar = String(Int.max, radix: 16)
    ///         _bar = bar
    ///         return bar
    ///     }
    /// }
    ///
    /// // With `withPresenting`...
    /// class Foo {
    ///     private var _bar: String?
    ///     var bar: String {
    ///         _bar.withPresenting {
    ///             String(Int.max, radix: 16)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter body: A closure that takes `Wrapped` value. Calls if the Optional is `none`.
    @inlinable
    public mutating func withPresenting(_ body: () throws -> Wrapped) rethrows -> Wrapped {
        switch self {
        case .none:
            let value = try body()
            self = .some(value)
            return value
        case let .some(value):
            return value
        }
    }

    /// Returns the contained some value or a provided default.
    ///
    /// - Note: Arguments passed to unwrap(or:) are eagerly evaluated;
    /// if you are passing the result of a function call,
    /// it is recommended to use unwrap(by:), which is lazily evaluated.
    ///
    /// - Parameter default: A default value provided if the self value equals `none`.
    /// - Returns: Returns the contained some value or a provided default.
    @inlinable
    public func unwrap(or `default`: Wrapped) -> Wrapped {
        switch self {
        case .none:
            return `default`
        case let .some(value):
            return value
        }
    }

    /// Returns the contained some value or computes it from a closure.
    ///
    /// - Parameter method: A closure provided if the self value equals `none`.
    /// - Returns: Returns the contained some value or a computes one.
    @inlinable
    public func unwrap(by method: () throws -> Wrapped) rethrows -> Wrapped {
        switch self {
        case .none:
            return try method()
        case let .some(value):
            return value
        }
    }
}

extension Optional where Wrapped: Collection {
    /// Returns `true` if the Optional is a `none` value or the wrapped collection is empty.
    @inlinable
    public var isNoneOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case let .some(value):
            return value.isEmpty
        }
    }
}
