public protocol AnyPointer: _Pointer {
    func deallocate()
}

public protocol TypedPointer: AnyPointer {
    var pointee: Pointee { get }
}

extension UnsafeRawPointer: AnyPointer {}
extension UnsafeMutableRawPointer: AnyPointer {}
extension UnsafePointer: TypedPointer {}
extension UnsafeMutablePointer: TypedPointer {}

#if swift(>=5.9)
@frozen
@propertyWrapper
public struct OwnedPointer<Pointer, Value>: ~Copyable where Pointer: AnyPointer, Value == Pointer.Pointee  {
    public typealias Dealloc = (Pointer) -> Void
    
    var value: Pointer
    let dealloc: Dealloc?
    
    public var wrappedValue: Pointer {
        value
    }
    
    public init(_ value: Pointer, dealloc: Dealloc? = nil) {
        self.value = value
        self.dealloc = dealloc
    }
    
    public init(wrappedValue: Pointer) {
        // ???
        // Copy of noncopyable typed value. This is a compiler bug.
        // self.init(wrappedValue, dealloc: nil)
        value = wrappedValue
        dealloc = nil
    }

    public init(wrappedValue: Pointer, dealloc: Dealloc? = nil) {
        // ???
        // Copy of noncopyable typed value. This is a compiler bug.
        // self.init(wrappedValue, dealloc: dealloc)
        value = wrappedValue
        self.dealloc = dealloc
    }
    
    deinit {
        if let dealloc {
            dealloc(value)
        } else {
            value.deallocate()
        }
    }
}
#else
@propertyWrapper
public class OwnedPointer<Pointer, Value> where Pointer: AnyPointer, Value == Pointer.Pointee {
    public typealias Dealloc = (Pointer) -> Void
    
    var value: Pointer
    let dealloc: Dealloc?
    private var holder: Holder

    public var wrappedValue: Pointer {
        value
    }

    public init(_ value: Pointer, dealloc: Dealloc? = nil) {
        self.value = value
        self.dealloc = dealloc
        holder = Holder()
    }

    public convenience init(wrappedValue: Pointer) {
        self.init(wrappedValue, dealloc: nil)
    }

    public convenience init(wrappedValue: Pointer, dealloc: Dealloc? = nil) {
        self.init(wrappedValue, dealloc: dealloc)
    }

    deinit {
       guard isKnownUniquelyReferenced(&holder) else {
           return
       }
        if let dealloc {
            dealloc(value)
        } else {
            value.deallocate()
        }
    }

    private class Holder {
        init() {}
    }
}
#endif

extension OwnedPointer {
    public var pointer: Pointer? {
        value
    }
}

extension OwnedPointer where Pointer: TypedPointer {
    public var pointee: Value {
        value.pointee
    }

    public var projectedValue: Value {
        value.pointee
    }
}
