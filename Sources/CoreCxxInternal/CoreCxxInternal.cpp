#include <Buffer.h>
#include <ranges>

#if defined(__i386__) || defined(__x86_64__)
#include <smmintrin.h>
#elif defined(__ARM_NEON)
#include <arm_neon.h>
#endif

bool cci_unrolled_find_uint8(uint8_t* CS_NONNULL bytes, size_t count, uint8_t needle) {
    if (UNLIKELY(bytes == nullptr || count < 1)) {
        return false;
    }
    auto end = bytes + count;
#ifdef __SSE2__
    // 128-bit
    auto find = _mm_set1_epi8(static_cast<char>(needle));
    while (end - bytes >= 16) {
        auto c = _mm_cmpeq_epi8(*reinterpret_cast<__m128i*>(bytes), find);
#ifdef __SSE4_1__
        if (_mm_testz_si128(c, c) == 0) {
            return true;
        }
#else
        if (_mm_movemask_epi8(c) == 0) {
            return true;
        }
#endif
        bytes += 16;
    }
#elif __ARM_NEON
    // neon version _mm_testz_si128
    // https://android.googlesource.com/platform/external/pffft/+/refs/heads/main/sse2neon.h
    // 128-bit
    uint8x16_t find = vdupq_n_u8(needle);
    while (end - bytes >= 16) {
        auto c = vceqq_u8(vld1q_u8(bytes), find);
        auto r = vreinterpretq_u64_u8(vandq_u8(c, c));
        if (vgetq_lane_u64(r, 0) != 0 || vgetq_lane_u64(r, 1) != 0) {
            return true;
        }
        bytes += 16;
    }
#else
    while (end - bytes >= 8) {
        if (*(bytes++) == needle || // 0
            *(bytes++) == needle || // 1
            *(bytes++) == needle || // 2
            *(bytes++) == needle || // 3
            *(bytes++) == needle || // 4
            *(bytes++) == needle || // 5
            *(bytes++) == needle || // 6
            *(bytes++) == needle) { // 7
            return true;
        }
    }
#endif
    while (bytes < end) {
        if (*bytes == needle) {
            return true;
        }
        bytes += 1;
    }
    return false;
}

// Compute the bitwise AND of 128 bits (representing integer data) in a and b,
// and set ZF to 1 if the result is zero, otherwise set ZF to 0. Compute the
// bitwise NOT of a and then AND with b, and set CF to 1 if the result is zero,
// otherwise set CF to 0. Return the ZF value.
// https://software.intel.com/sites/landingpage/IntrinsicsGuide/#text=_mm_testz_si128
// FORCE_INLINE int _mm_testz_si128(__m128i a, __m128i b)
// {
//     int64x2_t s64 =
//         vandq_s64(vreinterpretq_s64_m128i(a), vreinterpretq_s64_m128i(b));
//     return !(vgetq_lane_s64(s64, 0) | vgetq_lane_s64(s64, 1));
// }
