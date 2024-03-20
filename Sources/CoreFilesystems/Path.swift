#if SWIFT_PACKAGE
import CoreSwift
import CoreSystem
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
    private(set) var content: OsString

    @_transparent
    @usableFromInline
    init(buffer: Bytes) {
        content = OsString(unchecked: buffer)
    }

    @_transparent
    @usableFromInline
    init(string: OsString) {
        content = string
    }

    @inlinable
    public init() {
        self.init(string: OsString())
    }

    @inlinable
    public init(_ path: String) {
        self.init(string: OsString(path))
    }

    @inlinable
    public init(stringLiteral value: StaticString) {
        self.init(string: OsString(stringLiteral: value))
    }

    @inlinable
    public init<S>(_ value: S) where S: StringProtocol {
        self.init(string: OsString(value))
    }

    // TODO: UnsafeBufferPointer
    public func withBytes<Result>(_ method: (UnsafePointer<UInt8>) throws -> Result) rethrows -> Result {
        let bytes = content.bytes
        switch bytes.count {
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
                bytes.withUnsafeBuffer { (temp: UnsafeBufferPointer<UInt8>) -> Void in
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
                bytes.withUnsafeBuffer { (temp: UnsafeBufferPointer<UInt8>) -> Void in
                    if let base = temp.baseAddress {
                        memcpy(start, base, temp.count)
                    }
                }
                return try method(UnsafePointer(start))
            }
        default:
            let start = UnsafeMutablePointer<UInt8>.allocate(capacity: bytes.count + 1)
            defer {
                start.deallocate()
            }
            bytes.withUnsafeBuffer { (temp: UnsafeBufferPointer<UInt8>) -> Void in
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
    static func splitAtDot(_ path: OsString) -> (OsString?, OsString?) {
        let bytes = path.bytes
        if bytes == [ASCII.fullStop.rawValue, ASCII.fullStop.rawValue] {
            return (path, nil)
        }
        guard let i = bytes.lastIndex(of: ASCII.fullStop.rawValue) else {
            return (path, nil)
        }
        let first = bytes[..<i]
        let second = bytes[(i + 1)...]
        return first.isEmpty ? (path, nil) : (OsString(unchecked: first), OsString(unchecked: second))
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
    func _filename() -> OsString? {
        guard let storage = lastComponent?.storage else {
            return nil
        }
        switch storage {
        case let .regular(string):
            return string
        case .prefix, .root, .current, .parent:
            return nil
        }
    }

    @usableFromInline
    mutating func _setFilename(filename: OsString?) {
        if _filename() != nil {
            let popped = pop()
            assert(popped)
        }
        if let filename = filename {
            // TODO: 
            push(Path(filename.string))
        }
    }
}

extension Path {
    @inlinable
    public var components: ComponentView {
        let prefix = Path.parsePrefix(content)
        let bytes = content.bytes
        return ComponentView(
            bytes: bytes,
            prefix: prefix,
            hasPhysicalRoot: Path.hasPhysicalRoot(bytes, prefix: prefix))
    }

    /// Whether this path is empty.
    @inlinable
    public var isEmpty: Bool {
        content.isEmpty
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
    public var filename: OsString? {
        get {
            _filename()
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
                (first ?? second)?.string
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
                (first.isNone ? nil : second)?.string
            }
    }

    public var string: String {
        content.string
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
        var bytes = Bytes(capacity: (first.content.count + second.content.count) / 2)
        if !from.isEmpty {
            bytes.unsafeAppend(3 * from.count - 1) { pointer in
                var p = pointer
                for x in 0..<from.count {
                    if x > 0 {
                        p.initialize(to: Path.preferredSeparator)
                        p += 1
                    }
                    p.initialize(repeating: ASCII.fullStop.rawValue, count: 2)
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
        var needSeparator = !(content.bytes.last.map(Path.isSeparator) ?? true)

        // in the special case of `C:` on Windows, do *not* add a separator
        let view = components
        if view.prefixCount > 0 && view.prefixCount == content.count &&
            view.prefix?.isDrive == true {
            needSeparator = false
        }

        if other.isAbsolute || other.prefix != nil {
            // absolute `path` replaces `self`
            content.removeAll(keepingCapacity: true)
        } else if view.prefixVerbatim && !other.content.isEmpty {
            // verbatim paths need . and .. removed
            return
        } else if other.hasRoot {
            // `path` has a root but no prefix, e.g., `\windows` (Windows only)
            let count = view.prefixRemaining()
            content.removeLast(content.count - count)
        } else if needSeparator {
            // `path` is a pure relative path
            content.append(Path.preferredSeparator)
        }
        content.append(other.content)
    }

    /// Truncates `self` to ``parent()``.
    ///
    /// - Returns: `false` and does nothing if ``parent()`` is `nil`. Otherwise, returns `true`.
    public mutating func pop() -> Bool {
        guard let path = parent() else {
            return false
        }
        content.removeLast(content.count - path.content.count)
        return true
    }
}
