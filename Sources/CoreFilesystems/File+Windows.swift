#if os(Windows)

import WinSDK

#if SWIFT_PACKAGE
import CoreIOKit
#endif

extension File {
    @usableFromInline
    struct Content {
        let handle: OwnedHandle
    }
}

extension File.Content {
    @usableFromInline
    static func open(_ path: Path, option: OpenOption.Content) -> IOResult<File> {
        // let accessMode: DWORD
        // switch option.resolveAccessMode() {
        // case let .success(mode):
        //     accessMode = mode
        // case let .failure(error):
        //     return .failure(error)
        // }
        // let handle = CreateFileW(nil, accessMode, 0, nil, 0, 0, nil)
        fatalError()
    }
}

#endif // os(Windows)
