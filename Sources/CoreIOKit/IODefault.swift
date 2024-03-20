public struct IODefault {
    static let bufferSize = 0x2000

    // https://github.com/rust-lang/rust/commit/f74fe8bf4ca773e416d4da3a3bf37045b06ea3de
    @inline(__always)
    static func readSize(_ hint: Int?) -> Int? {
        guard let hint else {
            return nil
        }
        var (next, overflow) = hint.addingReportingOverflow(0x23FF)
        if overflow {
            return nil
        }
        // https://doc.rust-lang.org/std/primitive.usize.html#method.checked_next_multiple_of
        (next, overflow) = (next / bufferSize).multipliedReportingOverflow(by: bufferSize)
        return overflow ? nil : next
    }

    // This uses an adaptive system to extend the vector when it fills. We want to
    // avoid paying to allocate and zero a huge chunk of memory if the reader only
    // has 4 bytes while still making large reads if the reader does have a ton
    // of data to return. Simply tacking on an extra DEFAULT_BUF_SIZE space every
    // time is 4,500 times (!) slower than a default reservation size of 32 if the
    // reader has a very small amount of data to return.
    public static func readAll<R>(_ reader: inout R, buffer: inout Bytes, hint: Int?) -> IOResult<Int> where R: Reader {
        let startCount = buffer.count
        let startCapacity = buffer.capacity

        // Optionally limit the maximum bytes read on each iteration.
        // This adds an arbitrary fiddle factor to allow for more data than we expect.
        // TODO: let maxReadSize = readSize(hint)

        while true {
            if buffer.count == buffer.capacity {
                // buffer is full, need more space
                buffer.reserveCapacity(32)
            }
            switch reader.read(into: &buffer) {
            case let .success(written):
                if written == 0 {
                    return .success(buffer.count - startCount)
                }
            case let .failure(error) where error.kind == IOErrorKind.interrupted:
                continue
            case let .failure(error):
                return .failure(error)
            }

            if buffer.count == buffer.capacity && buffer.capacity == startCapacity {
                // The buffer might be an exact fit. Let's read into a probe buffer
                // and see if it returns `.success(0)`. If so, we've avoided an
                // unnecessary doubling of the capacity. But if not, append the
                // probe buffer to the primary buffer and let its capacity grow.
                var probe = FixedBuffer32()
                while true {
                    switch reader.read(buffer: probe.buffer()) {
                    case .success(0):
                        return .success(buffer.count)
                    case let .success(count):
                        buffer.append(UnsafeMutableBufferPointer(start: probe.start(), count: count))
                    case let .failure(error) where error.kind == IOErrorKind.interrupted:
                        continue
                    case let .failure(error):
                        return .failure(error)
                    }
                }
            }
        }
    }

    public static func readToString<R>(_ reader: inout R, buffer: inout Bytes) -> IOResult<String> where R: Reader {
        var bytes = Bytes()
        return readAll(&reader, buffer: &bytes, hint: nil).map { _ -> String in
            bytes.toString()
        }
    }

    public static func writeAll<W>(
        _ writer: inout W, buffer: UnsafeBufferPointer<UInt8>
    ) -> IOResult<()> where W: Writer {
        guard var base = buffer.baseAddress else {
            return .success(())
        }
        var count = buffer.count
        while count > 0 {
            switch writer.write(buffer: UnsafeBufferPointer(start: base, count: count)) {
            case .success(0):
                return .failure(IOError.message(kind: .writeZero, message: "failed to write whole buffer"))
            case let .success(size):
                base += Int(size)
                count -= Int(size)
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
