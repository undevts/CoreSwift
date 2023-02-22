//#include <optional>
//#include <CoreCxx/CFPointer.h>
//#include <CoreFoundation/CoreFoundation.h>
//
//namespace cf {
//
//namespace internal {
//template<typename T, std::enable_if_t<std::is_same_v<T, int32_t>, bool> = true>
//CF_INLINE CFNumberRef makeRawNumber(T value) {
//    return CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &value);
//}
//
//template<typename T, std::enable_if_t<std::is_same_v<T, int64_t>, bool> = true>
//CF_INLINE CFNumberRef makeRawNumber(T value) {
//    return CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &value);
//}
//
//template<typename T, std::enable_if_t<std::is_same_v<T, int32_t>, bool> = true>
//CF_INLINE std::optional<T> fromRawNumber(CFNumberRef ref) {
//    int32_t result = 0;
//    auto success = CFNumberGetValue(ref, kCFNumberSInt32Type, &result);
//    if (success) {
//        return result;
//    }
//    return std::nullopt;
//}
//
//template<typename T, std::enable_if_t<std::is_same_v<T, int64_t>, bool> = true>
//CF_INLINE std::optional<T> fromRawNumber(CFNumberRef ref) {
//    int64_t result = 0;
//    auto success = CFNumberGetValue(ref, kCFNumberSInt64Type, &result);
//    if (success) {
//        return result;
//    }
//    return std::nullopt;
//}
//} // namespace internal
//
//template<typename T>
//class Base {
//public:
//    Base() noexcept = default;
//    ~Base() noexcept = default;
//    Base(const Base&) noexcept = default;
//    Base& operator=(const Base&) noexcept = default;
//    Base(Base&&) noexcept = default;
//    Base& operator=(Base&&) noexcept = default;
//
//    explicit Base(T value): _ref(value) {}
//
//    T release() {
//        return _ref.release();
//    }
//
//protected:
//    CFPointer<T> _ref;
//};
//
//class Number final: Base<CFNumberRef> {
//public:
//    using Super = Base<CFNumberRef>;
//    using Super::Base;
//
//    template<typename T>
//    explicit Number(T value): Super(internal::makeRawNumber(value)) {}
//
//    template<typename T>
//    [[nodiscard]] inline std::optional<T> as() const {
//        if (!_ref) {
//            return std::nullopt;
//        }
//        return internal::fromRawNumber<T>(*_ref);
//    }
//
//    [[nodiscard]] inline std::optional<int32_t> asInt32() const {
//        return as<int32_t>();
//    }
//
//    [[nodiscard]] inline std::optional<int64_t> asInt64() const {
//        return as<int64_t>();
//    }
//
//    static inline Number int32(int32_t value) {
//        return Number{value};
//    }
//
//    static inline Number int64(int64_t value) {
//        return Number{value};
//    }
//};
//}

int main() {
//    cf::Number number;
//    printf("%d\n", number.asInt32().value_or(0));
//    printf("%lld\n", number.asInt64().value_or(0));
    return 0;
}