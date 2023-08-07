extension Path {
    /// Queries the file system to get information about a file, directory, etc.
    ///
    /// This function will traverse symbolic links to query information about the
    /// destination file.
    ///
    /// This is an alias to``Filesystem/metadata(path:)``.
    @inlinable
    public func metadata() -> IOResult<FileMetadata> {
        Filesystem.metadata(path: self)
    }

    /// Returns `true` if the path points at an existing entity.
    ///
    /// Warning: this method may be error-prone, consider using ``tryExists()`` instead!
    /// It also has a risk of introducing time-of-check to time-of-use (TOCTOU) bugs.
    ///
    /// This function will traverse symbolic links to query information about the
    /// destination file.
    ///
    /// If you cannot access the metadata of the file, e.g. because of a
    /// permission error or broken symbolic links, this will return `false`.
    @inlinable
    public func exists() -> Bool {
        Filesystem.exists(path: self)
    }

    /// Returns `Some(true)` if the path points at an existing entity.
    ///
    /// This function will traverse symbolic links to query information about the
    /// destination file. In case of broken symbolic links this will return `.success(false)`.
    ///
    /// As opposed to the ``exists()`` method, this one doesn't silently ignore errors
    /// unrelated to the path not existing. (E.g. it will return `.failure(_)` in case of permission
    /// denied on some of the parent directories.)
    ///
    /// Note that while this avoids some pitfalls of the ``exists()`` method, it still can not
    /// prevent time-of-check to time-of-use (TOCTOU) bugs. You should only use it in scenarios
    /// where those bugs are not an issue.
    @inlinable
    public func tryExists() -> IOResult<Bool> {
        Filesystem.tryExists(path: self)
    }
}
