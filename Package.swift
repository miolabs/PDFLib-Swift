// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PDFLib-Swift",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PDFLib-Swift",
            targets: ["PDFLib-Swift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/miolabs/MIOCore", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .systemLibrary(
            name: "CPDFLib",
            pkgConfig: "pdflib",
            providers: []
        ),
        .target(
            name: "PDFLib-Swift",
            dependencies: ["CPDFLib", "MIOCore"],
            swiftSettings: [.define("PDFLIB_7")]
        ),
        .testTarget(
            name: "PDFLib-SwiftTests",
            dependencies: ["PDFLib-Swift"],
            resources: [.copy("Resources")]
        ),
    ]
)
