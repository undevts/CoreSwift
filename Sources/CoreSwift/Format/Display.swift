public protocol Display {
    func format(_ formatter: inout Formatter<some Write>) -> FormatResult
}

public protocol DebugDisplay {
    func debugFormat(_ formatter: inout Formatter<some Write>) -> FormatResult
}

//public protocol BinaryStyle {
//    func format(_ formatter: inout Formatter) -> FormatResult
//}
//
//public protocol OctalStyle {
//    func format(_ formatter: inout Formatter) -> FormatResult
//}
//
//public protocol LowerHexStyle {
//    func format(_ formatter: inout Formatter) -> FormatResult
//}
//
//public protocol UpperHexStyle {
//    func format(_ formatter: inout Formatter) -> FormatResult
//}
//
//public protocol PointerStyle {
//    func format(_ formatter: inout Formatter) -> FormatResult
//}

extension Int: Display, DebugDisplay {
    public func format(_ formatter: inout Formatter<some Write>) -> FormatResult {
        return DecimalStyle().format(self, &formatter)
    }
    
    public func debugFormat(_ formatter: inout Formatter<some Write>) -> FormatResult {
        return DecimalStyle().format(self, &formatter)
    }
}

// extension Slice: Display where Base: Display {
//     public func format(_ formatter: inout Formatter) -> FormatResult {
//         return .success(())
//     }
// }

// extension Slice: DebugDisplay where Base: DebugDisplay {
//     public func debugFormat(_ formatter: inout Formatter) -> FormatResult {
//         return .success(())
//     }
// }

// extension UnsafePointer: DebugDisplay where Pointee: DebugDisplay {
//     public func debugFormat(_ formatter: inout Formatter) -> FormatResult {
//         pointee.debugFormat(&formatter)
//     }
// }

// extension UnsafeMutablePointer: DebugDisplay where Pointee: DebugDisplay {
//     public func debugFormat(_ formatter: inout Formatter) -> FormatResult {
//         pointee.debugFormat(&formatter)
//     }
// }

// extension UnsafeMutableBufferPointer {
    
// }
