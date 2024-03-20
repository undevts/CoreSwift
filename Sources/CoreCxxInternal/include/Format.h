#ifndef CORE_CXX_INTERNAL_FORMAT_H
#define CORE_CXX_INTERNAL_FORMAT_H

#if __has_include(<CoreSwift/Buffer.h>)
#include <CoreSwift/Buffer.h>
#elif __has_include(<CoreCxxInternal/Buffer.h>)
#include <CoreCxxInternal/Buffer.h>
#else
#include <Buffer.h>
#endif

CS_C_FILE_BEGIN

size_t cci_write_int8_binary(cci_buffer_128* CS_NONNULL buffer, int8_t value);
size_t cci_write_int8_octal(cci_buffer_128* CS_NONNULL buffer, int8_t value);
size_t cci_write_int8_decimal(cci_buffer_64* CS_NONNULL buffer, int8_t value);
size_t cci_write_int8_lower_hex(cci_buffer_128* CS_NONNULL buffer, int8_t value);
size_t cci_write_int8_upper_hex(cci_buffer_128* CS_NONNULL buffer, int8_t value);
size_t cci_write_int16_binary(cci_buffer_128* CS_NONNULL buffer, int16_t value);
size_t cci_write_int16_octal(cci_buffer_128* CS_NONNULL buffer, int16_t value);
size_t cci_write_int16_decimal(cci_buffer_64* CS_NONNULL buffer, int16_t value);
size_t cci_write_int16_lower_hex(cci_buffer_128* CS_NONNULL buffer, int16_t value);
size_t cci_write_int16_upper_hex(cci_buffer_128* CS_NONNULL buffer, int16_t value);
size_t cci_write_int32_binary(cci_buffer_128* CS_NONNULL buffer, int32_t value);
size_t cci_write_int32_octal(cci_buffer_128* CS_NONNULL buffer, int32_t value);
size_t cci_write_int32_decimal(cci_buffer_64* CS_NONNULL buffer, int32_t value);
size_t cci_write_int32_lower_hex(cci_buffer_128* CS_NONNULL buffer, int32_t value);
size_t cci_write_int32_upper_hex(cci_buffer_128* CS_NONNULL buffer, int32_t value);
size_t cci_write_int64_binary(cci_buffer_128* CS_NONNULL buffer, int64_t value);
size_t cci_write_int64_octal(cci_buffer_128* CS_NONNULL buffer, int64_t value);
size_t cci_write_int64_decimal(cci_buffer_64* CS_NONNULL buffer, int64_t value);
size_t cci_write_int64_lower_hex(cci_buffer_128* CS_NONNULL buffer, int64_t value);
size_t cci_write_int64_upper_hex(cci_buffer_128* CS_NONNULL buffer, int64_t value);
size_t cci_write_int_binary(cci_buffer_128* CS_NONNULL buffer, NSInteger value);
size_t cci_write_int_octal(cci_buffer_128* CS_NONNULL buffer, NSInteger value);
size_t cci_write_int_decimal(cci_buffer_64* CS_NONNULL buffer, NSInteger value);
size_t cci_write_int_lower_hex(cci_buffer_128* CS_NONNULL buffer, NSInteger value);
size_t cci_write_int_upper_hex(cci_buffer_128* CS_NONNULL buffer, NSInteger value);

size_t cci_write_uint8_binary(cci_buffer_128* CS_NONNULL buffer, uint8_t value);
size_t cci_write_uint8_octal(cci_buffer_128* CS_NONNULL buffer, uint8_t value);
size_t cci_write_uint8_decimal(cci_buffer_64* CS_NONNULL buffer, uint8_t value);
size_t cci_write_uint8_lower_hex(cci_buffer_128* CS_NONNULL buffer, uint8_t value);
size_t cci_write_uint8_upper_hex(cci_buffer_128* CS_NONNULL buffer, uint8_t value);
size_t cci_write_uint16_binary(cci_buffer_128* CS_NONNULL buffer, uint16_t value);
size_t cci_write_uint16_octal(cci_buffer_128* CS_NONNULL buffer, uint16_t value);
size_t cci_write_uint16_decimal(cci_buffer_64* CS_NONNULL buffer, uint16_t value);
size_t cci_write_uint16_lower_hex(cci_buffer_128* CS_NONNULL buffer, uint16_t value);
size_t cci_write_uint16_upper_hex(cci_buffer_128* CS_NONNULL buffer, uint16_t value);
size_t cci_write_uint32_binary(cci_buffer_128* CS_NONNULL buffer, uint32_t value);
size_t cci_write_uint32_octal(cci_buffer_128* CS_NONNULL buffer, uint32_t value);
size_t cci_write_uint32_decimal(cci_buffer_64* CS_NONNULL buffer, uint32_t value);
size_t cci_write_uint32_lower_hex(cci_buffer_128* CS_NONNULL buffer, uint32_t value);
size_t cci_write_uint32_upper_hex(cci_buffer_128* CS_NONNULL buffer, uint32_t value);
size_t cci_write_uint64_binary(cci_buffer_128* CS_NONNULL buffer, uint64_t value);
size_t cci_write_uint64_octal(cci_buffer_128* CS_NONNULL buffer, uint64_t value);
size_t cci_write_uint64_decimal(cci_buffer_64* CS_NONNULL buffer, uint64_t value);
size_t cci_write_uint64_lower_hex(cci_buffer_128* CS_NONNULL buffer, uint64_t value);
size_t cci_write_uint64_upper_hex(cci_buffer_128* CS_NONNULL buffer, uint64_t value);
size_t cci_write_uint_binary(cci_buffer_128* CS_NONNULL buffer, NSUInteger value);
size_t cci_write_uint_octal(cci_buffer_128* CS_NONNULL buffer, NSUInteger value);
size_t cci_write_uint_decimal(cci_buffer_64* CS_NONNULL buffer, NSUInteger value);
size_t cci_write_uint_lower_hex(cci_buffer_128* CS_NONNULL buffer, NSUInteger value);
size_t cci_write_uint_upper_hex(cci_buffer_128* CS_NONNULL buffer, NSUInteger value);

CS_C_FILE_END

#endif // CORE_CXX_INTERNAL_FORMAT_H
