public struct Formatter<T>: Write where T: Write {
    var delegate: T

    public init(_ write: T) where T: Write {
        self.delegate = write
    }

    public mutating func write(_ value: String) -> FormatResult {
        delegate.write(value)
    }

    public mutating func write(_ bytes: UnsafeBufferPointer<UInt8>) -> FormatResult {
        delegate.write(bytes)
    }

    public mutating func write(_ bytes: UnsafePointer<UInt8>, count: Int) -> FormatResult {
        delegate.write(bytes, count: count)
    }

    public mutating func write(_ bytes: Bytes) -> FormatResult {
        delegate.write(bytes)
    }

    mutating func write(_ value: some Display, _ result: inout FormatResult) {
        result = value.format(&self)
    }

    mutating func write(_ value: some DebugDisplay, _ result: inout FormatResult) {
        result = value.debugFormat(&self)
    }

#if swift(>=5.9)
    public mutating func write<each V: Display>(format: StaticString, _ values: repeat each V) -> FormatResult {
        var result = FormatResult.success(())
        repeat write(each values, &result)
        return result
//        repeat (each values).format(&self)
//        return .success(())
    }

    public mutating func write<each V: DebugDisplay>(format: StaticString, _ values: repeat each V) -> FormatResult {
        var result = FormatResult.success(())
        repeat write(each values, &result)
        return result
    }
#endif
}

#if swift(>=5.9)
class BytesWrite: Write {
    private(set) var bytes: Bytes

    init() {
        bytes = Bytes(capacity: 64)
    }

    func write(_ bytes: UnsafeBufferPointer<UInt8>) -> FormatResult {
        self.bytes.append(bytes)
        return .success(())
    }

    func toString() -> String {
        bytes.asString()
    }
}
#endif
