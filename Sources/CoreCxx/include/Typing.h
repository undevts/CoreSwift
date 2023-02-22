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

#ifndef CORE_SWIFT_TYPING_H
#define CORE_SWIFT_TYPING_H

#if COCOAPODS
#include <CoreSwift/Language.h>
#include <CoreSwift/Features.h>
#elif CS_HEADER_STYLE_CMAKE
#include <CoreCxx/Language.h>
#include <CoreCxx/Features.h>
#else // SWIFT_PACKAGE
#include <Language.h>
#include <Features.h>
#endif

#if CS_CXX_HAS_CONCEPTS

#include <type_traits>

namespace types {
template<typename T, typename U>
concept Same = std::is_same_v<T, U>;
}

#endif // CS_CXX_HAS_CONCEPTS

#endif // CORE_SWIFT_TYPING_H
