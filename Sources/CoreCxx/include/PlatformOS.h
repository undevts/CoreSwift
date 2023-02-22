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

#ifndef CORE_SWIFT_PLATFORM_OS_H
#define CORE_SWIFT_PLATFORM_OS_H

#ifndef CORE_SWIFT_PLATFORM_H
#warning "Importing this file directly may leading errors."
#endif

#if defined(__APPLE__)
#include <Availability.h>
#include <AvailabilityMacros.h>
#include <TargetConditionals.h>
#endif

/**
 * OS() - underlying operating system.
 */
#define OS(NAME) (defined CS_OS_##NAME && CS_OS_##NAME)

/* OS(DARWIN) - Any Darwin-based OS, including macOS, iOS, macCatalyst, tvOS, and watchOS */
#if defined(__APPLE__)
#define CS_OS_DARWIN 1
#endif

/* OS(IOS_FAMILY) - iOS family, including iOS, iPadOS, macCatalyst, tvOS, watchOS */
#if OS(DARWIN) && TARGET_OS_IPHONE
#define CS_OS_IOS_FAMILY 1
#endif

/* OS(IOS) - iOS and iPadOS only (iPhone and iPad), not including macCatalyst, not including watchOS, not including tvOS */
#if OS(DARWIN) && (TARGET_OS_IOS && !(defined(TARGET_OS_MACCATALYST) && TARGET_OS_MACCATALYST))
#define CS_OS_IOS 1
#endif

/* OS(TVOS) - tvOS */
#if OS(DARWIN) && TARGET_OS_TV
#define CS_OS_TVOS 1
#endif

/* OS(WATCHOS) - watchOS */
#if OS(DARWIN) && TARGET_OS_WATCH
#define CS_OS_WATCHOS 1
#endif

// TODO: Use `TARGET_OS_MAC` ?
/* OS(MACOS) - macOS (not including iOS family) */
#if OS(DARWIN) && TARGET_OS_OSX
#define CS_OS_MACOS 1
#endif

/* OS(LINUX) - Linux */
#if defined(__linux__)
#define CS_OS_LINUX 1
#endif

/* OS(WINDOWS) - Any version of Windows */
#if defined(WIN32) || defined(_WIN32)
#define CS_OS_WINDOWS 1
#endif

#endif // CORE_SWIFT_PLATFORM_OS_H
