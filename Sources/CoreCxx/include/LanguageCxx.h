#ifndef CORE_SWIFT_DEFINE_LANGUAGE_CXX_H
#define CORE_SWIFT_DEFINE_LANGUAGE_CXX_H

#ifndef CORE_SWIFT_DEFINE_LANGUAGE_H
#warning "Importing this file directly may leading errors."
#endif

#define CS_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define CS_ASSUME_NONNULL_END   _Pragma("clang assume_nonnull end")

#if CS_LANG_CXX
#   define CS_EXTERN_C_BEGIN   extern "C" {
#   define CS_EXTERN_C_END     }
#else
#   define CS_EXTERN_C_BEGIN
#   define CS_EXTERN_C_END
#endif

#if CS_LANG_CXX
#   define CS_C_FILE_BEGIN  CS_ASSUME_NONNULL_BEGIN \
                            CS_EXTERN_C_BEGIN
#   define CS_C_FILE_END    CS_EXTERN_C_END \
                            CS_ASSUME_NONNULL_END
#else
#   define CS_C_FILE_BEGIN  CS_ASSUME_NONNULL_BEGIN
#   define CS_C_FILE_END    CS_ASSUME_NONNULL_END
#endif

#if CS_LANG_CXX
#   define CS_CPP_NAME_SPACE_BEGIN(NAME)    namespace NAME {
#   define CS_CPP_NAME_SPACE_END            }
#else
#   define CS_CPP_NAME_SPACE_BEGIN(NAME)
#   define CS_CPP_NAME_SPACE_END
#endif

// ------------- NULLABLE ------------------
// http://clang.llvm.org/docs/AttributeReference.html#nullability-attributes
// A nullable pointer to non-null pointers to const characters.
// const char *join_strings(const char * _Nonnull * _Nullable strings, unsigned n);
#if defined(__clang__)
// int fetch(int * CS_NONNULL ptr);
#define CS_NONNULL _Nonnull
#define CS_NULL_UNSPECIFIED _Null_unspecified
// int fetch_or_zero(int * CS_NULLABLE ptr);
#define CS_NULLABLE _Nullable
#else
#define CS_NONNULL
#define CS_NULL_UNSPECIFIED
#define CS_NULLABLE
#endif // defined(__clang__)
// ------------- NULLABLE ------------------

#if CS_LANG_CXX

#define CS_SIMPLE_CONVERSION(CxxType, CRef)                     \
inline CxxType *unwrap(CRef value) {                            \
    return reinterpret_cast<CxxType*>(value);                   \
}                                                               \
                                                                \
inline CRef wrap(const CxxType* value) {                        \
    return reinterpret_cast<CRef>(const_cast<CxxType*>(value)); \
}                                                               \

#define CS_STATIC_CONVERSION(TARGET, SOURCE)                    \
inline TARGET unwrap(const SOURCE& value) {                     \
    return static_cast<TARGET>(value);                          \
}                                                               \
                                                                \
inline SOURCE wrap(const TARGET& value) {                       \
    return static_cast<SOURCE>(value);                          \
}                                                               \

#define CS_POINTER_CAST(type, source) (reinterpret_cast<type>(source))

#define CS_VALUE_CAST(type, source) (static_cast<type>(source))

#else // CS_LANG_CXX

#define CS_SIMPLE_CONVERSION(CxxType, CRef)                     \
static inline CxxType *unwrap(CRef value) {                     \
    return (CxxType*)(value);                                   \
}                                                               \
                                                                \
static inline CRef wrap(const CxxType* value) {                 \
    return (CRef)(const_cast<CxxType*>(value));                 \
}                                                               \

#define CS_STATIC_CONVERSION(TARGET, SOURCE)                    \
static inline TARGET unwrap(const SOURCE& value) {              \
    return (TARGET)(value);                                     \
}                                                               \
                                                                \
static inline SOURCE wrap(const TARGET& value) {                \
    return (SOURCE)(value);                                     \
}                                                               \

#define CS_POINTER_CAST(type, source) ((type)(source))

#define CS_VALUE_CAST(type, source) ((type)(source))

#endif // CS_LANG_CXX

#endif // CORE_SWIFT_DEFINE_LANGUAGE_CXX_H
