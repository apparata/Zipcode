// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Zipcode",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13)
    ],
    products: [
        .library(name: "Zipcode", targets: ["Zipcode"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Zipcode",
            dependencies: ["CZip"],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
        .target(
            name: "CZip"
        ),
        .testTarget(name: "ZipcodeTests", dependencies: ["Zipcode"]),
    ]
)
