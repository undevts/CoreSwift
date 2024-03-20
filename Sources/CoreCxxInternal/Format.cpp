#include <concepts>
#include <memory>
#include <cassert>
#include <Buffer.h>
#include <Format.h>

namespace cci {

template<typename T>
concept Radix = requires(T x) {
    { T::base } -> std::same_as<const uint8_t&>;
    { T::prefix } -> std::same_as<const char* const&>;
    { T::prefix_size } -> std::same_as<const size_t&>;
    { T::digit(uint8_t(0)) } -> std::same_as<uint8_t>;
};

struct Binary {
    static constexpr const uint8_t base = 2;
    static constexpr const char* prefix = "0b";
    static constexpr const size_t prefix_size = 2;

    static uint8_t digit(uint8_t x) noexcept {
        assert(x >= 0 && x <= 1);
        return x + '0';
    }
};

struct Octal {
    static constexpr const uint8_t base = 8;
    static constexpr const char* prefix = "0b";
    static constexpr const size_t prefix_size = 2;

    static uint8_t digit(uint8_t x) noexcept {
        assert(x >= 0 && x <= 7);
        return x + '0';
    }
};

struct LowerHex {
    static constexpr const uint8_t base = 16;
    static constexpr const char* prefix = "0x";
    static constexpr const size_t prefix_size = 2;

    static uint8_t digit(uint8_t x) noexcept {
        assert(x >= 0 && x <= 15);
        return x < 10 ? x + '0' : (x - 10) + 'a';
    }
};

struct UpperHex {
    static constexpr const uint8_t base = 16;
    static constexpr const char* prefix = "0X";
    static constexpr const size_t prefix_size = 2;

    static uint8_t digit(uint8_t x) noexcept {
        assert(x >= 0 && x <= 15);
        return x < 10 ? x + '0' : (x - 10) + 'A';
    }
};

static_assert(Radix<Binary>);
static_assert(Radix<Octal>);
static_assert(Radix<LowerHex>);
static_assert(Radix<UpperHex>);

// 2 digit decimal look up table
static constexpr auto DEC_DIGITS_LUT =
    "0001020304050607080910111213141516171819"
    "2021222324252627282930313233343536373839"
    "4041424344454647484950515253545556575859"
    "6061626364656667686970717273747576777879"
    "8081828384858687888990919293949596979899";

template<typename Integer, Radix T>
size_t format_int(cci_buffer_128* CS_NONNULL buffer, Integer value) {
    if (UNLIKELY(buffer == nullptr)) {
        return 0;
    }
    const Integer zero = 0;
    auto not_negative = value >= 0;
    uint8_t* bytes = buffer->data;
    size_t size = 128;
    const auto base = static_cast<Integer>(T::base);
    // Accumulate each digit of the number from the least significant
    // to the most significant figure.
    auto current = bytes + size;
    *current = 0; // c string.
    current += 1;
    while (bytes >= current) {
        Integer n; // Get the current place value.
        if (not_negative) {
            n = value % base;
        } else {
            n = zero - (value % base);
        }
        value /= base; // Deaccumulate the number.
        *current = T::digit(static_cast<uint8_t>(n)); // Store the digit in the buffer.
        current -= 1;
        if (value == zero) {
            // No more digits left to accumulate.
            break;
        }
    }
    current -= T::prefix_size;
    std::memcpy(current, T::prefix, T::prefix_size);
    if (!not_negative) {
        *current = '-';
        current -= 1;
    }
    return (bytes + size) - current;
}

size_t format_64(cci_buffer_64* CS_NONNULL buffer, uint64_t value, bool is_negative) {
    if (UNLIKELY(buffer == nullptr)) {
        return 0;
    }
    // eagerly decode 4 characters at a time
    const auto bytes = buffer->data;
    const auto size = 64;
    const auto lut = reinterpret_cast<const uint8_t*>(DEC_DIGITS_LUT);
    auto current = bytes + size;

    *current = 0;
    current -= 1;
    while (value >= 1'0000) {
        const auto rem = static_cast<NSUInteger>(value % 1'0000);
        value /= 1'0000;

        const auto d1 = (rem / 100) << 1;
        const auto d2 = (rem % 100) << 1;
        current -= 4;

        // We are allowed to copy to `current...current + 3` here since
        // otherwise `current < bytes`. But then `n` was originally at
        // least `10000^10` which is `10^40 > 2^128 > n`.
        std::memcpy(current, lut + d1, 2);
        std::memcpy(current + 2, lut + d2, 2);
    }

    // if we reach here numbers are <= 9999, so at most 4 chars long
    auto n = static_cast<NSUInteger>(value); // possibly reduce 64bit math

    // decode 2 more chars, if > 2 chars
    if (n >= 100) {
        const auto d1 = (n % 100) << 1;
        n /= 100;
        current -= 2;
        std::memcpy(current, lut + d1, 2);
    }

    // decode last 1 or 2 chars
    if (n < 10) {
        current -= 1;
        *current = static_cast<uint8_t>(n) + '0';
    } else {
        const auto d1 = n << 1;
        current -= 2;
        std::memcpy(current, lut + d1, 2);
    }
    if (is_negative) {
        *current = '-';
        current -= 1;
    }
    return (bytes + size) - current;
}

} // namespace cci

#define FORMAT_INTEGER(INTEGER, NAME, IS_NEGATIVE)                                          \
size_t cci_write_##NAME##_binary(cci_buffer_128* CS_NONNULL buffer, INTEGER value) {        \
    return cci::format_int<INTEGER, cci::Binary>(buffer, value);                            \
}                                                                                           \
size_t cci_write_##NAME##_octal(cci_buffer_128* CS_NONNULL buffer, INTEGER value) {         \
    return cci::format_int<INTEGER, cci::Octal>(buffer, value);                             \
}                                                                                           \
size_t cci_write_##NAME##_lower_hex(cci_buffer_128* CS_NONNULL buffer, INTEGER value) {     \
    return cci::format_int<INTEGER, cci::LowerHex>(buffer, value);                          \
}                                                                                           \
size_t cci_write_##NAME##_upper_hex(cci_buffer_128* CS_NONNULL buffer, INTEGER value) {     \
    return cci::format_int<INTEGER, cci::UpperHex>(buffer, value);                          \
}                                                                                           \
size_t cci_write_##NAME##_decimal(cci_buffer_64* CS_NONNULL buffer, INTEGER value) {        \
    return cci::format_64(buffer, static_cast<uint64_t>(value), IS_NEGATIVE);               \
}                                                                                           \

FORMAT_INTEGER(int8_t, int8, value < 0)
FORMAT_INTEGER(int16_t, int16, value < 0)
FORMAT_INTEGER(int32_t, int32, value < 0)
FORMAT_INTEGER(int64_t, int64, value < 0)
FORMAT_INTEGER(NSInteger, int, value < 0)

FORMAT_INTEGER(uint8_t, uint8, false)
FORMAT_INTEGER(uint16_t, uint16, false)
FORMAT_INTEGER(uint32_t, uint32, false)
FORMAT_INTEGER(uint64_t, uint64, false)
FORMAT_INTEGER(NSUInteger, uint, false)
