import XCTest
@testable import CoreSwift

final class RangeReplaceableCollectionTests: XCTestCase {
    func testReplace() {
        var array = [1, 9, 8]
        XCTAssertEqual(array.replaced(at: 1, with: 100), [1, 100, 8])
        array.replace(at: 1, with: 100)
        XCTAssertEqual(array, [1, 100, 8])

        XCTAssertEqual(array.replaced(at: 0, with: -1), [-1, 100, 8])
        array.replace(at: 0, with: 200)
        XCTAssertEqual(array, [200, 100, 8])
    }
}