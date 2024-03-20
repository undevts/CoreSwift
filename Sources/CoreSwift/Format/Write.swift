public typealias FormatResult = Result<Void, Error>

public protocol Write {
    // Required methods
    mutating func write(_ bytes: UnsafeBufferPointer<UInt8>) -> FormatResult
    // Provided methods
    mutating func write(_ bytes: UnsafePointer<UInt8>, count: Int) -> FormatResult
    mutating func write(_ bytes: Bytes) -> FormatResult
    mutating func write(_ string: String) -> FormatResult

// #if swift(>=5.9)
//     mutating func write<each T: Display>(format: StaticString, _ values: repeat each T) -> FormatResult
// #endif
}

extension Write {
    mutating func write(_ bytes: UnsafePointer<UInt8>, count: Int) -> FormatResult {
        let buffer = UnsafeBufferPointer(start: bytes, count: count)
        return write(buffer)
    }

    public mutating func write(_ bytes: Bytes) -> FormatResult {
        bytes.withUnsafeBuffer { buffer in
            self.write(buffer)
        }
    }

    public mutating func write(_ string: String) -> FormatResult {
        let bytes = Bytes(string)
        return bytes.withUnsafeBuffer { buffer in
            self.write(buffer)
        }
    }
}

@frozen
public struct AnyWrite: Write {
    var storage: _AnyWrite

    public init<T>(_ writer: T) where T: Write {
        storage = _AnyWriteStorage(writer: writer)
    }

    public mutating func write(_ string: String) -> FormatResult {
        storage.write(string)
    }
    
    public func write(_ bytes: Bytes) -> FormatResult {
        storage.write(bytes)
    }
    
    public func write(_ bytes: UnsafeBufferPointer<UInt8>) -> FormatResult {
        storage.write(bytes)
    }

    public func write(_ bytes: UnsafePointer<UInt8>, count: Int) -> FormatResult {
        storage.write(bytes, count: count)
    }

// #if swift(>=5.9)
//     public mutating func write<each T: Display>(format: StaticString, _ values: repeat each T) -> FormatResult {
//         storage.write(format: format, repeat each values)
//     }
// #endif
}

@usableFromInline
class _AnyWrite {
    func write(_ string: String) -> FormatResult {
        return .success(())
    }
    
    func write(_ bytes: Bytes) -> FormatResult {
        return .success(())
    }
    
    func write(_ bytes: UnsafeBufferPointer<UInt8>) -> FormatResult {
        return .success(())
    }

    func write(_ bytes: UnsafePointer<UInt8>, count: Int) -> FormatResult {
        return .success(())
    }

// #if swift(>=5.9)
//     func write<each T: Display>(format: StaticString, _ values: repeat each T) -> FormatResult {
//         return .success(())
//     }
// #endif
}

final class _AnyWriteStorage<T>: _AnyWrite where T: Write {
    var writer: T

    init(writer: T) {
        self.writer = writer
    }

    override func write(_ string: String) -> FormatResult {
        writer.write(string)
    }
    
    override func write(_ bytes: Bytes) -> FormatResult {
        writer.write(bytes)
    }
    
    override func write(_ bytes: UnsafeBufferPointer<UInt8>) -> FormatResult {
        writer.write(bytes)
    }

    override func write(_ bytes: UnsafePointer<UInt8>, count: Int) -> FormatResult {
        writer.write(bytes, count: count)
    }

// #if swift(>=5.9)
//     func write<each V: Display>(format: StaticString, _ values: repeat each V) -> FormatResult {
//         writer.write(format: format, repeat each values)
//     }
// #endif
}
