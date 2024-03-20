add_library(CoreCxx
    include/Compiler.h
    include/Features.h
    include/FeaturesCxx.h
    include/Language.h
    include/LanguageCxx.h
    include/LanguageObjC.h
    include/LanguageSwift.h
    include/Typing.h
    CoreCxx.cpp)

target_include_directories(CoreCxx SYSTEM PUBLIC
    include)
