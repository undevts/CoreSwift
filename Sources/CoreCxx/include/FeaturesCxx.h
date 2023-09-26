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
