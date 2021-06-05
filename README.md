
# Zipcode

Zipcode is a simple Swift framework for reading and writing zip files.

## License

Zipcode is public domain. See UNLICENSE file for details.

Zipcode is based around [zip](https://github.com/kuba--/zip) which in turn is based on [miniz](https://code.google.com/archive/p/miniz/).  Both zip and miniz are public domain under the UNLICENSE license.

## Examples

Printing the number of entries and the name of the entries in a zip file:

```Swift
let archive = ZipArchive(path: "/tmp/Zipcode.zip")
try archive.read { reader in
    print("Number of entries: ", try reader.entryCount())
    let entries = try reader.entries()
    for entry in entries {
        print(entry.name)
    }
}
```

Unzipping an entry into memory:

```Swift
let archive = ZipArchive(path: "/tmp/Zipcode.zip")
try archive.read { reader in
    let data = try reader.readEntryNamed("Zipcode/Package.swift")
    let string = String(data: data, encoding: .utf8) ?? "<Data is not a string>"
    print(string)
}
```

Writing text files to a zip file:

```Swift
let archive = ZipArchive(path: "/tmp/Zipcode.zip")
try archive.write(type: .overwrite) { writer in
    try writer.writeEntryNamed("textfile1.txt", "Text Content 1".data(using: .utf8))
    try writer.writeEntryNamed("otherfiles/textfile2.txt", "Text Content 2".data(using: .utf8)) 
}
```

