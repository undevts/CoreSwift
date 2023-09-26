import Foundation // For Data

extension String {
    /// Convert any property of any object to a String. Generally used to convert a property
    /// in a C structure into a String. In Swift, C arrays will convert to homogeneous tuples,
    /// like: (Int, Int, Int, Int, Int, Int), which is not very useful.
    ///
    /// For example, to get the name of the system `utsname.machine` can be written like this:
    /// ```swift
    /// var raw = utsname()
    /// uname(&raw)
    /// let name = String(raw, keyPath: \utsname.machine, count: Int(_SYS_NAMELEN))
    /// // name = "iPhone14,2"
    /// ```
    ///
    /// - Parameters:
    ///   - value: The object to be resolved, usually a C structure.
    ///   - keyPath: A KeyPath object for reading properties.
    ///   - count: The length of C string.
    public init?<T>(_ value: T, keyPath: PartialKeyPath<T>, count: Int) {
        guard let offset = MemoryLayout<T>.offset(of: keyPath) else {
            return nil
        }
        let result = withUnsafePointer(to: value) { (pointer: UnsafePointer<T>) -> String? in
            let raw: UnsafeRawPointer = UnsafeRawPointer(pointer).advanced(by: offset)
            let field: UnsafePointer<UInt8> = raw.assumingMemoryBound(to: UInt8.self)
            if field[count - 1] != 0 {
                let data = Data(bytes: raw, count: count)
                return String(data: data, encoding: .utf8)
            } else {
                return String(cString: field)
            }
        }
        if let result = result {
            self = result
        } else {
            return nil
        }
    }
}
