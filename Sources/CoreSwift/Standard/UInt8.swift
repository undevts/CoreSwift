/// If 6th bit is set ascii is lower case.
@usableFromInline
let asciiCaseMask: UInt8 = 0b0010_0000

extension UInt8 {
    /// Checks if the value is an ASCII uppercase character:
    /// U+0041 'A' ..= U+005A 'Z'.
    @inlinable
    @inline(__always)
    public var isASCIIUppercase: Bool {
        self >= 0x41 && self <= 0x5A
    }

    /// Checks if the value is an ASCII lowercase character:
    /// U+0061 'a' ..= U+007A 'z'.
    @inlinable
    @inline(__always)
    public var isASCIILowercase: Bool {
        self >= 0x61 && self <= 0x7A
    }

    /// Checks if the value is an ASCII alphanumeric character:
    ///
    /// - U+0041 'A' ..= U+005A 'Z', or
    /// - U+0061 'a' ..= U+007A 'z', or
    /// - U+0030 '0' ..= U+0039 '9'.
    @inlinable
    @inline(__always)
    public var isASCIIAlphanumeric: Bool {
        isASCIIUppercase || isASCIILowercase || isASCIIDigit
    }

    /// Checks if the value is an ASCII decimal digit:
    /// U+0030 '0' ..= U+0039 '9'.
    @inlinable
    @inline(__always)
    public var isASCIIDigit: Bool {
        self >= 0x30 && self <= 0x39
    }

    /// Makes a copy of the value in its ASCII upper case equivalent.
    ///
    /// ASCII letters 'a' to 'z' are mapped to 'A' to 'Z',
    /// but non-ASCII letters are unchanged.
    @inlinable
    @inline(__always)
    public func asciiUppercased() -> UInt8 {
        self ^ ((isASCIIUppercase ? 1 : 0) * asciiCaseMask)
    }

    /// Makes a copy of the value in its ASCII lower case equivalent.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    @inlinable
    @inline(__always)
    public func asciiLowercased() -> UInt8 {
        self | ((isASCIIUppercase ? 1 : 0) * asciiCaseMask)
    }

    /// Returns a array containing a copy of the input array where each byte
    /// is mapped to its ASCII upper case equivalent.
    ///
    /// ASCII letters 'a' to 'z' are mapped to 'A' to 'Z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To luppercase the value in-place, use ``asciiUppercase(_:)``.
    @inlinable
    public static func asciiUppercased(_ array: [UInt8]) -> [UInt8] {
        array.map { $0.asciiUppercased() }
    }

    /// Converts the input array to its ASCII upper case equivalent in-place.
    ///
    /// ASCII letters 'a' to 'a' are mapped to 'A' to 'Z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To return a new uppercased value without modifying the existing one, use
    /// ``asciiUppercased(_:)``.
    @inlinable
    public static func asciiUppercase(_ array: inout [UInt8]) {
        array.withUnsafeMutableBufferPointer { pointer -> Void in
            guard var c = pointer.baseAddress else {
                return
            }
            let n = c + pointer.count
            while c < n {
                c.initialize(to: c.pointee.asciiUppercased())
                c += 1
            }
        }
    }

    /// Returns a array containing a copy of the input array where each byte
    /// is mapped to its ASCII lower case equivalent.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To lowercase the value in-place, use ``asciiLowercase(_:)``.
    @inlinable
    public static func asciiLowercased(_ array: [UInt8]) -> [UInt8] {
        array.map { $0.asciiLowercased() }
    }

    /// Converts the input array to its ASCII lower case equivalent in-place.
    ///
    /// ASCII letters 'A' to 'Z' are mapped to 'a' to 'z',
    /// but non-ASCII letters are unchanged.
    ///
    /// To return a new lowercased value without modifying the existing one, use
    /// ``asciiLowercased(_:)``.
    @inlinable
    public static func asciiLowercase(_ array: inout [UInt8]) {
        array.withUnsafeMutableBufferPointer { pointer -> Void in
            guard var c = pointer.baseAddress else {
                return
            }
            let n = c + pointer.count
            while c < n {
                c.initialize(to: c.pointee.asciiLowercased())
                c += 1
            }
        }
    }
}