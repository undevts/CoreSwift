#ifndef CORE_CXX_INTERNAL_H
#define CORE_CXX_INTERNAL_H

#if __has_include(<CoreSwift/Buffer.h>)
#include <CoreSwift/Buffer.h>
#include <CoreSwift/File.h>
#include <CoreSwift/Format.h>
#elif __has_include(<CoreCxxInternal/Buffer.h>)
#include <CoreCxxInternal/Buffer.h>
#include <CoreCxxInternal/File.h>
#include <CoreCxxInternal/Format.h>
#else
#include <Buffer.h>
#include <File.h>
#include <Format.h>
#endif

#endif // CORE_CXX_INTERNAL_H
