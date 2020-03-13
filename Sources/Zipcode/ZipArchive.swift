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

public class ZipArchive {
        
    public enum WriteType {
        case overwrite
        case append
    }
    
    public let path: String

    private let lock = NSLock()

    public init(path: String) {
        self.path = path
    }

    public func write(type: WriteType, action: (ZipWriter) throws -> Void) throws {
        lock.lock()
        defer { lock.unlock() }
        
        let handle = try zipOpen(filename: path, mode: type == .overwrite ? .write : .append)
        let writer = ZipWriter(handle: handle)
        do {
            try action(writer)
        } catch {
            zipClose(handle: handle)
            throw error
        }
        zipClose(handle: handle)
    }

    public func read(action: (ZipReader) throws -> Void) throws {
        lock.lock()
        defer { lock.unlock() }
        
        let handle = try zipOpen(filename: path, mode: .read)
        let reader = ZipReader(handle: handle)
        do {
            try action(reader)
        } catch {
            zipClose(handle: handle)
            throw error
        }
        zipClose(handle: handle)
    }

}
