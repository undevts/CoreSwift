import XCTest

#if DEBUG
@testable import CoreFilesystem
#else
import CoreFilesystem
#endif

func assertNoError<T, E>(_ method: () -> Result<T, E>, file: StaticString = #filePath,
                         line: UInt = #line) throws -> T where E: Error {
    switch method() {
    case let .success(value):
        return value
    case let .failure(error):
        XCTFail("\(error)", file: file, line: line)
        throw error
    }
}

final class FilesystemTests: XCTestCase {
    func testTryExists() throws {
        var exists = try assertNoError {
            Filesystem.tryExists(path: "/file/not/exists")
        }
        XCTAssertFalse(exists)

        exists = try assertNoError {
            Filesystem.tryExists(path: "/usr/bin")
        }
        XCTAssertTrue(exists)
    }

    func testReadDirectory() throws {
//        print(#file)
//        print(#filePath)
        var path = Path(#file)
        let filename = path.filename ?? ""
        path = Path(stringLiteral: "/Users/yangnan/Documents/swift/CoreSwift/Tests/CoreFilesystemTests")
        let directories = try Filesystem.readDirectory(path: path).get()
//        for directory in directories {
//            print(try directory.get().path)
//        }
        let contains = try directories.contains { result -> Bool in
            let directory = try result.get()
            return directory.filename == filename
        }
        XCTAssertTrue(contains)
    }
}
