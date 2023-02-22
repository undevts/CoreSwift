add_executable(CoreCxxTests
    main.cpp)
target_link_libraries(CoreCxxTests PRIVATE
    CoreSwift
    "-framework CoreFoundation")