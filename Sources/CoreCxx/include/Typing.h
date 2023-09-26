#ifndef CORE_SWIFT_TYPING_H
#define CORE_SWIFT_TYPING_H

#if __has_include(<CoreSwift/Language.h>)
#include <CoreSwift/Language.h>
#include <CoreSwift/Features.h>
#else
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
