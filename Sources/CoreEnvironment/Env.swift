// Namespace for various functions.
public enum Env {
    /// Returns the current working directory as a ``Path``.
    ///
    /// # Platform-specific behavior
    ///
    /// This function currently corresponds to the `getcwd` function on Unix
    /// and the `GetCurrentDirectoryW` function on Windows.
    @inlinable
    public static func currentDirectory() -> IOResult<Path> {
        _currentDirectory()
    }
}
