public struct BufferedWriter<Other> where Other: Writer {
    @usableFromInline
    let token: Token

    public init(_ other: Other) {
        // TODO: capacity DEFAULT_BUF_SIZE
        token = Token(other: other, buffer: Bytes(capacity: 1024))
    }

    @inlinable
    @inline(__always)
    var spareCapacity: Int {
        token.buffer.capacity - token.buffer.count
    }

    /// Send data in our local buffer into the inner writer, looping as
    /// necessary until either it's all been sent or an error occurs.
    ///
    /// Because all the data in the buffer has been reported to our owner as
    /// "successfully written" (by returning nonzero success values from
    /// `write`), any 0-length writes from `inner` must be reported as i/o
    /// errors from this method.
    @inlinable
    @inline(__always)
    mutating func flushBuffer() -> IOResult<Void> {
        token.flushBuffer()
    }

    @usableFromInline
    class Token {
        @usableFromInline
        var other: Other
        @usableFromInline
        var buffer: Bytes
        @usableFromInline
        var panicked = false

        init(other: Other, buffer: Bytes) {
            self.other = other
            self.buffer = buffer
        }

        deinit {
            if !panicked {
                _ = flushBuffer()
            }
        }

        @usableFromInline
        func flushBuffer() -> IOResult<Void> {
            var written: UInt = 0

            @inline(__always)
            func remaining() -> Bytes {
                let index = buffer.startIndex + Int(written)
                return buffer[index...]
            }

            @inline(__always)
            func done() -> Bool {
                written >= buffer.count
            }

            while !done() {
                panicked = true
                let result = other.write(buffer: remaining())
                panicked = false

                switch result {
                case .success(0):
                    return .failure(IOError.message(kind: .writeZero, message: "failed to write the buffered data"))
                case let .success(size):
                    written += size
                case let .failure(error):
                    if error.kind == IOErrorKind.interrupted {
                        continue
                    } else {
                        return .failure(error)
                    }
                }
            }
            return .success(())
        }
    }
}

extension BufferedWriter: Writer {
    // SAFETY: Requires `buffer.count <= self.buffer.capacity - self.buffer.count`,
    // i.e., that input buffer length is less than or equal to spare capacity.
    @inlinable
    @inline(__always)
    mutating func unsafeWrite(buffer: UnsafeBufferPointer<UInt8>) {
        let base = buffer.baseAddress!
        let count = buffer.count
        assert(count < spareCapacity)
        token.buffer.withUnsafeMutableStorage { _, _, current -> Void in
            current.initialize(from: base, count: count)
            current += count
        }
    }

    // Ensure this function does not get inlined into `write`, so that it
    // remains inlineable and its common path remains as short as possible.
    // If this function ends up being called frequently relative to `write`,
    // it's likely a sign that the client is using an improperly sized buffer
    // or their write patterns are somewhat pathological.
    @inline(never)
    private mutating func writeCold(buffer: UnsafeBufferPointer<UInt8>) -> IOResult<UInt> {
        let count = buffer.count
        if count > spareCapacity {
            switch flushBuffer() {
            case .success:
                break
            case let .failure(error):
                return .failure(error)
            }
        }
        if buffer.count >= token.buffer.capacity {
            token.panicked = true
            let result = token.other.write(buffer: buffer)
            token.panicked = false
            return result
        }
        // Write to the buffer. In this case, we write to the buffer even if it fills it
        // exactly. Doing otherwise would mean flushing the buffer, then writing this
        // input to the inner writer, which in many cases would be a worse strategy.

        // SAFETY: There was either enough spare capacity already, or there wasn't and we
        // flushed the buffer to ensure that there is. In the latter case, we know that there
        // is because flushing ensured that our entire buffer is spare capacity, and we entered
        // this block because the input buffer length is less than that capacity. In either
        // case, it's safe to write the input buffer to our buffer.
        unsafeWrite(buffer: buffer)
        return .success(UInt(count))
    }

    public mutating func write(buffer: UnsafeBufferPointer<UInt8>) -> IOResult<UInt> {
        guard buffer.baseAddress != nil else {
            return .success(0)
        }
        if buffer.count < spareCapacity {
            unsafeWrite(buffer: buffer)
            return .success(UInt(buffer.count))
        }
        return writeCold(buffer: buffer)
    }

    public mutating func flush() -> IOResult<Void> {
        flushBuffer().flatMap { () -> IOResult<Void> in
            token.other.flush()
        }
    }
}

extension BufferedWriter: Seekable where Other: Seekable {
    public mutating func seek(position: SeekFrom) -> IOResult<UInt64> {
        flushBuffer().flatMap { () -> IOResult<UInt64> in
            token.other.seek(position: position)
        }
    }
}
