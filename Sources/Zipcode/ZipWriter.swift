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

public class ZipWriter {

    private let handle: OpaquePointer

    init(handle: OpaquePointer) {
        self.handle = handle
    }
    
    public func entryCount() throws -> Int {
        try zipTotalEntryCount(handle: handle)
    }
    
    public func entries() throws -> [ZipEntryMetadata] {
        let entryCount = try zipTotalEntryCount(handle: handle)
        return try (0..<entryCount).map {
            try ZipEntryMetadata(handle: handle, index: $0)
        }
    }
    
    public func writeEntry(_ entry: ZipEntryMetadata, data: Data) throws {
        try writeEntry(at: entry.index, data: data)
    }
    
    public func writeEntry(at index: Int, data: Data) throws {
        try zipOpenEntryByIndex(handle: handle, index: index)
        do {
            try zipWriteDataToCurrentEntry(handle: handle, data: data)
        } catch {
            try? zipCloseEntry(handle: handle)
            throw error
        }
        try zipCloseEntry(handle: handle)
    }
    
    public func writeEntryNamed(_ name: String, data: Data) throws {
        try zipOpenEntry(handle: handle, entryName: name)
        do {
            try zipWriteDataToCurrentEntry(handle: handle, data: data)
        } catch {
            try? zipCloseEntry(handle: handle)
            throw error
        }
        try zipCloseEntry(handle: handle)
    }
    
    public func writeEntry(_ entry: ZipEntryMetadata, from filename: String) throws {
        return try writeEntry(at: entry.index, from: filename)
    }
    
    public func writeEntry(at index: Int, from filename: String) throws {
        try zipOpenEntryByIndex(handle: handle, index: index)
        do {
            try zipWriteFileToCurrentEntry(handle: handle, filename: filename)
        } catch {
            try? zipCloseEntry(handle: handle)
            throw error
        }
        try zipCloseEntry(handle: handle)
    }

    public func writeEntryNamed(_ name: String, from filename: String) throws {
        try zipOpenEntry(handle: handle, entryName: name)
        do {
            try zipWriteFileToCurrentEntry(handle: handle, filename: filename)
        } catch {
            try? zipCloseEntry(handle: handle)
            throw error
        }
        try zipCloseEntry(handle: handle)
    }
}
