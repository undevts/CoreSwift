#if SWIFT_PACKAGE
import CoreSwift
import CoreCxxInternal
#endif

// Rust Path: https://doc.rust-lang.org/std/path/struct.Path.html
// Node.js Path: https://nodejs.org/api/path.html
// Python Path: https://docs.python.org/3/library/pathlib.html
// Apple FilePath: https://developer.apple.com/documentation/system/filepath/
// Java Path: https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/nio/file/Path.html
// Go Path: https://pkg.go.dev/path
// C++ Path: https://en.cppreference.com/w/cpp/filesystem/path

@frozen
public struct Path: ExpressibleByStringLiteral {
    @usableFromInline
    private(set) var buffer: Bytes

    @inlinable
    init(buffer: Bytes) {
        self.buffer = buffer
    }

    @inlinable
    public init() {
        buffer = Bytes.empty()
    }

    @inlinable
    public init(_ path: String) {
        buffer = Bytes(path)
    }

    @inlinable
    public init(stringLiteral value: StaticString) {
        buffer = Bytes(value)
    }

    // TODO: UnsafeBufferPointer
    public func withBytes<Result>(_ method: (UnsafePointer<UInt8>) throws -> Result) rethrows -> Result {
        switch buffer.count {
        case 0:
            return try withUnsafePointer(to: 0 as UInt8) { (pointer: UnsafePointer<UInt8>) -> Result in
                try method(pointer)
            }
        case 1..<128:
            var buffer = cci_buffer_128()
            return try withUnsafeMutablePointer(to: &buffer) {
                (pointer: UnsafeMutablePointer<cci_buffer_128>) -> Result in
                let start = UnsafeMutableRawPointer(mutating: pointer)
                    .assumingMemoryBound(to: UInt8.self)
                self.buffer.withUnsafeBuffer { (temp: UnsafeBufferPointer<UInt8>) -> Void in
                    if let base = temp.baseAddress {
                        memcpy(start, base, temp.count)
                    }
                }
                return try method(UnsafePointer(start))
            }
        case 128..<383: // max 384
            var buffer = cci_buffer_384()
            return try withUnsafeMutablePointer(to: &buffer) { pointer -> Result in
                let start = UnsafeMutableRawPointer(mutating: pointer)
                    .assumingMemoryBound(to: UInt8.self)
                self.buffer.withUnsafeBuffer { (temp: UnsafeBufferPointer<UInt8>) -> Void in
                    if let base = temp.baseAddress {
                        memcpy(start, base, temp.count)
                    }
                }
                return try method(UnsafePointer(start))
            }
        default:
            let start = UnsafeMutablePointer<UInt8>.allocate(capacity: buffer.count + 1)
            defer {
                start.deallocate()
            }
            buffer.withUnsafeBuffer { (temp: UnsafeBufferPointer<UInt8>) -> Void in
                if temp.count > 0, let base = temp.baseAddress {
                    memcpy(start, base, temp.count)
                    (start + temp.count).initialize(to: 0)
                } else {
                    start.initialize(to: 0)
                }
            }
            return try method(UnsafePointer(start))
        }
    }

    // TODO: UnsafeBufferPointer
    public func withCString<Result>(_ method: (UnsafePointer<Int8>) throws -> Result) rethrows -> Result {
        try withBytes { (pointer: UnsafePointer<UInt8>) -> Result in
            let start = UnsafeRawPointer(pointer)
                .assumingMemoryBound(to: Int8.self)
            return try method(start)
        }
    }

    /// Whether the first byte after the prefix is a separator.
    @usableFromInline
    static func hasPhysicalRoot(_ bytes: Bytes, prefix: Prefix?) -> Bool {
        let path: Bytes
        if let prefix = prefix {
            // TODO: Int index
            let start = bytes.index(bytes.startIndex, offsetBy: prefix.count)
            path = bytes[start...]
        } else {
            path = bytes
        }
        return !path.isEmpty && isSeparator(path[0])
    }

    // basic workhorse for splitting stem and extension
    @usableFromInline
    static func splitAtDot(_ path: Bytes) -> (Bytes?, Bytes?) {
        if path == [ASCII.period.rawValue, ASCII.period.rawValue] {
            return (path, nil)
        }
        guard let i = path.lastIndex(of: ASCII.period.rawValue) else {
            return (path, nil)
        }
        let first = path[..<i]
        let second = path[(i + 1)...]
        return first.isEmpty ? (path, nil) : (first, second)
    }
}

