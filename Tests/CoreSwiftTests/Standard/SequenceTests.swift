import XCTest
@testable import CoreSwift

final class SequenceTests: XCTestCase {
    func testMapNotNil() {
        do {
            let array: [Int?] = [1, 3, 5]
            let result = array.mapNotNil()
            XCTAssertEqual(array, result)
        }
        do {
            let array: [Int?] = [1, nil, 5]
            let result = array.mapNotNil()
            XCTAssertEqual(result, [1, 5])
        }
        do {
            let array: [Int?] = []
            let result = array.mapNotNil()
            XCTAssertEqual(result, [])
        }
        do {
            let array: [Int?] = [nil, nil, nil]
            let result = array.mapNotNil()
            XCTAssertEqual(result, [])
        }
    }
}
