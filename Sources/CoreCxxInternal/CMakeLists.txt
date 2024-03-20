add_library(CoreCxxInternal
    include/Buffer.h
    include/CoreCxxInternal.h
    include/File.h
    include/Format.h
    CoreCxxInternal.cpp
    Format.cpp)

target_link_libraries(CoreCxxInternal PUBLIC CoreCxx)

target_include_directories(CoreCxxInternal SYSTEM PUBLIC
    include)