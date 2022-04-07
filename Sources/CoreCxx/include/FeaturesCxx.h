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

#ifndef CORE_SWIFT_FEATURES_CXX_H
#define CORE_SWIFT_FEATURES_CXX_H

#ifndef CORE_SWIFT_FEATURES_H
#warning "Importing this file directly may leading errors."
#endif

#if __cpp_concepts >= 201907L
#   define CS_CXX_HAS_CONCEPTS 1
#else
#   define CS_CXX_HAS_CONCEPTS 0
#endif

#if __cpp_exceptions
#   define CS_CXX_HAS_EXCEPTIONS 1
#else
#   define CS_CXX_HAS_EXCEPTIONS 0
#endif

#endif // CORE_SWIFT_FEATURES_CXX_H
