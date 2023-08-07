#if SWIFT_PACKAGE
import CoreCxxInternal
#endif

protocol BytesBuffer {
    var capacity: Int { get }

    mutating func start() -> UnsafeMutablePointer<UInt8>
    mutating func end() -> UnsafeMutablePointer<UInt8>
}

extension cci_buffer_32: BytesBuffer {
    @_transparent
    @usableFromInline
    var capacity: Int {
        32
    }

    @_transparent
    @usableFromInline
    mutating func start() -> UnsafeMutablePointer<UInt8> {
        withUnsafePointer(to: &self) { (pointer: UnsafePointer<cci_buffer_32>) in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: UInt8.self)
        }
    }

    @_transparent
    @usableFromInline
    mutating func end() -> UnsafeMutablePointer<UInt8> {
        start().advanced(by: capacity)
    }
}


extension cci_buffer_64: BytesBuffer {
    @_transparent
    var capacity: Int {
        64
    }

    @_transparent
    mutating func start() -> UnsafeMutablePointer<UInt8> {
        withUnsafePointer(to: &self) { (pointer: UnsafePointer<cci_buffer_64>) in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: UInt8.self)
        }
    }

    @_transparent
    mutating func end() -> UnsafeMutablePointer<UInt8> {
        start().advanced(by: capacity)
    }
}


extension cci_buffer_128: BytesBuffer {
    @_transparent
    var capacity: Int {
        128
    }

    @_transparent
    mutating func start() -> UnsafeMutablePointer<UInt8> {
        withUnsafePointer(to: &self) { (pointer: UnsafePointer<cci_buffer_128>) in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: UInt8.self)
        }
    }

    @_transparent
    mutating func end() -> UnsafeMutablePointer<UInt8> {
        start().advanced(by: capacity)
    }
}

extension cci_buffer_256: BytesBuffer {
    @_transparent
    var capacity: Int {
        256
    }

    @_transparent
    mutating func start() -> UnsafeMutablePointer<UInt8> {
        withUnsafePointer(to: &self) { (pointer: UnsafePointer<cci_buffer_256>) in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: UInt8.self)
        }
    }

    @_transparent
    mutating func end() -> UnsafeMutablePointer<UInt8> {
        start().advanced(by: capacity)
    }
}

extension cci_buffer_512: BytesBuffer {
    @_transparent
    var capacity: Int {
        512
    }

    @_transparent
    mutating func start() -> UnsafeMutablePointer<UInt8> {
        withUnsafePointer(to: &self) { (pointer: UnsafePointer<cci_buffer_512>) in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: UInt8.self)
        }
    }

    @_transparent
    mutating func end() -> UnsafeMutablePointer<UInt8> {
        start().advanced(by: capacity)
    }
}

extension cci_buffer_1024: BytesBuffer {
    @_transparent
    var capacity: Int {
        1024
    }

    @_transparent
    mutating func start() -> UnsafeMutablePointer<UInt8> {
        withUnsafePointer(to: &self) { (pointer: UnsafePointer<cci_buffer_1024>) in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: UInt8.self)
        }
    }

    @_transparent
    mutating func end() -> UnsafeMutablePointer<UInt8> {
        start().advanced(by: capacity)
    }
}

extension cci_buffer_2048: BytesBuffer {
    @_transparent
    var capacity: Int {
        2048
    }

    @_transparent
    mutating func start() -> UnsafeMutablePointer<UInt8> {
        withUnsafePointer(to: &self) { (pointer: UnsafePointer<cci_buffer_2048>) in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: UInt8.self)
        }
    }

    @_transparent
    mutating func end() -> UnsafeMutablePointer<UInt8> {
        start().advanced(by: capacity)
    }
}

extension cci_buffer_4096: BytesBuffer {
    @_transparent
    var capacity: Int {
        4096
    }

    @_transparent
    mutating func start() -> UnsafeMutablePointer<UInt8> {
        withUnsafePointer(to: &self) { (pointer: UnsafePointer<cci_buffer_4096>) in
            UnsafeMutableRawPointer(mutating: pointer).assumingMemoryBound(to: UInt8.self)
        }
    }

    @_transparent
    mutating func end() -> UnsafeMutablePointer<UInt8> {
        start().advanced(by: capacity)
    }
}
