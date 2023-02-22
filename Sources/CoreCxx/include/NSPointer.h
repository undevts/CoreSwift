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

#ifndef CORE_SWIFT_NSPOINTER_H
#define CORE_SWIFT_NSPOINTER_H

#include <Foundation/NSObject.h>
#include <CoreCxx/CFPointer.h>

#if LANG(OBJCXX) && OS(DARWIN)

CS_ASSUME_NONNULL_BEGIN

namespace ns {
#if CS_CXX_HAS_CONCEPTS
template<typename T>
concept Deleter = requires (id CS_NULLABLE value) {
    T::retain(value);
    T::release(value);
};
#endif

struct DefaultDeleter final {
    CF_INLINE void retain(id value) noexcept {
        [value retain];
    }

    CF_INLINE void release(id value) noexcept {
        [value release];
    }
};

#if CS_CXX_HAS_CONCEPTS
static_assert(Deleter<DefaultDeleter>);
#endif

using RetainTag = cf::RetainTag;

inline constexpr RetainTag retainTag{};
}

template<typename T, typename Deleter = ns::DefaultDeleter>
#if CS_CXX_HAS_CONCEPTS
    requires(ns::Deleter<Deleter>)
#endif
class NSPointer final {
private:
    static_assert(std::is_pointer_v<T>);
public:

    NSPointer() noexcept: _value(nullptr) {}

    ~NSPointer() noexcept {
        Deleter::release(_value);
    }

    NSPointer(std::nullptr_t) noexcept: _value(nullptr) {}

    explicit NSPointer(T CS_NULLABLE value) noexcept: _value(value) {}

    explicit NSPointer(T CS_NULLABLE value, ns::RetainTag) noexcept: _value(value) {
        Deleter::retain(_value);
    }

    NSPointer(const NSPointer& other) noexcept: _value(other._value) {
        Deleter::retain(_value);
    }

    NSPointer(NSPointer&& other) noexcept: _value(other._value) {
        other._value = nullptr;
    }

    NSPointer& operator=(const NSPointer& other) noexcept {
        Deleter::release(_value);
        _value = other._value;
        Deleter::retain(_value);
        return *this;
    }

    NSPointer& operator=(NSPointer&& other) noexcept {
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
        id result = _value;
        Deleter::release(result);
        _value = nullptr;
        return result;
    }

    T CS_NULLABLE operator*() const noexcept {
        return reinterpret_cast<T>(reinterpret_cast<void*>(_value));
    }

    explicit operator bool() const noexcept {
        return _value != nullptr;
    }

private:
    id CS_NULLABLE _value;
};

CS_ASSUME_NONNULL_END

#endif // LANG(OBJCXX) && OS(DARWIN)

#endif // CORE_SWIFT_NSPOINTER_H