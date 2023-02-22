// MIT License
//
// Copyright (c) 2022 The Core Swift Project Authors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#ifndef CORE_SWIFT_LANGUAGE_H
#define CORE_SWIFT_LANGUAGE_H

#if COCOAPODS
#include <CoreSwift/Compiler.h>
#elif CS_HEADER_STYLE_CMAKE
#include <CoreCxx/Compiler.h>
#else // SWIFT_PACKAGE
#include <Compiler.h>
#endif

/**
 * LANG() - which languages currently support.
 */
#define LANG(NAME) (defined CS_LANG_##NAME && CS_LANG_##NAME)

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

#if COCOAPODS
#include <CoreSwift/LanguageCxx.h>
#include <CoreSwift/LanguageObjC.h>
#include <CoreSwift/LanguageSwift.h>
#elif CS_HEADER_STYLE_CMAKE
#include <CoreCxx/LanguageCxx.h>
#include <CoreCxx/LanguageObjC.h>
#include <CoreCxx/LanguageSwift.h>
#else // SWIFT_PACKAGE
#include <LanguageCxx.h>
#include <LanguageObjC.h>
#include <LanguageSwift.h>
#endif

#endif // CORE_SWIFT_LANGUAGE_H
