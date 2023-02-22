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

#ifndef CORE_SWIFT_CFPOINTER_H
#define CORE_SWIFT_CFPOINTER_H

#if COCOAPODS
#include <CoreSwift/Platform.h>
#include <CoreSwift/Language.h>
#include <CoreSwift/Features.h>
#elif CS_HEADER_STYLE_CMAKE
#include <CoreCxx/Platform.h>
#include <CoreCxx/Language.h>
#include <CoreCxx/Features.h>
#else // SWIFT_PACKAGE
#include <Platform.h>
#include <Language.h>
#include <Features.h>
#endif

#if LANG(CXX) && OS(DARWIN)

#include <CoreFoundation/CFBase.h>
#include <memory>
#include <type_traits>

CS_ASSUME_NONNULL_BEGIN

namespace cf {
#if CS_CXX_HAS_CONCEPTS
template<typename T>
concept Deleter = requires (CFTypeRef CS_NULLABLE value) {
    T::retain(value);
    T::release(value);
};
#endif

struct DefaultDeleter final {
    CF_INLINE void retain(CFTypeRef value) noexcept {
        if (value != nullptr) {
            CFRetain(value); // This value must not be NULL.
        }
    }

    CF_INLINE void release(CFTypeRef value) noexcept {
        if (value != nullptr) {
            CFRelease(value); // This value must not be NULL.
        }
    }
};

#if CS_CXX_HAS_CONCEPTS
static_assert(Deleter<DefaultDeleter>);
#endif

struct RetainTag {
    explicit RetainTag() = default;
};

inline constexpr RetainTag retainTag{};
} // namespace cf

template<typename T, typename Deleter = cf::DefaultDeleter>
#if CS_CXX_HAS_CONCEPTS
    requires(cf::Deleter<Deleter>)
#endif
class CFPointer final {
private:
    static_assert(std::is_pointer_v<T>);
public:

    CFPointer() noexcept: _value(nullptr) {}

    ~CFPointer() noexcept {
        Deleter::release(_value);
    }

    CFPointer(std::nullptr_t) noexcept: _value(nullptr) {}

    explicit CFPointer(T CS_NULLABLE value) noexcept: _value(value) {}

    explicit CFPointer(T CS_NULLABLE value, cf::RetainTag) noexcept: _value(value) {
        Deleter::retain(_value);
    }

    CFPointer(const CFPointer& other) noexcept: _value(other._value) {
        Deleter::retain(_value);
    }

    CFPointer(CFPointer&& other) noexcept: _value(other._value) {
        other._value = nullptr;
    }

    CFPointer& operator=(const CFPointer& other) noexcept {
        Deleter::release(_value);
        _value = other._value;
        Deleter::retain(_value);
        return *this;
    }

    CFPointer& operator=(CFPointer&& other) noexcept {
        Deleter::release(_value);
        _value = other._value;
        return *this;
    }

    void reset() {
        Deleter::release(_value);
        _value = nullptr;
    }

    void reset(T value) {
        if (LIKELY(value != _value)) {
            Deleter::release(_value);
            _value = value;
            Deleter::retain(_value);
        }
    }

    T release() {
        auto result = _value;
        Deleter::release(result);
        _value = nullptr;
        return result;
    }

    T CS_NULLABLE operator*() const noexcept {
        return reinterpret_cast<T>(const_cast<void*>(_value));
    }

    explicit operator bool() const noexcept {
        return _value != nullptr;
    }

private:
    CFTypeRef CS_NULLABLE _value;
};

CS_ASSUME_NONNULL_END

#endif // LANG(CXX) && OS(DARWIN)

#endif // CORE_SWIFT_CFPOINTER_H
