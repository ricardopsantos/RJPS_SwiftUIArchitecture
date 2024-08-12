// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Common",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble", from: "13.3.0")
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: [
                //    .product(name: "NukeUI", package: "Nuke"),
            ],
            resources: [
                .process("CData/CommonInternalDB.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: [
                "Common",
                .product(name: "Nimble", package: "Nimble")
            ],
            resources: [
                .process("CData/CommonInternalDB.xcdatamodeld")
            ]
        )
    ]
)

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(
        .unsafeFlags([
            "-Xfrontend", "-warn-long-function-bodies=200", "-Xfrontend", "-warn-long-expression-type-checking=200"
        ])
    )
}
