// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.
//
// In jurisdictions that recognize copyright laws, the author or authors
// of this software dedicate any and all copyright interest in the
// software to the public domain. We make this dedication for the benefit
// of the public at large and to the detriment of our heirs and
// successors. We intend this dedication to be an overt act of
// relinquishment in perpetuity of all present and future rights to this
// software under copyright law.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// For more information, please refer to <http://unlicense.org/>

import Foundation
import CZip

typealias CZipHandle = OpaquePointer

enum CZipMode: Int8 {
    /// Opens a file for reading/extracting (the file must exist).
    case read = 114
    
    /// Creates an empty file for writing.
    case write = 119
    
    /// Appends to an existing archive.
    case append = 97
}

/// Opens zip archive with compression level using the given mode.
///
/// - parameter filename: Filename of Zip archive.
/// - parameter compressionLevel: Compression level, .level6 is default.
/// - parameter mode: File access mode.
///
/// - returns: The Zip archive handle. Throws on error.
///
func zipOpen(filename: String, compressionLevel: ZipCompressionLevel = .level6, mode: CZipMode) throws -> CZipHandle {
    guard let handle = zip_open(filename, Int32(compressionLevel.rawValue), mode.rawValue) else {
        throw ZipError.failedToOpenArchive(filename)
    }
    return handle
}

/// Closes the zip archive and releases resources.
///
/// - parameter handle: Zip archive handle.
///
func zipClose(handle: CZipHandle) {
    zip_close(handle)
}

/// Opens an entry by name in the zip archive.
///
/// For zip archive opened in 'w' or 'a' mode the function will append
/// a new entry. In readonly mode the function tries to locate the entry
/// in global dictionary.
///
/// Throws on error.
///
/// - parameter handle: Zip archive handle.
/// - parameter entryname: An entry name in the archive.
///
func zipOpenEntry(handle: CZipHandle, entryName: String) throws {
    guard zip_entry_open(handle, entryName) == 0 else {
        throw ZipError.failedToOpenEntryInArchive(entryName)
    }
}

/// Opens a new entry by index in the zip archive.
///
/// This function is only valid if zip archive was opened in 'r' (read) mode.
///
/// Throws on error.
///
/// - parameter handle: Zip archive handle.
/// - parameter index: Index in local dictionary.
///
func zipOpenEntryByIndex(handle: CZipHandle, index: Int) throws {
    guard zip_entry_openbyindex(handle, Int32(index)) == 0 else {
        throw ZipError.failedToOpenEntryAtIndex(index)
    }
}

/// Closes a zip entry, flushes buffer and releases resources.
///
/// Throws on error.
///
/// - parameter handle: Zip archive handle.
///
func zipCloseEntry(handle: CZipHandle) throws {
    guard zip_entry_close(handle) == 0 else {
        throw ZipError.failedToCloseEntry
    }
}

/// Returns a local name of the current zip entry.
///
/// The main difference between user's entry name and local entry name
/// is optional relative path.
/// Following .ZIP File Format Specification - the path stored MUST not contain
/// a drive or device letter, or a leading slash.
///
/// - parameter handle: Zip archive handle.
///
/// - returns: Current zip entry name. Throws on error.
///
func zipCurrentEntryName(handle: CZipHandle) throws -> String {
    guard let currentEntryName = zip_entry_name(handle) else {
        throw ZipError.failedToGetInformationForCurrentEntry
    }
    return String(cString: currentEntryName)
}

/// Returns index of the current zip entry.
///
/// - parameter handle: Zip archive handle.
///
/// - returns: Index on success. Throws on error.
///
func zipIndexOfCurrentEntry(handle: CZipHandle) throws -> Int {
    let index = zip_entry_index(handle)
    guard index >= 0 else {
        throw ZipError.failedToGetInformationForCurrentEntry
    }
    return Int(index)
}

/// Determines if the current zip entry is a directory entry.
///
/// Throws on error.
///
/// - parameter handle: Zip archive handle.
///
/// - returns: Returns true if entry is directory, false otherwise.
///
func zipIsCurrentEntryDirectory(handle: CZipHandle) throws -> Bool {
    let result = zip_entry_isdir(handle)
    guard result == 0 || result == 1 else {
        throw ZipError.failedToGetInformationForCurrentEntry
    }
    return result == 1
}

/// Returns an uncompressed size of the current zip entry.
///
/// - parameter handle: Zip archive handle.
///
/// - returns: the uncompressed size in bytes.
///
func zipUncompressedSizeOfCurrentEntry(handle: CZipHandle) -> UInt {
    UInt(zip_entry_size(handle))
}

/// Returns CRC-32 checksum of the current zip entry.
///
/// - parameter handle: Zip archive handle.
///
/// - returns: the CRC-32 checksum.
///
func zipCurrentEntryCRC32(handle: CZipHandle) -> Int {
    Int(zip_entry_crc32(handle))
}

/// Compresses an input buffer for the current zip entry.
///
/// Throws on error.
///
/// - parameter handle: Zip archive handle.
/// - parameter data: Data to write to entry.
///
func zipWriteDataToCurrentEntry(handle: CZipHandle, data: Data) throws {
    try data.withUnsafeBytes { pointer in
        guard zip_entry_write(handle, pointer.baseAddress, data.count) == 0 else {
            throw ZipError.failedToWriteEntry
        }
    }
}

/// Compresses a file for the current zip entry.
///
/// Throws on error.
///
/// - parameter handle: Zip archive handle.
/// - parameter filename: Name of file to write to entry.
///
func zipWriteFileToCurrentEntry(handle: CZipHandle, filename: String) throws {
    guard zip_entry_fwrite(handle, filename) == 0 else {
        throw ZipError.failedToWriteEntry
    }
}

/// Extracts the current zip entry into a memory buffer using no memory
/// allocation.
///
/// - parameter handle: Zip archive handle.
///
/// - returns: Extracted data. Throws on error.
///
func zipReadCurrentEntry(handle: CZipHandle) throws -> Data {
    let size = Int(Double(zipUncompressedSizeOfCurrentEntry(handle: handle)) * 1.5)
    guard let buffer = malloc(size) else {
        throw ZipError.failedToReadEntry
    }
    defer { free(buffer) }
    let readSize = zip_entry_noallocread(handle, buffer, size)
    guard readSize >= 0 else {
        throw ZipError.failedToReadEntry
    }
    return Data(bytes: buffer, count: readSize)
}

/// Extracts the current zip entry into output file.
///
/// Throws on error.
///
/// - parameter handle: Zip archive handle.
/// - parameter filename: Path of file to extract entry to.
///
func zipReadCurrentEntryToFile(handle: CZipHandle, filename: String) throws {
    guard zip_entry_fread(handle, filename) == 0 else {
        throw ZipError.failedToReadEntry
    }
}

/// Returns the number of all entries (files and directories) in the zip archive.
///
/// - parameter handle: Zip archive handle.
///
/// - returns: The number of entries on success. Throws on error.
///
func zipTotalEntryCount(handle: CZipHandle) throws -> Int {
    let result = zip_total_entries(handle)
    guard result >= 0 else {
        throw ZipError.failedToGetEntryCount
    }
    return Int(result)
}
