#ifndef CORE_CXX_INTERNAL_BUFFER_H
#define CORE_CXX_INTERNAL_BUFFER_H

#if __has_include(<CoreSwift/Language.h>)
#include <CoreSwift/Language.h>
#elif __has_include(<CoreCxx/Language.h>)
#include <CoreCxx/Language.h>
#else
#include <Language.h>
#endif

#if CS_LANG_CXX
#include <cstdint>
#include <cstddef>
#include <cstdbool>
#else
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#endif

CS_C_FILE_BEGIN

static inline uint8_t* CS_NONNULL cci_null_bytes() {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"

#if CS_LANG_CXX
    return nullptr;
#else
    return NULL;
#endif

#pragma GCC diagnostic pop
}

typedef struct {
    uint8_t data[32];
} cci_buffer_32;

typedef struct {
    uint8_t data[64];
} cci_buffer_64;

typedef struct {
    uint8_t data[128];
} cci_buffer_128;

typedef struct {
    uint8_t data[256];
} cci_buffer_256;

typedef struct {
    uint8_t data[384];
} cci_buffer_384;

typedef struct {
    uint8_t data[512];
} cci_buffer_512;

typedef struct {
    uint8_t data[1024];
} cci_buffer_1024;

typedef struct {
    uint8_t data[2048];
} cci_buffer_2048;

typedef struct {
    uint8_t data[4096];
} cci_buffer_4096;

static inline cci_buffer_32 cci_uninit_buffer_32() {
    cci_buffer_32 local;
    return local;
}

static inline cci_buffer_64 cci_uninit_buffer_64() {
    cci_buffer_64 local;
    return local;
}

static inline cci_buffer_128 cci_uninit_buffer_128() {
    cci_buffer_128 local;
    return local;
}

static inline cci_buffer_256 cci_uninit_buffer_256() {
    cci_buffer_256 local;
    return local;
}

static inline cci_buffer_384 cci_uninit_buffer_384() {
    cci_buffer_384 local;
    return local;
}

static inline cci_buffer_512 cci_uninit_buffer_512() {
    cci_buffer_512 local;
    return local;
}

static inline cci_buffer_1024 cci_uninit_buffer_1024() {
    cci_buffer_1024 local;
    return local;
}

static inline cci_buffer_2048 cci_uninit_buffer_2048() {
    cci_buffer_2048 local;
    return local;
}

static inline cci_buffer_4096 cci_uninit_buffer_4096() {
    cci_buffer_4096 local;
    return local;
}

static inline uint8_t* CS_NONNULL cci_bytes_plus(uint8_t* CS_NONNULL bytes, NSUInteger value) {
    return bytes + (size_t)value;
}

static inline uint8_t* CS_NONNULL cci_bytes_minus(uint8_t* CS_NONNULL bytes, NSUInteger value) {
    return bytes - (size_t)value;
}

bool cci_unrolled_find_uint8(uint8_t *CS_NONNULL bytes, size_t count, uint8_t needle);

CS_C_FILE_END

#endif // CORE_CXX_INTERNAL_BUFFER_H
