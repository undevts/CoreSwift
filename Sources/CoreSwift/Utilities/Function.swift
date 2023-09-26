/// A collection of useful functions.
public struct Function {
    private init() {
        // Do nothing.
    }

    /// A function that returns the parameter itself directly.
    @inlinable
    @inline(__always)
    public static func identity<T>(_ value: T) -> T {
        value
    }

    /// A function that returns the parameter as `Optional<T>`.
    @inlinable
    @inline(__always)
    public static func optional<T>(_ value: T) -> T? {
        value
    }

    /// A function eats anything, returns `Void`.
    @inlinable
    @inline(__always)
    public static func nothing(_ value: Any) {
        // Do nothing.
    }

    /// A function eats nothing, returns `Void`.
    @inlinable
    @inline(__always)
    public static func nothing() {
        // Do nothing.
    }

    // Returns true if the parameter is `true`.
    @inlinable
    @inline(__always)
    public static func truly(_ value: Bool) -> Bool {
        value
    }

    // Returns true if the parameter is `false`.
    @inlinable
    @inline(__always)
    public static func falsely(_ value: Bool) -> Bool {
        !value
    }

    /// Create a method that always ignores all parameters and returns the current parameter.
    @inlinable
    @inline(__always)
    public static func always<T, R>(_ value: T) -> (R) -> T {
        { _ in value }
    }
}
