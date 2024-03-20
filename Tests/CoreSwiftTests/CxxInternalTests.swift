import XCTest

#if DEBUG
@testable import CoreCxxInternal
@testable import CoreSwift
#else
import CoreCxxInternal
import CoreSwift
#endif

func fill(buffer: UnsafeMutablePointer<UInt8>, size: Int) {
    var start = buffer
    let end = start + size
    while start < end {
        start.initialize(to: UInt8.random(in: 1..<UInt8.max))
        start += 1
    }
}

func unrolled_find_uint8(_ bytes: UnsafeMutablePointer<UInt8>, _ size: Int, _ needle: UInt8) -> Bool {
    var start = bytes
    let end = bytes.advanced(by: size)
    let find = SIMD16<UInt8>(repeating: needle)
    while end - start >= 16 {
        var next = UnsafeMutableRawPointer(start)
            .assumingMemoryBound(to: SIMD16<UInt8>.self)
            .pointee
        next ^= find // xor
        next &= next
        if next.min() == 0 {
            return true
        }
//        let u64 = unsafeBitCast(next, to: SIMD2<UInt64>.self)
//        if u64.x == 0 || u64.y == 0 {
//            return true
//        }
        start += 16
    }
    while start < end {
        if start.pointee == needle {
            return true
        }
        start += 1
    }
    return false
}

final class CxxInternalTests: XCTestCase {
    func testUninitBuffer() {
        let buffer = cci_uninit_buffer_128()
        _ = buffer.data.0
    }
    
    func testUnrolledFindUInt8() throws {
#if DEBUG
        var buffer = cci_buffer_4096()
        let size = buffer.capacity
        let start = buffer.start()
        fill(buffer: start, size: size)

        XCTAssertFalse(cci_unrolled_find_uint8(start, size, 0))
        XCTAssertFalse(unrolled_find_uint8(start, size, 0))
        
        let next = buffer.start() + 100
        next.initialize(to: 0)
        XCTAssertTrue(cci_unrolled_find_uint8(start, size, 0))
        XCTAssertTrue(unrolled_find_uint8(start, size, 0))
#else
        throw XCTSkip("only supports debug version.")
#endif
    }
    
    func testUnrolledFindUInt8ForSlice() throws {
#if DEBUG
        let bytes = Bytes("Foobar")
        let i = bytes.startIndex + 1
        let temp = bytes[i..<bytes.endIndex]
        XCTAssertFalse(cci_unrolled_find_uint8(temp.storage.start, temp.count, 0))
        XCTAssertFalse(unrolled_find_uint8(temp.storage.start, temp.count, 0))
#else
        throw XCTSkip("only supports debug version.")
#endif
    }
    
    func testCUnrolledFindUInt8Performance() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        let size = 10_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        defer {
            buffer.deallocate()
        }
        fill(buffer: buffer, size: size)
        
        measure {
            cci_unrolled_find_uint8(buffer, size, 0)
        }
#endif
    }
    
    func testUnrolledFindUInt8Performance() throws {
#if DEBUG
        throw XCTSkip("Performance tests should run in release mode.")
#else
        let size = 10_000_000
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        defer {
            buffer.deallocate()
        }
        fill(buffer: buffer, size: size)

        measure {
            unrolled_find_uint8(buffer, size, 0)
        }
#endif
    }
}
