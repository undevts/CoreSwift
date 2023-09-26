import Foundation

extension NSObject {
    /// Returns the value associated with a given object for a given key.
    ///
    /// - Parameter key: The key for the association.
    /// - Returns: The value associated with the key key for object.
    @inline(__always)
    public func associatedObject<T>(key: UnsafeRawPointer) -> T? {
        objc_getAssociatedObject(self, key) as? T
    }

    /// Returns the value associated with a given object for a given key.
    /// If there is no such value, update with the `default` value.
    ///
    /// - Parameters:
    ///   - key: The key for the association.
    ///   - policy: The policy for the association.
    ///   - default: A closure providers `default` value.
    /// - Returns: The associated value or newly created value.
    @inline(__always)
    public func associatedObject<T>(key: UnsafeRawPointer,
        policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC,
        `default`: @autoclosure () -> T) -> T {
        if let object = objc_getAssociatedObject(self, key) as? T {
            return object
        }
        let object = `default`()
        self.setAssociatedObject(key: key, object: object, policy: policy)
        return object
    }

    /// Sets an associated value for a given object using a given key and association policy.
    ///
    /// - Parameters:
    ///   - key: The key for the association.
    ///   - object: The value to associate with the key key for object.
    ///     Pass `nil` to clear an existing association.
    ///   - policy: The policy for the association.
    @inline(__always)
    public func setAssociatedObject<T>(key: UnsafeRawPointer, object: T?,
        policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, key, object, policy)
    }
}

