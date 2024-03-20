@frozen
public enum Format {
    // Namespace
}

#if swift(>=5.9)
extension Format {
    public static func format(_ values: Int...) -> String {
        let write = BytesWrite()
        var formatter = Formatter(write)
        for value in values {
            _ = value.format(&formatter)
        }
        return write.toString()
    }
}
#endif

#if swift(>=5.9)
extension Format {
    public static func print<each T: Display>(_ format: StaticString, _ values: repeat each T) {
        let write = BytesWrite()
        var formatter = Formatter(write)
        _ = formatter.write(format: format, repeat each values)
        Swift.print(write.toString())
    }

    public static func format<each T: Display>(_ format: StaticString, _ values: repeat each T) -> String {
        let write = BytesWrite()
        var formatter = Formatter(write)
        _ = formatter.write(format: format, repeat each values)
        return write.toString()
    }

    public static func debugPrint<each T: DebugDisplay>(_ format: StaticString, _ values: repeat each T) {
        let write = BytesWrite()
        var formatter = Formatter(write)
        _ = formatter.write(format: format, repeat each values)
        Swift.print(write.toString())
    }

    public static func debugFormat<each T: DebugDisplay>(_ format: StaticString, _ values: repeat each T) -> String {
        let write = BytesWrite()
        var formatter = Formatter(write)
        _ = formatter.write(format: format, repeat each values)
        return write.toString()
    }
}
#endif // swift(>=5.9)
