public protocol BufferReader: Reader {
    mutating func fill() -> IOResult<Bytes>
    mutating func consume(amt: UInt)
}