extension Path: CustomStringConvertible {
    public var description: String {
        string
    }
}

extension Path: Equatable {
    @inlinable
    public static func ==(lhs: Path, rhs: Path) -> Bool {
        lhs.components == rhs.components
    }
}

extension Path {
    @usableFromInline
    func _filename() -> Bytes? {
        guard let storage = lastComponent?.storage else {
            return nil
        }
        switch storage {
        case let .regular(bytes):
            return bytes
        case .prefix, .root, .current, .parent:
            return nil
        }
    }

    @usableFromInline
    mutating func _setFilename(filename: String?) {
        if _filename() != nil {
            let popped = pop()
            assert(popped)
        }
        if let filename = filename {
            push(Path(filename))
        }
    }
}

extension Path {
    @inlinable
    public var components: ComponentView {
        let prefix = Path.parsePrefix(buffer)
        return ComponentView(
            bytes: buffer,
            prefix: prefix,
            hasPhysicalRoot: Path.hasPhysicalRoot(buffer, prefix: prefix))
    }

    /// Whether this path is empty.
    @inlinable
    public var isEmpty: Bool {
        buffer.isEmpty
    }

    /// Returns `true` if the `Path` is absolute, i.e., if it is independent of
    /// the current directory.
    ///
    /// * On Unix, a path is absolute if it starts with the root, so
    /// `isAbsolute` and ``hasRoot`` are equivalent.
    ///
    /// * On Windows, a path is absolute if it has a prefix and starts with the
    /// root: `c:\windows` is absolute, while `c:temp` and `\temp` are not.
    @inlinable
    public var isAbsolute: Bool {
        components.hasRoot
    }

    /// Returns `true` if the `Path` is not absolute (see ``isAbsolute``).
    @inlinable
    public var isRelative: Bool {
        !isAbsolute
    }

    /// Returns `true` if the `Path` has a root.
    ///
    /// * On Unix, a path has a root if it begins with `/`.
    ///
    /// * On Windows, a path has a root if it:
    ///     * has no prefix and begins with a separator, e.g., `\windows`
    ///     * has a prefix followed by a separator, e.g., `c:\windows` but not `c:windows`
    ///     * has any non-disk prefix, e.g., `\\server\share`
    @inlinable
    public var hasRoot: Bool {
        components.hasRoot
    }

    @inlinable
    public var prefix: Prefix? {
        components.prefix
    }

    /// Returns the final component of the `Path`. Returns `nil` if the path is empty or only contains a root.
    public var lastComponent: Path.Component? {
        var iterator = components.makeBackIterator()
        return iterator.next()
    }

    /// Returns the final component of the `Path`, if there is one.
    ///
    /// If the path is a normal file, this is the file name. If it's the path of a directory, this
    /// is the directory name.
    ///
    /// Returns `nil` if the path terminates in `..`.
    @inlinable
    public var filename: String? {
        get {
            _filename()?.toString()
        }
        set {
            _setFilename(filename: newValue)
        }
    }

    /// Extracts the stem (non-extension) portion of ``filename``.
    ///
    /// The stem is:
    ///
    /// * `nil`, if there is no file name;
    /// * The entire file name if there is no embedded `.`;
    /// * The entire file name if the file name begins with `.` and has no other `.`s within;
    /// * Otherwise, the portion of the file name before the final `.`.
    public var stem: String? {
        _filename().map(Path.splitAtDot)
            .flatMap { first, second in
                (first ?? second)?.toString()
            }
    }

    /// Extracts the extension (without the leading dot) of ``filename``, if possible.
    ///
    /// The extension is:
    ///
    /// * `nil`, if there is no file name;
    /// * `nil`, if there is no embedded `.`;
    /// * `nil`, if the file name begins with `.` and has no other `.`s within;
    /// * Otherwise, the portion of the file name after the final `.`.
    public var `extension`: String? {
        _filename().map(Path.splitAtDot)
            .flatMap { first, second in
                (first.isNone ? nil : second)?.toString()
            }
    }

    /// Creates a string by interpreting the path’s content as UTF-8 on Unix and UTF-16 on Windows.
    public var string: String {
        buffer.toString() ?? ""
    }

