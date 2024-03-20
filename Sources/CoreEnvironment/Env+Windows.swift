#if os(Windows)

@usableFromInline
func _currentDirectory() -> IOResult<Path> {
    fatalError()
}

#endif // os(Windows)
