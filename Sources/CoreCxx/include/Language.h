#ifndef CORE_SWIFT_DEFINE_LANGUAGE_H
#define CORE_SWIFT_DEFINE_LANGUAGE_H

#if __has_include(<CoreSwift/Compiler.h>)
#include <CoreSwift/Compiler.h>
#else
#include <Compiler.h>
#endif

#if (__cplusplus)
#   define CS_LANG_CXX 1
#else
#   define CS_LANG_CXX 0
#endif

#if defined(__OBJC__)
#   define CS_LANG_OBJC 1
#else
#   define CS_LANG_OBJC 0
#endif

#if (CS_LANG_CXX && CS_LANG_OBJC)
#   define CS_LANG_OBJCXX 1
#else
#   define CS_LANG_OBJCXX 0
#endif

#if defined(__swift__)
#   define CS_LANG_SWIFT 1
#else
#   define CS_LANG_SWIFT 0
#endif

#if __has_include(<CoreSwift/LanguageCxx.h>)
#include <CoreSwift/LanguageCxx.h>
#include <CoreSwift/LanguageObjC.h>
#include <CoreSwift/LanguageSwift.h>
#else
#include <LanguageCxx.h>
#include <LanguageObjC.h>
#include <LanguageSwift.h>
#endif

#endif // CORE_SWIFT_DEFINE_LANGUAGE_H