    /// Returns the ``Path`` without its final component, if there is one.
    ///
    /// This means it returns `.some("")` for relative paths with one component.
    ///
    /// Returns `nil` if the path terminates in a root or prefix, or if it's
    /// the empty string.
    ///
    /// # Examples
    ///
    /// ```
    /// use std::path::Path;
    ///
    /// let path = Path::new("/foo/bar");
    /// let parent = path.parent().unwrap();
    /// assert_eq!(parent, Path::new("/foo"));
    ///
    /// let grand_parent = parent.parent().unwrap();
    /// assert_eq!(grand_parent, Path::new("/"));
    /// assert_eq!(grand_parent.parent(), None);
    ///
    /// let relative_path = Path::new("foo/bar");
    /// let parent = relative_path.parent();
    /// assert_eq!(parent, Some(Path::new("foo")));
    /// let grand_parent = parent.and_then(Path::parent);
    /// assert_eq!(grand_parent, Some(Path::new("")));
    /// let great_grand_parent = grand_parent.and_then(Path::parent);
    /// assert_eq!(great_grand_parent, None);
    /// ```
    public func parent() -> Path? {
        var view = components
        guard let last: Component = view.popLast() else {
            return nil
        }
        switch last.storage {
        case .current, .parent, .regular:
            return view.path
        default:
            return nil
        }
    }

    public static func relative(from first: Path, to second: Path) -> Path {
        let _from = first.components
        let _to = second.components
        var from = ArraySlice<Component>(_from.map(Function.identity))
        var to = ArraySlice<Component>(_to.map(Function.identity))
        if _from.hasRoot { // isAbsolute
            from = from.dropFirst()
        }
        if _to.hasRoot { // isAbsolute
            to = to.dropFirst()
        }

        let count = from.count < to.count ? from.count : to.count
        var i = 0
        while i < count {
            if let a = from.first, let b = to.first, a == b {
                from = from.dropFirst()
                to = to.dropFirst()
            } else {
                break
            }
            i += 1
        }
        var bytes = Bytes(capacity: (first.buffer.count + second.buffer.count) / 2)
        if !from.isEmpty {
            bytes.unsafeAppend(3 * from.count - 1) { pointer in
                var p = pointer
                for x in 0..<from.count {
                    if x > 0 {
                        p.initialize(to: Path.preferredSeparator)
                        p += 1
                    }
                    p.initialize(repeating: ASCII.period.rawValue, count: 2)
                    p += 2
                }
            }
        }
        for item in to {
            bytes.append(Path.preferredSeparator)
            item.append(into: &bytes)
        }
        return Path(buffer: bytes)
    }
}

extension Path {
    @inlinable
    public mutating func append<S>(_ value: S) where S: StringProtocol {
        push(Path(buffer: Bytes(value)))
    }

    @inlinable
    public mutating func append(_ value: Path) {
        push(value)
    }

    @inlinable
    public mutating func append(_ value: Path.Component) {
        push(value.toPath())
    }

    @inlinable
    public func appending<S>(_ value: S) -> Path where S: StringProtocol {
        var result = self
        result.append(value)
        return result
    }

    @inlinable
    public func appending(_ value: Path) -> Path {
        var result = self
        result.append(value)
        return result
    }

    @inlinable
    public func appending(_ value: Path.Component)-> Path {
        var result = self
        result.append(value)
        return result
    }

    public mutating func push(_ other: Path) {
        // in general, a separator is needed if the rightmost byte is not a separator
        var needSeparator = !(buffer.last.map(Path.isSeparator) ?? true)

        // in the special case of `C:` on Windows, do *not* add a separator
        let components = components
        if components.prefixCount > 0 && components.prefixCount == buffer.count &&
            components.prefix?.isDrive == true {
            needSeparator = false
        }

        if other.isAbsolute || other.prefix != nil {
            // absolute `path` replaces `self`
            buffer.removeAll(keepingCapacity: true)
        } else if components.prefixVerbatim && !other.buffer.isEmpty {
            // verbatim paths need . and .. removed
            return
        } else if other.hasRoot {
            // `path` has a root but no prefix, e.g., `\windows` (Windows only)
            let count = components.prefixRemaining()
            let index = buffer.startIndex + count
            buffer = buffer[..<index] // [0...index)
        } else if needSeparator {
            // `path` is a pure relative path
            buffer.append(Path.preferredSeparator)
        }
        buffer.append(other.buffer)
    }

    /// Truncates `self` to ``parent()``.
    ///
    /// - Returns: `false` and does nothing if [`self.parent`] is [`None`]. Otherwise, returns `true`.
    public mutating func pop() -> Bool {
        guard let path = parent() else {
            return false
        }
        buffer.removeLast(buffer.count - path.buffer.count)
        return true
    }
}
