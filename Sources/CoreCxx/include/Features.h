#ifndef CORE_SWIFT_FEATURES_H
#define CORE_SWIFT_FEATURES_H

#if __has_include(<CoreSwift/Compiler.h>)
#include <CoreSwift/Compiler.h>
#include <CoreSwift/Language.h>
#include <CoreSwift/FeaturesCxx.h>
#else
#include <Compiler.h>
#include <Language.h>
#include <FeaturesCxx.h>
#endif

#endif // CORE_SWIFT_FEATURES_H
