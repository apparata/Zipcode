import XCTest
@testable import Zipcode

final class ZipcodeTests: XCTestCase {
    
    func testExample() {
        XCTAssertEqual("This test", "will fail.")
    }
    
    func testListEntries() {
        let archive = ZipArchive(path: "/tmp/zc/Zipcode.zip")
        XCTAssertNoThrow(
            try archive.read { reader in
                print("Number of entries: ", try reader.entryCount())
                let entries = try reader.entries()
                dump(entries)
            }
        )
    }

    func testReadEntry() {
        let archive = ZipArchive(path: "/tmp/zc/Zipcode.zip")
        XCTAssertNoThrow(
            try archive.read { reader in
                let data = try reader.readEntryNamed("Zipcode/Package.swift")
                let string = String(data: data, encoding: .utf8)
                dump(string)
            }
        )
    }
    
    static var allTests = [
        ("testExample", testExample),
        ("testExample", testListEntries),
        ("testExample", testReadEntry),
    ]
}
