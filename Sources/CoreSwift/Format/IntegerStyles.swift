#if SWIFT_PACKAGE
import CoreCxxInternal
#endif

public protocol IntegerStyle {
    func format(_ value: Int, _ formatter: inout Formatter<some Write>) -> FormatResult
}

@frozen
public struct BinaryStyle: IntegerStyle {
    public func format(_ value: Int, _ formatter: inout Formatter<some Write>) -> FormatResult {
        var buffer = cci_uninit_buffer_128()
        let size = cci_write_int_binary(&buffer, value)
        let string = String(cString: buffer.end().advanced(by: -size))
        return formatter.write(string)
    }
}

@frozen
public struct OctalStyle: IntegerStyle {
    public func format(_ value: Int, _ formatter: inout Formatter<some Write>) -> FormatResult {
        var buffer = cci_uninit_buffer_128()
        let size = cci_write_int_octal(&buffer, value)
        let string = String(cString: buffer.end().advanced(by: -size))
        return formatter.write(string)
    }
}

@frozen
public struct LowerHexStyle: IntegerStyle {
    public func format(_ value: Int, _ formatter: inout Formatter<some Write>) -> FormatResult {
        var buffer = cci_uninit_buffer_128()
        let size = cci_write_int_lower_hex(&buffer, value)
        let string = String(cString: buffer.end().advanced(by: -size))
        return formatter.write(string)
    }
}

@frozen
public struct UpperHexStyle: IntegerStyle {
    public func format(_ value: Int, _ formatter: inout Formatter<some Write>) -> FormatResult {
        var buffer = cci_uninit_buffer_128()
        let size = cci_write_int_upper_hex(&buffer, value)
        let string = String(cString: buffer.end().advanced(by: -size))
        return formatter.write(string)
    }
}

@frozen
public struct DecimalStyle: IntegerStyle {
    public func format(_ value: Int, _ formatter: inout Formatter<some Write>) -> FormatResult {
        var buffer = cci_uninit_buffer_64()
        return withUnsafeMutableBytes(of: &buffer) { pointer in
            let buffer = pointer.assumingMemoryBound(to: cci_buffer_64.self)
                .baseAddress!
            let size = cci_write_int_decimal(buffer, value)
            let start = UnsafePointer<UInt8>(buffer.pointee.end().advanced(by: -size))
            return formatter.write(start, count: size)
        }
    }
}
