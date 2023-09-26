#ifndef CORE_SWIFT_DEFINE_LANGUAGE_SWIFT_H
#define CORE_SWIFT_DEFINE_LANGUAGE_SWIFT_H

#ifndef CORE_SWIFT_DEFINE_LANGUAGE_H
#warning "Importing this file directly may cause errors."
#endif

#if defined(CF_SWIFT_NAME)
#   define CS_SWIFT_NAME(_name) CF_SWIFT_NAME(_name)
#else
#   if __has_attribute(swift_name)
#       define CS_SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
#   else
#       define CS_SWIFT_NAME(_name)
#   endif
#endif

#endif // CORE_SWIFT_DEFINE_LANGUAGE_SWIFT_H
